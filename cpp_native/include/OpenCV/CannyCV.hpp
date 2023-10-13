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

#define THRESHOLD   40
#define RATIO       3

double canny_cv(string input_file, string output_file);
void canny_cv_cleanup(void);
