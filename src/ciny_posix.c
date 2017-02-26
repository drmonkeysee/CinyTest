//
//  ciny_posix.c
//  CinyTest
//
//  Created by Brandon Stansbury on 9/1/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include <stdint.h>
#include <stddef.h>
#include <sys/time.h>

static const uint64_t MillisecondFactor = 1000;

// macOS has not implemented timespec_get() so
// use gettimeofday() for POSIX-compliant builds.
uint64_t ct_get_currentmsecs(void)
{
    struct timeval vtime;
    gettimeofday(&vtime, NULL);
    
    return (vtime.tv_sec * MillisecondFactor) + (vtime.tv_usec / MillisecondFactor);
}
