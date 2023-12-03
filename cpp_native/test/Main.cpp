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
    
    cout << "Sobel OpenCV : " << sobel_cv(string(argv[1]), string(argv[2])) << endl;

    cout << "Sobel CUDA : " << sobel_cuda(string(argv[1]), string(argv[2])) << endl;

    cout << "Canny OpenCV : " << canny_cv(string(argv[1]), string(argv[2])) << endl;

    cout << "Canny CUDA : " << canny_cuda(string(argv[1]), string(argv[2])) << endl;

    exit(EXIT_SUCCESS);
}
