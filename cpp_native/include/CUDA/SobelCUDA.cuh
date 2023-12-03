// Headers
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui.hpp>
#include <iostream>
#include <filesystem>
#include <cstdlib>
#include <cuda.h>
#include <cuda_runtime.h>

#ifndef HELPER_TIMER_H
#define HELPER_TIMER_H
    #include "../Common/helper_timer.h"
#endif

#include "../Common/Macros.hpp"

#ifndef NOMINMAX
    #define NOMINMAX
#endif

using namespace std;

// Function Declarations

// Utils
void cuda_sobel_mem_alloc(void** dev_ptr, size_t size);
void cuda_sobel_mem_copy(void *dst, const void *src, size_t count, cudaMemcpyKind kind);
void cuda_sobel_mem_free(void** dev_ptr);

double sobel_cuda(string input_file, string output_file);
double sobel_operator(cv::Mat *input_image, cv::Mat *output_image);
void sobel_cuda_cleanup(void);
