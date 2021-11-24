//
//  ciny_posix.c
//  CinyTest
//
//  Created by Brandon Stansbury on 9/1/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include <unistd.h>

#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <time.h>

#define RED "\033[0;31m"
#define GREEN "\033[0;32m"
#define CYAN "\033[0;36m"
#define MAGENTA "\033[0;35m"
static const uint64_t
    MillisecondsPerSecond = 1000,
    NanosecondsPerMillisecond = 1e6;

uint64_t ct_get_currentmsecs(void)
{
    struct timespec vtime;
    clock_gettime(CLOCK_REALTIME, &vtime);

    return (vtime.tv_sec * MillisecondsPerSecond)
            + (vtime.tv_nsec / NanosecondsPerMillisecond);
}

void ct_startcolor(FILE *stream, size_t color_index)
{
    static const char *const colors[] = {GREEN, RED, CYAN, MAGENTA};
    static const size_t color_count = sizeof colors / sizeof colors[0];

    if (color_index < color_count) {
        fprintf(stream, "%s", colors[color_index]);
    }
}

void ct_endcolor(FILE *stream)
{
    fputs("\033[0m", stream);
}

FILE *ct_replacestream(FILE *stream)
{
    fflush(stream);

    const int new_stream = dup(fileno(stream));
    freopen("/dev/null", "w", stream);
    return fdopen(new_stream, "w");
}

void ct_restorestream(FILE *to, FILE *from)
{
    if (to == from) return;

    fflush(to);
    fflush(from);
    dup2(fileno(from), fileno(to));
    fclose(from);
}
