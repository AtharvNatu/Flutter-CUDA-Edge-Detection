#include "../include/OpenCV/SobelCV.hpp"
#include "../include/OpenCV/CannyCV.hpp"
#include "../include/CUDA/SobelCUDA.cuh"
#include "../include/CUDA/CannyCUDA.cuh"

// Library Exports
extern "C" double sobelCV(const char *file_path)
{
    return sobel_cv(string(file_path));
}

extern "C" double cannyCV(const char *file_path)
{
    return canny_cv(string(file_path));
}

extern "C" double sobelCUDA(const char *file_path)
{
    return sobel_cuda(string(file_path));
}

extern "C" double cannyCUDA(const char *file_path)
{
    return canny_cuda(string(file_path));
}


