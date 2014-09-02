//
//  ciny_posix.c
//  CinyTest
//
//  Created by Brandon Stansbury on 9/1/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include <time.h>
#include <sys/time.h>

static const long NanosecondsPerMicrosecond = 1000;
static const long NanosecondsPerMillisecond = 1000000;

// OS X has not implemented timespec_get() yet so
// use gettimeofday() for POSIX-compliant builds.
long get_currentmsecs(void)
{
    struct timeval vtime;
    if (gettimeofday(&vtime, NULL) != 0) {
        return 0;
    }
    
    // proxy through the C11 timespec type so returned value is standards compliant
    struct timespec time = { vtime.tv_sec, vtime.tv_usec * NanosecondsPerMicrosecond };
    return time.tv_nsec / NanosecondsPerMillisecond;
}