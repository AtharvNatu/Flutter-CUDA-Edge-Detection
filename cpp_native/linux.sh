clear

cd ./bin/

echo "Compiling Source Files ... "
nvcc --std c++20 -w -c -I "/usr/include/opencv4/" ../src/CUDA/*.cu ../src/OpenCV/*.cpp ../src/Main.cpp

echo "Linking Object Files ..."
nvcc -o Main *.o -lcudart -lopencv_core -lopencv_imgproc -lopencv_imgcodecs

cp Main ../

cd ..

./Main ./images/input/img1.jpg
