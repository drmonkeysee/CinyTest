//
//  ciny.c
//  CinyTest
//
//  Created by Brandon Stansbury on 4/8/14.
//  Copyright (c) 2014 Monkey Bits. All rights reserved.
//

#include "ciny.h"

// call sites for inline functions
extern inline ct_testcase ct_maketest_full(const char *, ct_test_function);
extern inline ct_testsuite ct_makesuite_full(const char *, ct_testcase[], size_t, ct_setupteardown_function, ct_setupteardown_function);