#include "../../include/OpenCV/SobelCV.hpp"

// Function Definition
double sobel_cv(string input_file, string output_file)
{
    // Variable Declarations
    cv::Mat input_image, blur_image, sobel_image;
    cv::String sobel_cv_input_file, sobel_cv_output_file;
    StopWatchInterface *sobel_cv_timer = nullptr;

    // Code
    sdkCreateTimer(&sobel_cv_timer);

    // Input and Output File 
    sobel_cv_input_file = input_file;
    filesystem::path output_path = filesystem::path(input_file).filename();
    string output_file_name = output_path.string();
    sobel_cv_output_file = output_file + "/Sobel_OpenCV_" + output_file_name;
    
    // Read Input Image
    input_image = cv::imread(sobel_cv_input_file, cv::IMREAD_GRAYSCALE);

    // Sobel Edge Detection
    sdkStartTimer(&sobel_cv_timer);
    {
        cv::GaussianBlur(input_image, blur_image, cv::Size(CV_GAUSSIAN_KERNEL_SIZE, CV_GAUSSIAN_KERNEL_SIZE), 0);
        cv::Sobel(blur_image, sobel_image, CV_64F, 1, 1, CV_SOBEL_KERNEL_SIZE);
    }
    sdkStopTimer(&sobel_cv_timer);

    // Get Execution Time
    double result = sdkGetTimerValue(&sobel_cv_timer);

    // Write Output Image
    sobel_image.convertTo(sobel_image, CV_8UC1);
    cv::imwrite(sobel_cv_output_file, sobel_image);

    // Cleanup Code
    sdkDeleteTimer(&sobel_cv_timer);
    sobel_cv_timer = nullptr;

    sobel_image.release();
    blur_image.release();
    input_image.release();

    return result;
}
