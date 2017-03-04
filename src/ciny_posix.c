//
//  ciny_posix.c
//  CinyTest
//
//  Created by Brandon Stansbury on 9/1/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <sys/time.h>

#define RED "\033[0;31m"
#define GREEN "\033[0;32m"
#define CYAN "\033[0;36m"
static const uint64_t MillisecondFactor = 1000;

// macOS has not implemented timespec_get() so
// use gettimeofday() for POSIX-compliant builds.
uint64_t ct_get_currentmsecs(void)
{
    struct timeval vtime;
    gettimeofday(&vtime, NULL);
    
    return (vtime.tv_sec * MillisecondFactor) + (vtime.tv_usec / MillisecondFactor);
}

void ct_startcolor(size_t color_index)
{
    static const char * const restrict colors[] = { GREEN, RED, CYAN };
    static const size_t color_count = sizeof colors / sizeof colors[0];
    
    if (color_index < color_count) {
        printf("%s", colors[color_index]);
    }
}

void ct_endcolor(void)
{
    printf("\033[0m");
}
