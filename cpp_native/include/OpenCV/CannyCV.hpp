#pragma once

#if defined(_WIN32) || defined(_WIN64) || defined(WIN32) || defined(WIN64)
    #include <windows.h>
#endif

#include <iostream>
#include <filesystem>
#include <opencv2/opencv.hpp>
using namespace std;

#ifndef HELPER_TIMER_H
#define HELPER_TIMER_H
    #include "../Common/helper_timer.h"
#endif

#include "../Common/Macros.hpp"

#ifndef NOMINMAX
    #define NOMINMAX
#endif

// Function Declaration
double canny_cv(string input_file, string output_file);
