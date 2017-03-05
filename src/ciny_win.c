//
//  ciny_win.c
//  CinyTest
//
//  Created by Brandon Stansbury on 2/25/17.
//  Copyright © 2017 Brandon Stansbury. All rights reserved.
//

#define WIN32_LEAN_AND_MEAN
#include <stdint.h>
#include <stddef.h>
#include <Windows.h>

// sys time returns 100s of nanoseconds
static const uint64_t MillisecondFactor = 10000;

uint64_t ct_get_currentmsecs(void)
{
    FILETIME vtime;
    GetSystemTimeAsFileTime(&vtime);
    
    ULARGE_INTEGER ntime = { .LowPart = vtime.dwLowDateTime, .HighPart = vtime.dwHighDateTime };
    return ntime.QuadPart / MillisecondFactor;
}

void ct_startcolor(size_t color_index)
{
    HANDLE stdout = GetStdHandle(STD_OUTPUT_HANDLE);
    
    SetConsoleTextAttribute(&stdout, FOREGROUND_RED);
}

void ct_endcolor(void)
{
    HANDLE stdout = GetStdHandle(STD_OUTPUT_HANDLE);
    
    if (!SetConsoleTextAttribute(&stdout, 0)) {
        printf("uh oh failed: %d", GetLastError());
    }
}
