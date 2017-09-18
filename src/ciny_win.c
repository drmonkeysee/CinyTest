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

static void printinfo(FILE *stream, const PCONSOLE_SCREEN_BUFFER_INFO info)
{
    fprintf(stream, "dwSize: {%d, %d}\n", info->dwSize.X, info->dwSize.Y);
    fprintf(stream, "dwCursorPosition: {%d, %d}\n", info->dwCursorPosition.X, info->dwCursorPosition.Y);
    fprintf(stream, "wAttributes: %x\n", info->wAttributes);
    fprintf(stream, "srWindow: {%d, %d, %d, %d}\n", info->srWindow.Left, info->srWindow.Top, info->srWindow.Right, info->srWindow.Bottom);
    fprintf(stream, "dwMaximumWindowSize: {%d, %d}\n", info->dwMaximumWindowSize.X, info->dwMaximumWindowSize.Y);
}

static HANDLE fdhandle(int fd)
{
    return (HANDLE)_get_osfhandle(fd);
}

static HANDLE streamhandle(FILE *stream)
{
    return fdhandle(_fileno(stream));
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
    static const WORD colors[] = { FOREGROUND_GREEN, FOREGROUND_RED, FOREGROUND_BLUE | FOREGROUND_GREEN };
    static const size_t color_count = sizeof colors / sizeof colors[0];
    static const WORD clear_foreground = ~(FOREGROUND_BLUE | FOREGROUND_GREEN | FOREGROUND_RED | FOREGROUND_INTENSITY);
    
    if (color_index >= color_count) return;
    
    const HANDLE output = streamhandle(stream);
    CONSOLE_SCREEN_BUFFER_INFO info;
    GetConsoleScreenBufferInfo(output, &info);
    ConsoleOldAttributes = info.wAttributes;

    fprintf(stream, "current stream: %p", stream);
    printinfo(stream, &info);
    
    info.wAttributes &= clear_foreground;
    info.wAttributes |= colors[color_index];
    SetConsoleTextAttribute(output, info.wAttributes);

    GetConsoleScreenBufferInfo(output, &info);
    fprintf(stream, "Updated info:\n");
    printinfo(stream, &info);
}

void ct_endcolor(FILE *stream)
{
    const HANDLE output = streamhandle(stream);
    
    if (ConsoleOldAttributes) {
        SetConsoleTextAttribute(output, ConsoleOldAttributes);
    }
}

FILE *ct_replacestream(FILE *stream)
{
    const int new_stream = _dup(_fileno(stream));
    fflush(stream);

    CONSOLE_SCREEN_BUFFER_INFO info;
    const HANDLE handle = streamhandle(stream);
    GetConsoleScreenBufferInfo(handle, &info);
    printf("Old Info:\n");
    printinfo(stream, &info);

    const HANDLE new_handle = fdhandle(new_stream);
    CONSOLE_SCREEN_BUFFER_INFO new_info;
    if (GetConsoleScreenBufferInfo(new_handle, &new_info)) {
        printf("New Info:\n");
        printinfo(stream, &new_info);
    } else {
        printf("New info error: %lx\n", GetLastError());
    }
    printf("new stream: %p", stream);
    //SetConsoleTextAttribute(new_handle info.wAttributes);

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
