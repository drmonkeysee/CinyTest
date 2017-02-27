//
//  ciny_win.c
//  CinyTest
//
//  Created by Brandon Stansbury on 2/25/17.
//  Copyright © 2017 Brandon Stansbury. All rights reserved.
//

#define WIN32_LEAN_AND_MEAN
#include <stdint.h>
#include <Windows.h>

// TODO: print colors properly
// TODO: print non-unicode for nt shell friendly output

static const uint64_t MillisecondFactor = 10000;

uint64_t ct_get_currentmsecs(void)
{
    LPFILETIME vtime;
    GetSystemTimeAsFileTime(&vtime);
    
    ULARGE_INTEGER ntime = { .LowPart = vtime.dwLowDateTime, .HighPart = vtime.dwHighDateTime };
    
    return ntime.QuadPart / MillisecondFactor;
}
