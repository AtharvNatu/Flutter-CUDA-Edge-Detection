#include "../../include/CUDA/CannyCUDA.cuh"

// Global Variables
uchar_t *input_pixels = nullptr, *output_pixels = nullptr, *segment_pixels = nullptr, *final_result = nullptr;
double *gradient_pixels = nullptr, *max_pixels = nullptr, *gaussian_kernel_gpu = nullptr;
schar_t* sobel_kernel_x_gpu = nullptr, *sobel_kernel_y_gpu = nullptr;

// CUDA Kernels
__global__ void gaussianBlur(const uchar_t* input_data, uchar_t* output_data, int image_width, int image_height, double* gaussian_kernel)
{
    // Code
	int id = blockIdx.x * blockDim.x + threadIdx.x;

	const int offset_xy = ((CV_GAUSSIAN_KERNEL_SIZE - 1) / 2);

	if ((id >= 0 && id < image_height * image_width))
    {
        double kernelSum = 0;
        double blurPixel = 0;

        for (int i = 0; i < CV_GAUSSIAN_KERNEL_SIZE; i++) 
        {
            for (int j = 0; j < CV_GAUSSIAN_KERNEL_SIZE; j++) 
            {
                if (((id + ((i - offset_xy) * image_width) + j - offset_xy) >= 0) && 
                    ((id + ((i - offset_xy) * image_width) + j - offset_xy) <= image_height * image_width - 1) && 
                    (((id % image_width) + j - offset_xy) >= 0) && 
                    (((id % image_width) + j - offset_xy) <= (image_width - 1))) 
                    {
                        blurPixel = blurPixel + gaussian_kernel[i * CV_GAUSSIAN_KERNEL_SIZE + j] * input_data[id + ((i - offset_xy) * image_width) + j - offset_xy];
                        kernelSum = kernelSum + gaussian_kernel[i * CV_GAUSSIAN_KERNEL_SIZE + j];
                    }
            }
        }
        
        output_data[id] = (uchar_t)(blurPixel / kernelSum);
    }
}

__global__ void sobelFilter(double* gradient_pixels, uchar_t* segment_pixels, const uchar_t* input_data, int image_width, int image_height, schar_t* sobel_kernel_x, schar_t* sobel_kernel_y ) 
{
    // Code
	int id = blockIdx.x * blockDim.x + threadIdx.x;

	if ((id >= 0 && id < image_height * image_width))
    {
        int offset_xy = 1;
        double convolve_X = 0.0;
        double convolve_Y = 0.0;
        int k = 0;
        int segment = 0;

        int x = id % image_width;
        int y = id / image_width;
        
        if (x < offset_xy || x >= image_width - offset_xy || y < offset_xy || y >= image_height - offset_xy)
            return;
        
        int src_id = x + (y * image_width);

        for (int ky = -offset_xy; ky <= offset_xy; ky++) {
            for (int kx = -offset_xy; kx <= offset_xy; kx++) {
                convolve_X += input_data[src_id + (kx + (ky * image_width))] * sobel_kernel_x[k];
                convolve_Y += input_data[src_id + (kx + (ky * image_width))] * sobel_kernel_y[k];
                k++;
            }
        }

        if (convolve_X == 0.0 || convolve_Y == 0.0) 
        {
            gradient_pixels[src_id] = 0;
        }
        else 
        {
            gradient_pixels[src_id] = ((std::sqrt((convolve_X * convolve_X) + (convolve_Y * convolve_Y))));
            double theta = std::atan2(convolve_Y, convolve_X);
            theta = theta * (360.0 / (2.0 * M_PI));

            if ((theta <= 22.5 && theta >= -22.5) || (theta <= -157.5) || (theta >= 157.5))
                segment = 1;
            else if ((theta > 22.5 && theta <= 67.5) || (theta > -157.5 && theta <= -112.5))
                segment = 2;
            else if ((theta > 67.5 && theta <= 112.5) || (theta >= -112.5 && theta < -67.5))
                segment = 3;
            else if ((theta >= -67.5 && theta < -22.5) || (theta > 112.5 && theta < 157.5))
                segment = 4;
        }

        segment_pixels[src_id] = (uchar_t)segment;
    }
}

__global__ void nonMaxSuppression(double* max_pixels, double* gradient_pixels, uchar_t* segment_pixels, int image_width, int image_height) 
{
    // Code
	int id = blockIdx.x * blockDim.x + threadIdx.x;

	if ((id >= 0 && id < image_height * image_width))
    {
        switch (segment_pixels[id]) 
        {
            case 1:
                if (segment_pixels[id - 1] >= gradient_pixels[id] || gradient_pixels[id + 1] > gradient_pixels[id])
                    max_pixels[id] = 0;
            break;

            case 2:
                if (gradient_pixels[id - (image_width - 1)] >= gradient_pixels[id] || gradient_pixels[id + (image_width - 1)] > gradient_pixels[id])
                    max_pixels[id] = 0;
            break;

            case 3:
                if (gradient_pixels[id - (image_width)] >= gradient_pixels[id] || gradient_pixels[id + (image_width)] > gradient_pixels[id])
                    max_pixels[id] = 0;
            break;

            case 4:
                if (gradient_pixels[id - (image_width + 1)] >= gradient_pixels[id] || gradient_pixels[id + (image_width + 1)] > gradient_pixels[id])
                    max_pixels[id] = 0;
            break;

            default:
                max_pixels[id] = 0;
            break;
        }
    }
}

__global__ void doubleThreshold(uchar_t* out, double* max_pixels, int strong_threshold, int weak_threshold, int image_width, int image_height) 
{
    // Code
	int id = blockIdx.x * blockDim.x + threadIdx.x;

	if ((id >= 0 && id < image_height * image_width))
    {
        if (max_pixels[id] > strong_threshold)
		    out[id] = 255;
        else if (max_pixels[id] > weak_threshold)
            out[id] = 100;
        else
            out[id] = 0;
    }
}

__global__ void edgeHysteresis(uchar_t* out, uchar_t* in, int image_width, int image_height) 
{
    // Code
	int id = blockIdx.x * blockDim.x + threadIdx.x;

	if ((id >= 0 && id < image_height * image_width))
    {
        if (in[id] == 100) 
        {
            if (in[id - 1] == 255 || in[id + 1] == 255 ||
                in[id - image_width] == 255 || in[id + image_width] == 255 ||
                in[id - image_width - 1] == 255 || in[id - image_width + 1] == 255 ||
                in[id + image_width - 1] == 255 || in[id + image_width + 1] == 255)
                {
                    out[id] = 255;
                }
                
            else
                out[id] = 0;
        }
	}
}

void cuda_canny_mem_alloc(void** dev_ptr, size_t size)
{
    // Code
    cudaError_t result = cudaMalloc(dev_ptr, size);
    if (result != cudaSuccess)
    {
        std::cerr << std::endl << "Failed to allocate memory to " << dev_ptr << " : " << cudaGetErrorString(result) << " ... Exiting !!!" << std::endl;
        canny_cuda_cleanup();
        exit(EXIT_FAILURE);
    }
}

void cuda_canny_mem_copy(void *dst, const void *src, size_t count, cudaMemcpyKind kind)
{
    // Code 
    cudaError_t result = cudaMemcpy(dst, src, count, kind);
    if (result != cudaSuccess)
    {
        std::cerr << std::endl << "Failed to copy memory from " << src << " to " << dst << " : " << cudaGetErrorString(result) << " ... Exiting !!!" << std::endl;
        canny_cuda_cleanup();
        exit(EXIT_FAILURE);
    }
}

void cuda_canny_mem_free(void** dev_ptr)
{
    // Code
    if (*dev_ptr)
    {
        cudaFree(*dev_ptr);
        *dev_ptr = nullptr;
    }
}

double canny_operator(uchar_t *input_image_data, uchar_t *output_image_data, int image_width, int image_height)
{
    // Variable Declarations
    StopWatchInterface *canny_cuda_timer = nullptr;

	const double gaussian_kernel[9] = 
    {
		1, 2, 1,
		2, 4, 2,
		1, 2, 1
	};

	const schar_t sobel_kernel_x[] = 
    {   
        -1, 0, 1,
		-2, 0, 2,
		-1, 0, 1 
    };

	const schar_t sobel_kernel_y[] = 
    {    
        1, 2, 1,
		0, 0, 0,
		-1,-2,-1 
    };

	const int NUM_BLOCKS = (image_height * image_width) / THREADS_PER_BLOCK;

	cuda_canny_mem_alloc((void**)&input_pixels, sizeof(uchar_t) * image_height * image_width);
	cuda_canny_mem_alloc((void**)&output_pixels, sizeof(uchar_t) * image_height * image_width);
	cuda_canny_mem_alloc((void**)&gradient_pixels, sizeof(double) * image_height * image_width);
	cuda_canny_mem_alloc((void**)&final_result, sizeof(uchar_t) * image_height * image_width);
	cuda_canny_mem_alloc((void**)&max_pixels, sizeof(double) * image_height * image_width);
	cuda_canny_mem_alloc((void**)&segment_pixels, sizeof(uchar_t) * image_height * image_width);
	cuda_canny_mem_alloc((void**)&gaussian_kernel_gpu, sizeof(double) * CV_GAUSSIAN_KERNEL_SIZE * CV_GAUSSIAN_KERNEL_SIZE);
	cuda_canny_mem_alloc((void**)&sobel_kernel_x_gpu, sizeof(schar_t) * 3 * 3);
	cuda_canny_mem_alloc((void**)&sobel_kernel_y_gpu, sizeof(schar_t) * 3 * 3);

	cuda_canny_mem_copy(input_pixels, input_image_data, image_height * image_width * sizeof(uchar_t), cudaMemcpyHostToDevice);
	cuda_canny_mem_copy(gaussian_kernel_gpu, gaussian_kernel, sizeof(double) * CV_GAUSSIAN_KERNEL_SIZE * CV_GAUSSIAN_KERNEL_SIZE, cudaMemcpyHostToDevice);
	cuda_canny_mem_copy(sobel_kernel_x_gpu, sobel_kernel_x, sizeof(schar_t) * CV_GAUSSIAN_KERNEL_SIZE * CV_GAUSSIAN_KERNEL_SIZE, cudaMemcpyHostToDevice);
	cuda_canny_mem_copy(sobel_kernel_y_gpu, sobel_kernel_y, sizeof(schar_t) * CV_GAUSSIAN_KERNEL_SIZE * CV_GAUSSIAN_KERNEL_SIZE, cudaMemcpyHostToDevice);

    // CUDA Kernel Call
    sdkCreateTimer(&canny_cuda_timer);
    sdkStartTimer(&canny_cuda_timer);
    {
        gaussianBlur<<<NUM_BLOCKS, THREADS_PER_BLOCK>>>(input_pixels, output_pixels, image_width, image_height, gaussian_kernel_gpu);
        sobelFilter<<<NUM_BLOCKS, THREADS_PER_BLOCK>>>(gradient_pixels, segment_pixels, output_pixels, image_width, image_height, sobel_kernel_x_gpu, sobel_kernel_y_gpu);
        
        cuda_canny_mem_copy(max_pixels, gradient_pixels, image_height * image_width * sizeof(double), cudaMemcpyDeviceToDevice);
        
        nonMaxSuppression<<<NUM_BLOCKS, THREADS_PER_BLOCK>>>(max_pixels, gradient_pixels, segment_pixels, image_width, image_height);
        doubleThreshold<<<NUM_BLOCKS, THREADS_PER_BLOCK>>>(output_pixels, max_pixels, CUDA_THRESHOLD * 3, CUDA_THRESHOLD, image_width, image_height);
        
        cuda_canny_mem_copy(final_result, output_pixels, image_height * image_width * sizeof(uchar_t), cudaMemcpyDeviceToDevice);
        
        edgeHysteresis<<<NUM_BLOCKS, THREADS_PER_BLOCK>>>(final_result, output_pixels, image_width, image_height);
    }
    sdkStopTimer(&canny_cuda_timer);

    // Get Execution Time
    double canny_time = sdkGetTimerValue(&canny_cuda_timer);
    sdkDeleteTimer(&canny_cuda_timer);
    canny_cuda_timer = nullptr;

	cuda_canny_mem_copy(output_image_data, final_result, image_width * image_height * sizeof(uchar_t), cudaMemcpyDeviceToHost);

    return canny_time;
}

double canny_cuda(string input_file, string output_file)
{
    // Variable Declarations
    cv::Mat cuda_canny_input_image, cuda_canny_output_image;
    cv::String cuda_canny_input_file, cuda_canny_output_file;

    // Code
    cuda_canny_input_file = input_file;
    filesystem::path output_path = filesystem::path(input_file).filename();
    string output_file_name = output_path.string();

    #if (OS == 1)
        cuda_canny_output_file = output_file + "\\Canny_CUDA_" + output_file_name;
    #elif (OS == 2)
        cuda_canny_output_file = output_file + "/Canny_CUDA_" + output_file_name;
    #endif

    cuda_canny_input_image = cv::imread(cuda_canny_input_file, cv::IMREAD_GRAYSCALE);
    cuda_canny_output_image = cuda_canny_input_image.clone();

    double result = canny_operator(cuda_canny_input_image.data, cuda_canny_output_image.data, cuda_canny_input_image.cols, cuda_canny_input_image.rows);

    cuda_canny_output_image.convertTo(cuda_canny_output_image, CV_8UC1);

    cv::imwrite(cuda_canny_output_file, cuda_canny_output_image);

    canny_cuda_cleanup();
    cuda_canny_output_image.release();
    cuda_canny_input_image.release();

    return result;
}

void canny_cuda_cleanup(void)
{
    // Code
	cuda_canny_mem_free((void**)&final_result);
    cuda_canny_mem_free((void**)&sobel_kernel_y_gpu);
    cuda_canny_mem_free((void**)&sobel_kernel_x_gpu);
    cuda_canny_mem_free((void**)&gaussian_kernel_gpu);
    cuda_canny_mem_free((void**)&segment_pixels);
    cuda_canny_mem_free((void**)&max_pixels);
    cuda_canny_mem_free((void**)&gradient_pixels);
    cuda_canny_mem_free((void**)&output_pixels);
    cuda_canny_mem_free((void**)&input_pixels);
}
