#include "../include/OpenCV/SobelCV.hpp"
#include "../include/OpenCV/CannyCV.hpp"
#include "../include/CUDA/SobelCUDA.cuh"
#include "../include/CUDA/CannyCUDA.cuh"

// Library Exports
extern "C" double sobelCV(const char *input_file, const char *output_path)
{
    return sobel_cv(string(input_file), string(output_path));
}

extern "C" double cannyCV(const char *input_file, const char *output_path)
{
    return canny_cv(string(input_file), string(output_path));
}

extern "C" double sobelCUDA(const char *input_file, const char *output_path)
{
    return sobel_cuda(string(input_file), string(output_path));
}

extern "C" double cannyCUDA(const char *input_file, const char *output_path)
{
    return canny_cuda(string(input_file), string(output_path));
}


