clear

cd ./bin/

echo "Compiling Source Files ... "
nvcc -shared -Xcompiler -fPIC --std c++20 -w -c -I "/usr/include/opencv4/" ../src/CUDA/*.cu ../src/OpenCV/*.cpp ../export/Lib.cpp

echo "Linking Object Files ..."
# nvcc -o Main *.o -lcudart -lopencv_core -lopencv_imgproc -lopencv_imgcodecs

echo "Creating Shared Library ..."
nvcc -shared -o libEdgeDetection.so *.o -lcudart -lopencv_core -lopencv_imgproc -lopencv_imgcodecs

# cp Main ../
cp libEdgeDetection.so ../
echo "Done ..." 

cd ..

