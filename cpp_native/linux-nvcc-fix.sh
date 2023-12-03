clear

cd ./bin/

# For Executable
# echo "Compiling Source Files ... "
# nvcc -ccbin "/opt/cuda/bin" -shared -Xcompiler -fPIC --std=c++20 -w -c -I "/usr/include/opencv4/" ../test/Main.cpp ../src/CUDA/*.cu ../src/OpenCV/*.cpp

# echo "Linking Object Files ..."
# nvcc -o Main *.o -lcudart -lopencv_core -lopencv_imgproc -lopencv_imgcodecs

# cp Main ../

# echo "Generated Executable ..."

# cd ..


# For Shared Library (.so)
echo "Compiling Source Files ... "
nvcc -ccbin "/opt/cuda/bin" -shared -Xcompiler -fPIC --std=c++20 -w -c -I "/usr/include/opencv4/" ../export/Lib.cpp ../src/CUDA/*.cu ../src/OpenCV/*.cpp

echo "Creating Shared Library ..."
nvcc -shared -o libEdgeDetection.so *.o -lcudart -lopencv_core -lopencv_imgproc -lopencv_imgcodecs

cp libEdgeDetection.so ../

echo "Generated Library : libEdgeDetection.so  ..." 

cd ..

