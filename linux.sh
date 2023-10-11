clear

cd ./bin/

nvcc -c -I "/usr/include/opencv4/" ../src/CUDA/*.cu ../src/OpenCV/*.cpp ../src/Main.cpp

nvcc -o Main *.o -lcudart -lopencv_core -lopencv_imgproc -lopencv_imgcodecs

cp Main ../

cd ..

clear

./Main 1
