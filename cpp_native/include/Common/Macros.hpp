#pragma once

// Macros
#define CUDA_GAUSSIAN_KERNEL_SIZE   3
#define CV_GAUSSIAN_KERNEL_SIZE     3

#define CUDA_SOBEL_KERNEL_SIZE      5
#define CV_SOBEL_KERNEL_SIZE        5

#define CV_THRESHOLD                40
#define CV_RATIO                    3

#define THREADS_PER_BLOCK           1024
#define BLOCK_SIZE                  32
#define CUDA_THRESHOLD              30

// Typedef
typedef unsigned char uchar_t;
typedef signed char schar_t;

