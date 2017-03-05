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
static WORD PrevAttributes;

uint64_t ct_get_currentmsecs(void)
{
    FILETIME vtime;
    GetSystemTimeAsFileTime(&vtime);
    
    ULARGE_INTEGER ntime = { .LowPart = vtime.dwLowDateTime, .HighPart = vtime.dwHighDateTime };
    return ntime.QuadPart / MillisecondFactor;
}

void ct_startcolor(size_t color_index)
{
    static const WORD colors[] = { FOREGROUND_GREEN, FOREGROUND_RED, FOREGROUND_BLUE | FOREGROUND_GREEN };
    static const size_t color_count = sizeof colors / sizeof colors[0];
    
    const HANDLE output = GetStdHandle(STD_OUTPUT_HANDLE);
    CONSOLE_SCREEN_BUFFER_INFO info;
    GetConsoleScreenBufferInfo(output, &info);
    PrevAttributes = info.wAttributes;
    
    if (color_index < color_count) {
        SetConsoleTextAttribute(output, colors[color_index]);
    }
}

void ct_endcolor(void)
{
    const HANDLE output = GetStdHandle(STD_OUTPUT_HANDLE);
    
    if (PrevAttributes) {
        SetConsoleTextAttribute(output, PrevAttributes);
    }
}
