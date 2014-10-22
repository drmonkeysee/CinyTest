//
//  ciny_posix.c
//  CinyTest
//
//  Created by Brandon Stansbury on 9/1/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include <stdint.h>
#include <time.h>
#include <sys/time.h>

static const uint64_t NanosecondsPerMicrosecond = 1000;
static const uint64_t MillisecondsPerSecond = 1000;
static const uint64_t NanosecondsPerMillisecond = 1000000;

// OS X has not implemented timespec_get() yet so
// use gettimeofday() for POSIX-compliant builds.
uint64_t get_currentmsecs(void)
{
    struct timeval vtime;
    gettimeofday(&vtime, NULL);
    
    // proxy through the C11 timespec type so returned value is standards compliant
    const struct timespec time = { vtime.tv_sec, vtime.tv_usec * NanosecondsPerMicrosecond };
    return (time.tv_sec * MillisecondsPerSecond) + (time.tv_nsec / NanosecondsPerMillisecond);
}