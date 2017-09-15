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
#include <stdio.h>
#include <io.h>
#include <Windows.h>

// sys time returns 100s of nanoseconds
static const uint64_t MillisecondFactor = 10000;
static WORD ConsoleOldAttributes;

uint64_t ct_get_currentmsecs(void)
{
    FILETIME vtime;
    GetSystemTimeAsFileTime(&vtime);
    
    const ULARGE_INTEGER ntime = { .LowPart = vtime.dwLowDateTime, .HighPart = vtime.dwHighDateTime };
    return ntime.QuadPart / MillisecondFactor;
}

void ct_startcolor(FILE *stream, size_t color_index)
{
    static const WORD colors[] = { FOREGROUND_GREEN, FOREGROUND_RED, FOREGROUND_BLUE | FOREGROUND_GREEN };
    static const size_t color_count = sizeof colors / sizeof colors[0];
    static const WORD clear_foreground = ~(FOREGROUND_BLUE | FOREGROUND_GREEN | FOREGROUND_RED | FOREGROUND_INTENSITY);
    
    if (color_index >= color_count) return;
    
    const HANDLE output = _get_osfhandle(_fileno(stream));
    CONSOLE_SCREEN_BUFFER_INFO info;
    GetConsoleScreenBufferInfo(output, &info);
    ConsoleOldAttributes = info.wAttributes;
    
    info.wAttributes &= clear_foreground;
    info.wAttributes |= colors[color_index];
    SetConsoleTextAttribute(output, info.wAttributes);
}

void ct_endcolor(FILE *stream)
{
    const HANDLE output = _get_osfhandle(_fileno(stream));
    
    if (ConsoleOldAttributes) {
        SetConsoleTextAttribute(output, ConsoleOldAttributes);
    }
}

FILE *ct_replacestream(FILE *stream)
{
    return stream;
}

void ct_restorestream(FILE *to, FILE *from)
{
    if (to == from) return;
}
