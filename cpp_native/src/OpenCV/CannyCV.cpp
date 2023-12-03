#include "../../include/OpenCV/CannyCV.hpp"

// Function Definitions
double canny_cv(string input_file, string output_file)
{
    // Variable Declarations
    cv::Mat input_image, output_image;
    cv::String canny_cv_input_file, canny_cv_output_file;
    StopWatchInterface *canny_cv_timer = nullptr;

    // Code
    sdkCreateTimer(&canny_cv_timer);
    
    // Input and Output File 
    canny_cv_input_file = input_file;
    filesystem::path output_path = filesystem::path(input_file).filename();
    string output_file_name = output_path.string();
    canny_cv_output_file = output_file + "/Canny_OpenCV_" + output_file_name;

    // Read Input Image
    input_image = cv::imread(canny_cv_input_file, cv::IMREAD_GRAYSCALE);

    // Canny Edge Detection
    sdkStartTimer(&canny_cv_timer);
    {
        cv::GaussianBlur(input_image, output_image, cv::Size(CV_GAUSSIAN_KERNEL_SIZE, CV_GAUSSIAN_KERNEL_SIZE), 0);
        cv::Canny(output_image, output_image, CV_THRESHOLD, CV_THRESHOLD * CV_RATIO, 3);
    }
    sdkStopTimer(&canny_cv_timer);

    // Get Execution Time
    double result = sdkGetTimerValue(&canny_cv_timer);

    // Write Output Image
    output_image.convertTo(output_image, CV_8UC1);
    cv::imwrite(canny_cv_output_file, output_image);

    // Cleanup Code
    sdkDeleteTimer(&canny_cv_timer);
    canny_cv_timer = nullptr;

    output_image.release();
    input_image.release();

    return result;
}

