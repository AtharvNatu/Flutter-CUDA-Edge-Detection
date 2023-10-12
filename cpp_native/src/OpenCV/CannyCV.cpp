#include "../../include/OpenCV/CannyCV.hpp"

cv::Mat input_image, output_image;
cv::String canny_cv_input_file, canny_cv_output_file;
StopWatchInterface *canny_cv_timer = nullptr;

void canny_cv(string input_file)
{
    sdkCreateTimer(&canny_cv_timer);
    
    canny_cv_input_file = input_file;
    string output_file_name = filesystem::path(input_file).filename();
    canny_cv_output_file = "./images/output/Canny_OpenCV_" + output_file_name;

    input_image = cv::imread(canny_cv_input_file, cv::IMREAD_GRAYSCALE);

    sdkStartTimer(&canny_cv_timer);
    cv::GaussianBlur(input_image, output_image, cv::Size(3, 3), 0);
    cv::Canny(output_image, output_image, THRESHOLD, THRESHOLD * RATIO, 3);
    sdkStopTimer(&canny_cv_timer);

    std::cout << std::endl << "Time for Canny Operator using OpenCV (CPU) : " << sdkGetTimerValue(&canny_cv_timer) << " ms" << std::endl;

    cv::imwrite(canny_cv_output_file, output_image);

    canny_cv_cleanup();
}

void canny_cv_cleanup(void)
{
    if (canny_cv_timer)
    {
        sdkDeleteTimer(&canny_cv_timer);
        canny_cv_timer = nullptr;
    }

    output_image.release();
    input_image.release();
}