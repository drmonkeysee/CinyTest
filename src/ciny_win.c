//
//  ciny_win.c
//  CinyTest
//
//  Created by Brandon Stansbury on 2/25/17.
//  Copyright © 2017 Brandon Stansbury. All rights reserved.
//

#define WIN32_LEAN_AND_MEAN

#include <io.h>
#include <Windows.h>

#include <stddef.h>
#include <stdint.h>
#include <stdio.h>

static WORD ConsoleOldAttributes;

static HANDLE streamhandle(FILE *stream)
{
    return (HANDLE)_get_osfhandle(_fileno(stream));
}

uint64_t ct_get_currentmsecs()
{
    // sys time returns 100s of nanoseconds
    static constexpr uint64_t millisecond_factor = 10000;

    FILETIME vtime;
    GetSystemTimeAsFileTime(&vtime);

    ULARGE_INTEGER ntime = {
        .LowPart = vtime.dwLowDateTime,
        .HighPart = vtime.dwHighDateTime,
    };
    return ntime.QuadPart / millisecond_factor;
}

void ct_startcolor(FILE *stream, size_t color_index)
{
    static constexpr WORD
        colors[] = {
            FOREGROUND_GREEN,
            FOREGROUND_RED,
            FOREGROUND_BLUE | FOREGROUND_GREEN,
            FOREGROUND_BLUE | FOREGROUND_RED,
        },
        clear_foreground = ~(FOREGROUND_BLUE | FOREGROUND_GREEN
                             | FOREGROUND_RED | FOREGROUND_INTENSITY);
    static constexpr size_t color_count = sizeof colors / sizeof colors[0];

    if (color_index >= color_count) return;

    fflush(stream);

    HANDLE output = streamhandle(stream);
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

    int new_stream = _dup(_fileno(stream));
    freopen("NUL", "w", stream);
    return _fdopen(new_stream, "w");
}

void ct_restorestream(FILE *to, FILE *from)
{
    if (to == from) return;

    fflush(to);
    fflush(from);
    _dup2(_fileno(from), _fileno(to));
    fclose(from);
}
