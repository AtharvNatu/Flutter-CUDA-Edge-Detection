#include <iostream>
#include <cstdlib>

#include "../include/OpenCV/SobelCV.hpp"
#include "../include/OpenCV/CannyCV.hpp"
#include "../include/CUDA/SobelCUDA.cuh"
#include "../include/CUDA/CannyCUDA.cuh"

int main(int argc, char* argv[])
{
    if (argv[1] == nullptr)
    {
        cerr << endl << "Error : Please Follow Main <Image-Path> Convention To Execute !!!" << endl;
        exit(EXIT_FAILURE);
    }
    
    sobel_cv(string(argv[1]));

    sobel_cuda(string(argv[1]));

    canny_cv(string(argv[1]));

    canny_cuda(string(argv[1]));

    exit(EXIT_SUCCESS);
}
