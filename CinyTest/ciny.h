//
//  ciny.h
//  CinyTest
//
//  Created by Brandon Stansbury on 4/8/14.
//  Copyright (c) 2014 Monkey Bits. All rights reserved.
//

#ifndef CinyTest_ciny_h
#define CinyTest_ciny_h

/**
 Type definition for a unit test function.
 @param context Test context created in a suite's setup function.
 */
typedef void (*ct_test_function)(void *);

/**
 Type definition for a unit test setup or teardown function.
 @param context Pointer to a test context for initialization or destruction.
 The test context will be passed to all unit tests for a given suite.
 */
typedef void (*ct_setupteardown_function)(void **);

/**
 A unit test structure used internally by CinyTest.
 */
typedef struct {
    const char * const name;        /**< The function name of the test. */
    const ct_test_function test;    /**< The test function. */
} ct_unittest;

/**
 Create a unit test structure out of a unit test function pointer.
 @param test_function The unit test function pointer from which to create the unit test.
 @return A unit test structure.
 */
#define ct_maketest(test_function) ((ct_unittest){ #test_function, test_function })

#include <stdlib.h>

void atest(void *);

int testblock(void)
{
    ct_unittest foo = ct_maketest(atest);
    foo.test(NULL);
    ct_unittest butts;
    butts = ct_maketest(atest);
    butts.test(NULL);
    
    return 0;
}

#endif
