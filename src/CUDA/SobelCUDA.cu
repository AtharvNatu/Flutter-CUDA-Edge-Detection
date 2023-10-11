#include "../../include/CUDA/SobelCUDA.cuh"

cv::Mat cuda_sobel_input_image, cuda_sobel_output_image;
cv::String cuda_sobel_input_file, cuda_sobel_output_file;
StopWatchInterface *sobel_cuda_timer = nullptr;
unsigned char *device_input = nullptr, *device_output = nullptr;
float *host_kernel = nullptr, *device_kernel = nullptr;

__global__ void gaussianBlurKernel(unsigned char *cuda_sobel_input_image, unsigned char *cuda_sobel_output_image, int width, int height, float *kernel)
{
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x < width && y < height)
    {
        float blur_pixel = 0.0f;
        int kernel_radius = GAUSSIAN_KERNEL_SIZE / 2;

        for (int i = -kernel_radius; i <= kernel_radius; i++)
        {
            for (int j = -kernel_radius; j <= kernel_radius; j++)
            {
                int x_offset = x + i;
                int y_offset = y + j;

                if (x_offset >= 0 && x_offset < width && y_offset >= 0 && y_offset < height)
                {
                    int input_index = y_offset * width + x_offset;
                    int kernel_index = (i + kernel_radius) * GAUSSIAN_KERNEL_SIZE + (j + kernel_radius);
                    blur_pixel = blur_pixel + static_cast<float>(cuda_sobel_input_image[input_index]) * kernel[kernel_index];
                }
            }
        }

        cuda_sobel_output_image[y * width + x] = static_cast<unsigned char>(blur_pixel);
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

void cuda_sobel_mem_alloc(void** dev_ptr, size_t size)
{
    cudaError_t result = cudaMalloc(dev_ptr, size);
    if (result != cudaSuccess)
    {
        std::cerr << std::endl << "Failed to allocate memory to " << dev_ptr << " : " << cudaGetErrorString(result) << " ... Exiting !!!" << std::endl;
        sobel_cuda_cleanup();
        exit(EXIT_FAILURE);
    }
}

void cuda_sobel_mem_copy(void *dst, const void *src, size_t count, cudaMemcpyKind kind)
{
    cudaError_t result = cudaMemcpy(dst, src, count, kind);
    if (result != cudaSuccess)
    {
        std::cerr << std::endl << "Failed to copy memory from " << src << " to " << dst << " : " << cudaGetErrorString(result) << " ... Exiting !!!" << std::endl;
        sobel_cuda_cleanup();
        exit(EXIT_FAILURE);
    }
}

void cuda_sobel_mem_free(void* dev_ptr)
{
    if (dev_ptr)
    {
        cudaFree(dev_ptr);
        dev_ptr = nullptr;
    }
}

void run_sobel_operator(cv::Mat *input_image, cv::Mat *output_image)
{
    // Variable Declarations
    cudaError_t result;
    float kernel_sum = 0.0f;
    float sigma = 1.0f;

    int image_width = input_image->cols;
    int image_height = input_image->rows;
    int image_size = image_height * image_width * sizeof(unsigned char);
    
    // Create Gaussian Kernel
    host_kernel = new float[GAUSSIAN_KERNEL_SIZE * GAUSSIAN_KERNEL_SIZE];
    int kernel_radius = GAUSSIAN_KERNEL_SIZE / 2;

    for (int i = -kernel_radius; i <= kernel_radius; i++) 
    {
        for (int j = -kernel_radius; j <= kernel_radius; j++)
        {
            int index = (i + kernel_radius) * kernel_radius + (j + kernel_radius);
            host_kernel[index] = exp(-(i * i + j + j) / (2.0f * sigma * sigma));
            kernel_sum = kernel_sum + host_kernel[index];
        }
    }

    for (int i = 0; i < GAUSSIAN_KERNEL_SIZE * GAUSSIAN_KERNEL_SIZE; i++)
    {
        host_kernel[i] = host_kernel[i] / kernel_sum;
    }

    sdkCreateTimer(&sobel_cuda_timer);

    cuda_sobel_mem_alloc((void **)&device_input, image_size);
    cuda_sobel_mem_alloc((void **)&device_output, image_size);
    cuda_sobel_mem_alloc((void **)&device_kernel, GAUSSIAN_KERNEL_SIZE * GAUSSIAN_KERNEL_SIZE * sizeof(float));
    
    cuda_sobel_mem_copy(device_input, input_image->data, image_size, cudaMemcpyHostToDevice);
    cuda_sobel_mem_copy(device_kernel, host_kernel, GAUSSIAN_KERNEL_SIZE * GAUSSIAN_KERNEL_SIZE * sizeof(float), cudaMemcpyHostToDevice);

    // Kernel Configuration
    dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE);
    dim3 dimGrid(image_height, image_width);

    sdkStartTimer(&sobel_cuda_timer);
    gaussianBlurKernel<<<dimGrid, dimBlock>>>(device_input, device_output, image_width, image_height, device_kernel);
    sobelFilterKernel<<<dimGrid, dimBlock>>>(device_input, device_output, input_image->cols, input_image->rows);
    sdkStopTimer(&sobel_cuda_timer);

    cuda_sobel_mem_copy(output_image->data, device_output, image_size, cudaMemcpyDeviceToHost);
}

void sobel_cuda(string input_file)
{
    cuda_sobel_input_file = input_file;
    string output_file_name = filesystem::path(input_file).filename();
    cuda_sobel_output_file = "./images/output/Sobel_CUDA_" + output_file_name;

    cuda_sobel_input_image = cv::imread(cuda_sobel_input_file, cv::IMREAD_GRAYSCALE);
    cuda_sobel_output_image = cuda_sobel_input_image.clone();

    run_sobel_operator(&cuda_sobel_input_image, &cuda_sobel_output_image);

    std::cout << std::endl << "Time for Sobel Operator using CUDA (GPU) : " << sdkGetTimerValue(&sobel_cuda_timer) << " ms" << std::endl;

    cuda_sobel_output_image.convertTo(cuda_sobel_output_image, CV_8UC1);

    cv::imwrite(cuda_sobel_output_file, cuda_sobel_output_image);

    sobel_cuda_cleanup();
}

void sobel_cuda_cleanup(void)
{
    cuda_sobel_mem_free(device_kernel);
    cuda_sobel_mem_free(device_output);
    cuda_sobel_mem_free(device_input);

    if (host_kernel)
    {
        delete[] host_kernel;
        host_kernel = nullptr;
    }

    if (sobel_cuda_timer)
    {
        sdkDeleteTimer(&sobel_cuda_timer);
        sobel_cuda_timer = nullptr;
    }

    cuda_sobel_output_image.release();
    cuda_sobel_input_image.release();
}
