cls

@echo off

cd bin/

nvcc.exe -c "../src/CUDA/SobelCUDA.cu" -I "C:\opencv\build\include"
nvcc.exe -c "../src/CUDA/canny_cuda.cu"  -I "C:\opencv\build\include"

cl.exe /c /EHsc -I "C:\opencv\build\include" -I "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.2\include" "../src/OpenCV/SobelCV.cpp" "../src/OpenCV/CannyCV.cpp" "../src/Main.cpp"

link.exe Main.obj SobelCUDA.obj SobelCV.obj canny_cuda.obj CannyCV.obj /LIBPATH:"C:\opencv\build\x64\vc16\lib" /LIBPATH:"C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.2\lib\x64" cudart.lib opencv_world480.lib opencv_world480d.lib

@move Main.exe "../" > nul

cd ../
