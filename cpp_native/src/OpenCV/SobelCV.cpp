#include "../../include/OpenCV/SobelCV.hpp"

cv::Mat input_img, blur_image, sobel_image;
cv::String sobel_cv_input_file, sobel_cv_output_file;
StopWatchInterface *sobel_cv_timer = nullptr;

double sobel_cv(string input_file)
{
    sdkCreateTimer(&sobel_cv_timer);

    sobel_cv_input_file = input_file;
    string output_file_name = filesystem::path(input_file).filename();
    sobel_cv_output_file = "/home/atharv/Downloads/Images/Output/Sobel_OpenCV_" + output_file_name;
    
    input_img = cv::imread(sobel_cv_input_file, cv::IMREAD_GRAYSCALE);

    sdkStartTimer(&sobel_cv_timer);
    cv::GaussianBlur(input_img, blur_image, cv::Size(3, 3), 0);
    cv::Sobel(blur_image, sobel_image, CV_64F, 1, 1, 5);
    sdkStopTimer(&sobel_cv_timer);
    double result = sdkGetTimerValue(&sobel_cv_timer);

    cv::imwrite(sobel_cv_output_file, sobel_image);

    sobel_cv_cleanup();

    return result;
}

void sobel_cv_cleanup(void)
{
    if (sobel_cv_timer)
    {
        sdkDeleteTimer(&sobel_cv_timer);
        sobel_cv_timer = nullptr;
    }

    sobel_image.release();
    blur_image.release();
    input_img.release();
}
