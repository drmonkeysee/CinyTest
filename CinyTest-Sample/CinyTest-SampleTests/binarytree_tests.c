//
//  binarytree_tests.c
//  CinyTest-Sample
//
//  Created by Brandon Stansbury on 8/25/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include <stdlib.h>
#include <cinytest/ciny.h>
#include "binarytree.h"

/////
// Setup / Teardown
/////

struct bt_testcontext {
    binarytree *tree;
};

static void setup(void **context)
{
    struct bt_testcontext *bt_context = malloc(sizeof *bt_context);
    bt_context->tree = bt_create();
    *context = bt_context;
}

static void teardown(void **context)
{
    bt_free(((struct bt_testcontext *)*context)->tree);
    free(*context);
}

static binarytree *gettree(void *context)
{
    return ((struct bt_testcontext *)context)->tree;
}

/////
// Tests
/////

static void btcreate_creates_emptytree(void *context)
{
    binarytree *tree = gettree(context);
    
    _Bool empty = bt_isempty(tree);
    
    ct_asserttrue(empty);
}

static void btsize_returnszero_ifemptytree(void *context)
{
    binarytree *tree = gettree(context);
    
    size_t size = bt_size(tree);
    
    ct_assertequal(0u, size);
}

static void btdepth_returnszero_ifemptytree(void *context)
{
    binarytree *tree = gettree(context);
    
    size_t depth = bt_depth(tree);
    
    ct_assertequal(0u, depth);
}

static void btinsert_doesnothing_iftreeisnull(void *context)
{
    binarytree **ref = NULL;
    
    bt_insert(ref, 4);
    
    // nothing to assert so this is merely illustrative
    ct_assertnull(ref);
}

static void btinsert_insertsvalue(void *context)
{
    binarytree *tree = gettree(context);
    
    bt_insert(&tree, 5);
    
    ct_assertequal(1u, bt_size(tree));
}

static void btinsert_allowszero_ifinserted(void *context)
{
    binarytree *tree = gettree(context);
    
    bt_insert(&tree, 0);
    
    ct_assertequal(1u, bt_size(tree));
}

static void btinsert_createstreestructure(void *context)
{
    binarytree *tree = gettree(context);
    
    bt_insert(&tree, 3);
    bt_insert(&tree, -4);
    bt_insert(&tree, 8);
    bt_insert(&tree, 10);
    bt_insert(&tree, 1);
    
    ct_assertequal(5u, bt_size(tree));
    ct_assertequal(3u, bt_depth(tree));
}

static void btinsert_insertsmultiplevalues(void *context)
{
    binarytree *tree = gettree(context);
    
    bt_insert(&tree, 4);
    bt_insert(&tree, -3);
    bt_insert(&tree, 8);
    
    ct_assertequal(3u, bt_size(tree));
}

static void btcontains_returnstrue_ifvaluepresent(void *context)
{
    binarytree *tree = gettree(context);
    int expected_value = 7;
    bt_insert(&tree, expected_value);
    
    _Bool contains = bt_contains(tree, expected_value);
    
    ct_asserttrue(contains);
}

static void btcontains_returnstrue_ifvalueiszero(void *context)
{
    binarytree *tree = gettree(context);
    int expected_value = 0;
    bt_insert(&tree, expected_value);
    
    _Bool contains = bt_contains(tree, expected_value);
    
    ct_asserttrue(contains);
}

static void btcontains_returnstrue_ifvalueamongothervalues(void *context)
{
    binarytree *tree = gettree(context);
    int expected_value = 7;
    bt_insert(&tree, 5);
    bt_insert(&tree, 3);
    bt_insert(&tree, 10);
    bt_insert(&tree, expected_value);
    bt_insert(&tree, 6);
    
    _Bool contains = bt_contains(tree, expected_value);
    
    ct_asserttrue(contains);
}

static void btcontains_returnsfalse_ifvaluenotpresent(void *context)
{
    binarytree *tree = gettree(context);
    int expected_value = 9;
    bt_insert(&tree, 10);
    bt_insert(&tree, 4);
    
    _Bool contains = bt_contains(tree, expected_value);
    
    ct_assertfalse(contains);
}

static void btcontains_returnsfalse_ifemptytree(void *context)
{
    binarytree *tree = gettree(context);
    int expected_value = 9;
    
    _Bool contains = bt_contains(tree, expected_value);
    
    ct_assertfalse(contains);
}

static void btremove_doesnothing_iftreeisnull(void *context)
{
    binarytree **ref = NULL;
    
    bt_remove(ref, 8);
    
    // nothing to assert so this is merely illustrative
    ct_assertnull(ref);
}

static void btremove_doesnothing_iftreeisempty(void *context)
{
    binarytree *tree = gettree(context);
    
    bt_remove(&tree, 9);
    
    ct_asserttrue(bt_isempty(tree));
}

static void btremove_removesvalue(void *context)
{
    binarytree *tree = gettree(context);
    int expected_value = 9;
    bt_insert(&tree, expected_value);
    
    bt_remove(&tree, expected_value);
    
    ct_assertfalse(bt_contains(tree, expected_value));
}

static void btremove_removesvalue_ifamongothervalues(void *context)
{
    binarytree *tree = gettree(context);
    int expected_value = 7;
    bt_insert(&tree, 5);
    bt_insert(&tree, 3);
    bt_insert(&tree, 10);
    bt_insert(&tree, expected_value);
    bt_insert(&tree, 6);
    
    bt_remove(&tree, expected_value);
    
    ct_assertfalse(bt_contains(tree, expected_value));
}

static void btremove_supportszero(void *context)
{
    binarytree *tree = gettree(context);
    int expected_value = 0;
    bt_insert(&tree, expected_value);
    
    bt_remove(&tree, expected_value);
    
    ct_assertfalse(bt_contains(tree, expected_value));
}

static void btcreatewithvalues_createstree(void *context)
{
    // discard the tree created in setup
    binarytree *tree = gettree(context);
    bt_free(tree);
    int numbers[] = { 1, 2, 3, 4, 5 };
    const size_t count = sizeof numbers / sizeof numbers[0];
    
    tree = bt_createwithvalues(count, 1, 2, 3, 4, 5);
    // add new tree to test context so it gets cleaned up even if test fails
    ((struct bt_testcontext *)context)->tree = tree;
    
    ct_assertfalse(bt_isempty(tree));
    ct_assertequal(count, bt_size(tree));
    for (size_t i = 0; i < count; ++i) {
        ct_asserttrue(bt_contains(tree, numbers[i]));
    }
}

static void btcreatewithvalues_insertsvaluesinorder(void *context)
{
    // discard the tree created in setup
    binarytree *tree = gettree(context);
    bt_free(tree);
    const size_t count = 5;
    
    tree = bt_createwithvalues(count, 1, 2, 3, 4, 5);
    // add new tree to test context so it gets cleaned up even if test fails
    ((struct bt_testcontext *)context)->tree = tree;
    
    ct_assertequal(count, bt_depth(tree));
}

static void btrebalance_doesnothing_iftreeisnull(void *context)
{
    binarytree **ref = NULL;
    
    bt_rebalance(ref);
    
    // nothing to assert so this is merely illustrative
    ct_assertnull(ref);
}

static void btrebalance_rebalancestree(void *context)
{
    // discard the tree created in setup
    binarytree *tree = gettree(context);
    bt_free(tree);
    const size_t count = 10;
    tree = bt_createwithvalues(count, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
    // add new tree to test context so it gets cleaned up even if test fails
    ((struct bt_testcontext *)context)->tree = tree;
    ct_assertequal(count, bt_depth(tree));
    
    bt_rebalance(&tree);
    
    ct_assertequal(4u, bt_depth(tree));
}

static void btrebalance_doesnothing_ifemptytree(void *context)
{
    binarytree *tree = gettree(context);
    
    bt_rebalance(&tree);
    
    ct_asserttrue(bt_isempty(tree));
}

static void btrebalance_doesnothing_ifoneelementtree(void *context)
{
    binarytree *tree = gettree(context);
    bt_insert(&tree, 12);
    
    bt_rebalance(&tree);
    
    ct_assertequal(1lu, bt_size(tree));
}

size_t binarytree_tests(void)
{
    struct ct_testcase tests[] = {
        ct_maketest(btcreate_creates_emptytree),
        ct_maketest(btsize_returnszero_ifemptytree),
        ct_maketest(btdepth_returnszero_ifemptytree),
        
        ct_maketest(btinsert_doesnothing_iftreeisnull),
        ct_maketest(btinsert_insertsvalue),
        ct_maketest(btinsert_allowszero_ifinserted),
        ct_maketest(btinsert_createstreestructure),
        ct_maketest(btinsert_insertsmultiplevalues),
        
        ct_maketest(btcontains_returnstrue_ifvaluepresent),
        ct_maketest(btcontains_returnstrue_ifvalueiszero),
        ct_maketest(btcontains_returnstrue_ifvalueamongothervalues),
        ct_maketest(btcontains_returnsfalse_ifvaluenotpresent),
        ct_maketest(btcontains_returnsfalse_ifemptytree),
        
        ct_maketest(btremove_doesnothing_iftreeisnull),
        ct_maketest(btremove_doesnothing_iftreeisempty),
        ct_maketest(btremove_removesvalue),
        ct_maketest(btremove_removesvalue_ifamongothervalues),
        ct_maketest(btremove_supportszero),
        
        ct_maketest(btcreatewithvalues_createstree),
        ct_maketest(btcreatewithvalues_insertsvaluesinorder),
        
        ct_maketest(btrebalance_doesnothing_iftreeisnull),
        ct_maketest(btrebalance_rebalancestree),
        ct_maketest(btrebalance_doesnothing_ifemptytree),
        ct_maketest(btrebalance_doesnothing_ifoneelementtree)
    };
    struct ct_testsuite suite = ct_makesuite_setup_teardown(tests, setup, teardown);
    
    size_t results = ct_runsuite(&suite);
    
    return results;
}
