// Headers
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui.hpp>
#include <iostream>
#include <filesystem>
#include <cstdlib>
#include <cuda.h>
#include <device_launch_parameters.h>
#include <cuda_runtime.h>

#define _USE_MATH_DEFINES
#include <math.h>

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
void cuda_canny_mem_alloc(void** dev_ptr, size_t size);
void cuda_canny_mem_copy(void *dst, const void *src, size_t count, cudaMemcpyKind kind);
void cuda_canny_mem_free(void** dev_ptr);

double canny_cuda(string input_file, string output_file);
double canny_operator(uchar_t *input_image_data, uchar_t *output_image_data, int image_width, int image_height);
void canny_cuda_cleanup(void);
