#include "../../include/CUDA/SobelCUDA.cuh"

cv::Mat cuda_sobel_input_image, cuda_sobel_output_image;
cv::String cuda_sobel_input_file, cuda_sobel_output_file;
StopWatchInterface *sobelCudaTimer = nullptr;
unsigned char *deviceInput = nullptr, *deviceOutput = nullptr;
float *hostKernel = nullptr, *deviceKernel = nullptr;

__global__ void gaussianBlurKernel(unsigned char *cuda_sobel_input_image, unsigned char *cuda_sobel_output_image, int width, int height, float *kernel)
{
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x < width && y < height)
    {
        float blurPixel = 0.0f;
        int kernelRadius = GAUSSIAN_KERNEL_SIZE / 2;

        for (int i = -kernelRadius; i <= kernelRadius; i++)
        {
            for (int j = -kernelRadius; j <= kernelRadius; j++)
            {
                int xOffset = x + i;
                int yOffset = y + j;

                if (xOffset >= 0 && xOffset < width && yOffset >= 0 && yOffset < height)
                {
                    int inputIndex = yOffset * width + xOffset;
                    int kernelIndex = (i + kernelRadius) * GAUSSIAN_KERNEL_SIZE + (j + kernelRadius);
                    blurPixel = blurPixel + static_cast<float>(cuda_sobel_input_image[inputIndex]) * kernel[kernelIndex];
                }
            }
        }

        cuda_sobel_output_image[y * width + x] = static_cast<unsigned char>(blurPixel);
    }
}

__global__ void sobelFilterKernel(unsigned char *cuda_sobel_input_image, unsigned char *cuda_sobel_output_image, unsigned int image_width, unsigned int image_height)
{
    int sobel_x[SOBEL_KERNEL_SIZE][SOBEL_KERNEL_SIZE] = {
        { -1, 0, 1 },
        { -2, 0, 2 },
        { -1, 0, 1 }
    };

    int sobel_y[SOBEL_KERNEL_SIZE][SOBEL_KERNEL_SIZE] = {
        { -1, -2, -1 },
        { 0, 0, 0 },
        { 1, 2, 1 }
    };

    int num_rows = blockIdx.x * blockDim.x + threadIdx.x;
    int num_columns = blockIdx.y * blockDim.y + threadIdx.y;

    int index = (num_rows * image_width) + num_columns;

    if ((num_columns < (image_width - 1)) && (num_rows < (image_height - 1)))
    {
        float gradient_x =  (cuda_sobel_input_image[index] * sobel_x[0][0]) + (cuda_sobel_input_image[index + 1] * sobel_x[0][1]) + (cuda_sobel_input_image[index + 2] * sobel_x[0][2]) +
                            (cuda_sobel_input_image[index] * sobel_x[1][0]) + (cuda_sobel_input_image[index + 1] * sobel_x[1][1]) + (cuda_sobel_input_image[index + 2] * sobel_x[1][2]) +
                            (cuda_sobel_input_image[index] * sobel_x[2][0]) + (cuda_sobel_input_image[index + 1] * sobel_x[2][1]) + (cuda_sobel_input_image[index + 2] * sobel_x[2][2]);

        float gradient_y =  (cuda_sobel_input_image[index] * sobel_y[0][0]) + (cuda_sobel_input_image[index + 1] * sobel_y[0][1]) + (cuda_sobel_input_image[index + 2] * sobel_y[0][2]) +
                            (cuda_sobel_input_image[index] * sobel_y[1][0]) + (cuda_sobel_input_image[index + 1] * sobel_y[1][1]) + (cuda_sobel_input_image[index + 2] * sobel_y[1][2]) +
                            (cuda_sobel_input_image[index] * sobel_y[2][0]) + (cuda_sobel_input_image[index + 1] * sobel_y[2][1]) + (cuda_sobel_input_image[index + 2] * sobel_y[2][2]);

        float gradient = sqrtf(gradient_x * gradient_x + gradient_y * gradient_y);

        if (gradient > 255)
            gradient = 255;

        if (gradient < 0)
            gradient = 0;

        __syncthreads();

        cuda_sobel_output_image[index] = gradient;
    }
}

void cuda_sobel_mem_alloc(void** devPtr, size_t size)
{
    cudaError_t result = cudaMalloc(devPtr, size);
    if (result != cudaSuccess)
    {
        std::cerr << std::endl << "Failed to allocate memory to " << devPtr << " : " << cudaGetErrorString(result) << " ... Exiting !!!" << std::endl;
        sobelCleanup();
        exit(EXIT_FAILURE);
    }
}

void cuda_sobel_mem_copy(void *dst, const void *src, size_t count, cudaMemcpyKind kind)
{
    cudaError_t result = cudaMemcpy(dst, src, count, kind);
    if (result != cudaSuccess)
    {
        std::cerr << std::endl << "Failed to copy memory from " << src << " to " << dst << " : " << cudaGetErrorString(result) << " ... Exiting !!!" << std::endl;
        sobelCleanup();
        exit(EXIT_FAILURE);
    }
}

void cuda_sobel_mem_free(void* devPtr)
{
    if (devPtr)
    {
        cudaFree(devPtr);
        devPtr = nullptr;
    }
}

void runSobelOperator(cv::Mat *inputImage, cv::Mat *outputImage)
{
    // Variable Declarations
    cudaError_t result;
    float kernelSum = 0.0f;
    float sigma = 1.0f;

    int imageWidth = inputImage->cols;
    int imageHeight = inputImage->rows;
    int imageSize = imageHeight * imageWidth * sizeof(unsigned char);
    
    // Create Gaussian Kernel
    hostKernel = new float[GAUSSIAN_KERNEL_SIZE * GAUSSIAN_KERNEL_SIZE];
    int kernelRadius = GAUSSIAN_KERNEL_SIZE / 2;

    for (int i = -kernelRadius; i <= kernelRadius; i++) 
    {
        for (int j = -kernelRadius; j <= kernelRadius; j++)
        {
            int index = (i + kernelRadius) * kernelRadius + (j + kernelRadius);
            hostKernel[index] = exp(-(i * i + j + j) / (2.0f * sigma * sigma));
            kernelSum = kernelSum + hostKernel[index];
        }
    }

    for (int i = 0; i < GAUSSIAN_KERNEL_SIZE * GAUSSIAN_KERNEL_SIZE; i++)
    {
        hostKernel[i] = hostKernel[i] / kernelSum;
    }

    sdkCreateTimer(&sobelCudaTimer);

    result = cudaMalloc((void **)&deviceInput, imageSize);
    if (result != cudaSuccess)
    {
        std::cerr << std::endl << "cudaMalloc() Failed For Input Image ... Exiting !!!" << std::endl;
        exit(EXIT_FAILURE);
    }

    result = cudaMalloc((void **)&deviceOutput, imageSize);
    if (result != cudaSuccess)
    {
        std::cerr << std::endl << "cudaMalloc() Failed For Output Image ... Exiting !!!" << std::endl;
        exit(EXIT_FAILURE);
    }

    result = cudaMalloc((void **)&deviceKernel, GAUSSIAN_KERNEL_SIZE * GAUSSIAN_KERNEL_SIZE * sizeof(float));
    if (result != cudaSuccess)
    {
        std::cerr << std::endl << "cudaMalloc() Failed For Device Kernel ... Exiting !!!" << std::endl;
        exit(EXIT_FAILURE);
    }

    result = cudaMemcpy(deviceInput, inputImage->data, imageSize, cudaMemcpyHostToDevice);
    if (result != cudaSuccess)
    {
        std::cerr << std::endl << "cudaMemcpy() Failed For Input Image ... Exiting !!!" << std::endl;
        exit(EXIT_FAILURE);
    }

    result = cudaMemcpy(deviceKernel, hostKernel, GAUSSIAN_KERNEL_SIZE * GAUSSIAN_KERNEL_SIZE * sizeof(float), cudaMemcpyHostToDevice);
    if (result != cudaSuccess)
    {
        std::cerr << std::endl << "cudaMemcpy() Failed For Device Kernel ... Exiting !!!" << std::endl;
        exit(EXIT_FAILURE);
    }

    // Kernel Configuration
    dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE);
    dim3 dimGrid(imageHeight, imageWidth);

    sdkStartTimer(&sobelCudaTimer);
    gaussianBlurKernel<<<dimGrid, dimBlock>>>(deviceInput, deviceOutput, imageWidth, imageHeight, deviceKernel);
    sobelFilterKernel<<<dimGrid, dimBlock>>>(deviceInput, deviceOutput, inputImage->cols, inputImage->rows);
    sdkStopTimer(&sobelCudaTimer);

    result = cudaMemcpy(outputImage->data, deviceOutput, imageSize, cudaMemcpyDeviceToHost);
    if (result != cudaSuccess)
    {
        std::cerr << std::endl << "cudaMemcpy() Failed For Output Image ... Exiting !!!" << std::endl;
        exit(EXIT_FAILURE);
    }
}

void sobelCUDA(int image_number)
{
    switch(image_number)
    {
        case 1:
            cuda_sobel_input_file = "Images\\Input\\img1.jpg";
            cuda_sobel_output_file = "Images\\Output\\Sobel-CUDA-1.jpg";
        break;
        case 2:
            cuda_sobel_input_file = "Images\\Input\\img2.jpg";
            cuda_sobel_output_file = "Images\\Output\\Sobel-CUDA-2.jpg";
        break;
        case 3:
            cuda_sobel_input_file = "Images\\Input\\img3.jpg";
            cuda_sobel_output_file = "Images\\Output\\Sobel-CUDA-3.jpg";
        break;
        case 4:
            cuda_sobel_input_file = "Images\\Input\\img4.jpg";
            cuda_sobel_output_file = "Images\\Output\\Sobel-CUDA-4.jpg";
        break;
        case 5:
            cuda_sobel_input_file = "Images\\Input\\img5.jpg";
            cuda_sobel_output_file = "Images\\Output\\Sobel-CUDA-5.jpg";
        break;
        default:
            std::cerr << std::endl << "Error ... Please Enter Valid Number ... Exiting !!!" << std::endl;
            sobelCleanup();
            exit(EXIT_FAILURE);
        break;
    }

    cuda_sobel_input_image = cv::imread(cuda_sobel_input_file, cv::IMREAD_GRAYSCALE);
    cuda_sobel_output_image = cuda_sobel_input_image.clone();

    runSobelOperator(&cuda_sobel_input_image, &cuda_sobel_output_image);

    std::cout << std::endl << "Time for Sobel Operator using CUDA (GPU) : " << sdkGetTimerValue(&sobelCudaTimer) << " ms" << std::endl;

    cuda_sobel_output_image.convertTo(cuda_sobel_output_image, CV_8UC1);

    cv::imwrite(cuda_sobel_output_file, cuda_sobel_output_image);

    sobelCleanup();
}

void sobelCleanup(void)
{
    if (deviceKernel)
    {
        cudaFree(deviceKernel);
        deviceKernel = nullptr;
    }

    if (deviceOutput)
    {
        cudaFree(deviceOutput);
        deviceOutput = nullptr;
    }

    if (deviceInput)
    {
        cudaFree(deviceInput);
        deviceInput = nullptr;
    }

    if (hostKernel)
    {
        delete[] hostKernel;
        hostKernel = nullptr;
    }

    if (sobelCudaTimer)
    {
        sdkDeleteTimer(&sobelCudaTimer);
        sobelCudaTimer = nullptr;
    }

    cuda_sobel_output_image.release();
    cuda_sobel_input_image.release();
}
