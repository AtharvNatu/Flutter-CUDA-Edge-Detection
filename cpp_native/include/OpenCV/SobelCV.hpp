#pragma once

#include <iostream>
#include <filesystem>
#include <opencv2/opencv.hpp>
using namespace std;

#ifndef HELPER_TIMER_H
#define HELPER_TIMER_H
    #include "../helper_timer.h"
#endif

#ifndef NOMINMAX
    #define NOMINMAX
#endif

void sobel_cv(string input_file);
void sobel_cv_cleanup(void);