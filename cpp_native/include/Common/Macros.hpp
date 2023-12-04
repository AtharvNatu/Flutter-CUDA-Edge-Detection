#pragma once

// Macros
#define CUDA_GAUSSIAN_KERNEL_SIZE   3
#define CV_GAUSSIAN_KERNEL_SIZE     3

#define CUDA_SOBEL_KERNEL_SIZE      5
#define CV_SOBEL_KERNEL_SIZE        5

#define CV_THRESHOLD                40
#define CUDA_THRESHOLD              40

#define CV_RATIO                    3
#define CUDA_RATIO                    3

#define THREADS_PER_BLOCK           1024
#define BLOCK_SIZE                  32


#if defined(WIN32) || defined(_WIN32) || defined(WIN64) || defined(_WIN64)
    #define OS 1
#else
    #define OS 2
#endif

// Typedef
typedef unsigned char uchar_t;
typedef signed char schar_t;

