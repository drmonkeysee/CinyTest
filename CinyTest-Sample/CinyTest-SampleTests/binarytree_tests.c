//
//  binarytree_tests.c
//  CinyTest-Sample
//
//  Created by Brandon Stansbury on 8/25/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include <cinytest/ciny.h>
#include "binarytree.h"

static void setup(void **context)
{
    *context = bt_create();
}

static void teardown(void **context)
{
    bt_free(*context);
}

static void btcreate_creates_emptytree(void *context)
{
    binarytree *tree = context;
    
    _Bool empty = bt_isempty(tree);
    
    ct_asserttrue(empty);
}

size_t binarytree_tests(void)
{
    struct ct_testcase tests[] = {
        ct_maketest(btcreate_creates_emptytree)
    };
    struct ct_testsuite suite = ct_makesuite_setup_teardown(tests, setup, teardown);
    
    size_t results = ct_runsuite(&suite);
    
    return results;
}
