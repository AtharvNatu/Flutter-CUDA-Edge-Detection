#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui.hpp>
#include <iostream>
#include <filesystem>
#include <cstdlib>
#include <cuda.h>
#include <cuda_runtime.h>
using namespace std;

#ifndef HELPER_TIMER_H
#define HELPER_TIMER_H
    #include "../helper_timer.h"
#endif

#ifndef NOMINMAX
    #define NOMINMAX
#endif


#define BLOCK_SIZE            32
#define GRID_SIZE             128
#define SOBEL_KERNEL_SIZE     5
#define GAUSSIAN_KERNEL_SIZE  3

void sobel_cuda(string input_file);
void cuda_sobel_mem_alloc(void** dev_ptr, size_t size);
void cuda_sobel_mem_copy(void *dst, const void *src, size_t count, cudaMemcpyKind kind);
void cuda_sobel_mem_free(void* dev_ptr);
void sobel_cuda_cleanup(void);
void run_sobel_operator(cv::Mat *input_image, cv::Mat *output_image);
