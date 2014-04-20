//
//  ciny.c
//  CinyTest
//
//  Created by Brandon Stansbury on 4/8/14.
//  Copyright (c) 2014 Monkey Bits. All rights reserved.
//

#include "ciny.h"

extern inline ct_testcase ct_maketest_withname(const char *, ct_test_function);

struct ct_testsuite {
    const char * const name;
    const ct_testcase * const tests;
    const size_t testcount;
    const ct_setupteardown_function setup;
    const ct_setupteardown_function teardown;
};
