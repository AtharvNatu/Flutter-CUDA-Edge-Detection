#if defined(WIN32) || defined(_WIN32) || defined(WIN64) || defined(_WIN64)
    
    #include <windows.h>
    #include "../include/OpenCV/SobelCV.hpp"
    #include "../include/OpenCV/CannyCV.hpp"
    #include "../include/CUDA/SobelCUDA.cuh"
    #include "../include/CUDA/CannyCUDA.cuh"

    BOOL APIENTRY DllMain(HMODULE hModule, DWORD  ul_reason_for_call, LPVOID lpReserved) 
    {
        switch (ul_reason_for_call) 
        {
            case DLL_PROCESS_ATTACH:
            case DLL_THREAD_ATTACH:
            case DLL_THREAD_DETACH:
            case DLL_PROCESS_DETACH:
                break;
        }
        return TRUE;
    }

    // Library Exports
    extern "C" __declspec(dllexport) double sobelCV(const char *input_file, const char *output_path)
    {
        return sobel_cv(string(input_file), string(output_path));
    }

    extern "C" __declspec(dllexport) double cannyCV(const char *input_file, const char *output_path)
    {
        return canny_cv(string(input_file), string(output_path));
    }

    extern "C" __declspec(dllexport) double sobelCUDA(const char *input_file, const char *output_path)
    {
        return sobel_cuda(string(input_file), string(output_path));
    }

    extern "C" __declspec(dllexport) double cannyCUDA(const char *input_file, const char *output_path)
    {
        return canny_cuda(string(input_file), string(output_path));
    }

#else
    
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

#endif
