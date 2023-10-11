#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui.hpp>
#include <iostream>
#include <filesystem>
#include <cstdlib>
#include <cuda.h>
#include <device_launch_parameters.h>
#include <cuda_runtime.h>
using namespace std;

#define _USE_MATH_DEFINES
#include <math.h>

#ifndef HELPER_TIMER_H
#define HELPER_TIMER_H
    #include "../helper_timer.h"
#endif

#ifndef NOMINMAX
    #define NOMINMAX
#endif

#define THREADS_PER_BLOCK     1024
#define KERNEL_SIZE           3
#define GRID                  0
#define CUDA_THRESHOLD        30

void canny_cuda(string input_file);
void cuda_canny_mem_alloc(void** dev_ptr, size_t size);
void cuda_canny_mem_copy(void *dst, const void *src, size_t count, cudaMemcpyKind kind);
void cuda_canny_mem_free(void* dev_ptr);
void canny_cuda_cleanup(void);
void run_canny_operator(uint8_t *input_image_data, uint8_t *output_image_data, int image_width, int image_height);
