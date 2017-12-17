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
#include <errno.h>
#include <string.h>
#include <io.h>
#include <Windows.h>

// sys time returns 100s of nanoseconds
static const uint64_t MillisecondFactor = 10000;
static WORD ConsoleOldAttributes;

static HANDLE streamhandle(FILE *stream)
{
    return (HANDLE)_get_osfhandle(_fileno(stream));
}

uint64_t ct_get_currentmsecs(void)
{
    FILETIME vtime;
    GetSystemTimeAsFileTime(&vtime);
    
    const ULARGE_INTEGER ntime = { .LowPart = vtime.dwLowDateTime, .HighPart = vtime.dwHighDateTime };
    return ntime.QuadPart / MillisecondFactor;
}

void ct_startcolor(FILE *stream, size_t color_index)
{
    static const WORD colors[] = { FOREGROUND_GREEN, FOREGROUND_RED, FOREGROUND_BLUE | FOREGROUND_GREEN, FOREGROUND_BLUE | FOREGROUND_RED },
                      clear_foreground = ~(FOREGROUND_BLUE | FOREGROUND_GREEN | FOREGROUND_RED | FOREGROUND_INTENSITY);
    static const size_t color_count = sizeof colors / sizeof colors[0];
    
    if (color_index >= color_count) return;

    fflush(stream);
    
    const HANDLE output = streamhandle(stream);
    CONSOLE_SCREEN_BUFFER_INFO info;
    GetConsoleScreenBufferInfo(output, &info);
    ConsoleOldAttributes = info.wAttributes;

    info.wAttributes &= clear_foreground;
    info.wAttributes |= colors[color_index];
    SetConsoleTextAttribute(output, info.wAttributes);
}

void ct_endcolor(FILE *stream)
{
    if (!ConsoleOldAttributes) return;

    fflush(stream);

    SetConsoleTextAttribute(streamhandle(stream), ConsoleOldAttributes);
}

FILE *ct_replacestream(FILE *stream)
{
    fflush(stream);
    
    const int new_fd = _dup(_fileno(stream));
    if (freopen("NUL", "w", stream)) {
        return _fdopen(new_fd, "w");
    } else {
        fprintf(stderr, "WARNING: unable to replace standard stream! (%d:%s)\n", errno, strerror(errno));
        return stream;
    }
}

void ct_restorestream(FILE *to, FILE *from)
{
    if (to == from) return;

    fflush(to);
    fflush(from);
    _dup2(_fileno(from), _fileno(to));
    fclose(from);
}
