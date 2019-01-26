//
//  binarytree_tests.c
//  CinyTest-Sample
//
//  Created by Brandon Stansbury on 8/25/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include <stddef.h>
#include <stdlib.h>
#include <stdbool.h>
#include "ciny.h"
#include "binarytree.h"

/////
// Setup / Teardown
/////

struct bt_testcontext {
    binarytree *tree;
};

static void setup(void *context[static 1])
{
    struct bt_testcontext * const bt_context = malloc(sizeof *bt_context);
    bt_context->tree = bt_new();
    *context = bt_context;
}

static void teardown(void *context[static 1])
{
    bt_free(((struct bt_testcontext *)*context)->tree);
    free(*context);
    *context = NULL;
}

/////
// Tests
/////

static void btnew_creates_emptytree(void *context)
{
    struct bt_testcontext * const ctx = context;
    
    const bool empty = bt_isempty(ctx->tree);
    
    ct_asserttrue(empty);
}

static void btsize_returnszero_ifemptytree(void *context)
{
    struct bt_testcontext * const ctx = context;
    
    const size_t size = bt_size(ctx->tree);
    
    ct_assertequal(0u, size);
}

static void btdepth_returnszero_ifemptytree(void *context)
{
    struct bt_testcontext * const ctx = context;
    
    const size_t depth = bt_depth(ctx->tree);
    
    ct_assertequal(0u, depth);
}

static void btinsert_insertsvalue(void *context)
{
    struct bt_testcontext * const ctx = context;
    
    bt_insert(&ctx->tree, 5);
    
    ct_assertequal(1u, bt_size(ctx->tree));
}

static void btinsert_allowszero_ifinserted(void *context)
{
    struct bt_testcontext * const ctx = context;
    
    bt_insert(&ctx->tree, 0);
    
    ct_assertequal(1u, bt_size(ctx->tree));
}

static void btinsert_createstreestructure(void *context)
{
    struct bt_testcontext * const ctx = context;
    
    bt_insert(&ctx->tree, 3);
    bt_insert(&ctx->tree, -4);
    bt_insert(&ctx->tree, 8);
    bt_insert(&ctx->tree, 10);
    bt_insert(&ctx->tree, 1);
    
    ct_assertequal(5u, bt_size(ctx->tree));
    ct_assertequal(3u, bt_depth(ctx->tree));
}

static void btinsert_insertsmultiplevalues(void *context)
{
    struct bt_testcontext * const ctx = context;
    
    bt_insert(&ctx->tree, 4);
    bt_insert(&ctx->tree, -3);
    bt_insert(&ctx->tree, 8);
    
    ct_assertequal(3u, bt_size(ctx->tree));
}

static void btcontains_returnstrue_ifvaluepresent(void *context)
{
    struct bt_testcontext * const ctx = context;
    const int expected_value = 7;
    bt_insert(&ctx->tree, expected_value);
    
    const bool contains = bt_contains(ctx->tree, expected_value);
    
    ct_asserttrue(contains);
}

static void btcontains_returnstrue_ifvalueiszero(void *context)
{
    struct bt_testcontext * const ctx = context;
    const int expected_value = 0;
    bt_insert(&ctx->tree, expected_value);
    
    const bool contains = bt_contains(ctx->tree, expected_value);
    
    ct_asserttrue(contains);
}

static void btcontains_returnstrue_ifvalue_among_othervalues(void *context)
{
    struct bt_testcontext * const ctx = context;
    const int expected_value = 7;
    bt_insert(&ctx->tree, 5);
    bt_insert(&ctx->tree, 3);
    bt_insert(&ctx->tree, 10);
    bt_insert(&ctx->tree, expected_value);
    bt_insert(&ctx->tree, 6);
    
    const bool contains = bt_contains(ctx->tree, expected_value);
    
    ct_asserttrue(contains);
}

static void btcontains_returnsfalse_ifvaluenotpresent(void *context)
{
    struct bt_testcontext * const ctx = context;
    const int expected_value = 9;
    bt_insert(&ctx->tree, 10);
    bt_insert(&ctx->tree, 4);
    
    const bool contains = bt_contains(ctx->tree, expected_value);
    
    ct_assertfalse(contains);
}

static void btcontains_returnsfalse_ifemptytree(void *context)
{
    struct bt_testcontext * const ctx = context;
    const int expected_value = 9;
    
    const bool contains = bt_contains(ctx->tree, expected_value);
    
    ct_assertfalse(contains);
}

static void btremove_doesnothing_iftreeisempty(void *context)
{
    struct bt_testcontext * const ctx = context;
    
    bt_remove(&ctx->tree, 9);
    
    ct_asserttrue(bt_isempty(ctx->tree));
}

static void btremove_removesvalue(void *context)
{
    struct bt_testcontext * const ctx = context;
    const int expected_value = 9;
    bt_insert(&ctx->tree, expected_value);
    
    bt_remove(&ctx->tree, expected_value);
    
    ct_assertfalse(bt_contains(ctx->tree, expected_value));
}

static void btremove_removesvalue_if_among_othervalues(void *context)
{
    struct bt_testcontext * const ctx = context;
    const int expected_value = 7;
    bt_insert(&ctx->tree, 5);
    bt_insert(&ctx->tree, 3);
    bt_insert(&ctx->tree, 10);
    bt_insert(&ctx->tree, expected_value);
    bt_insert(&ctx->tree, 6);
    
    bt_remove(&ctx->tree, expected_value);
    
    ct_assertfalse(bt_contains(ctx->tree, expected_value));
}

static void btremove_supportszero(void *context)
{
    struct bt_testcontext * const ctx = context;
    const int expected_value = 0;
    bt_insert(&ctx->tree, expected_value);
    
    bt_remove(&ctx->tree, expected_value);
    
    ct_assertfalse(bt_contains(ctx->tree, expected_value));
}

static void btnewwithvalues_createstree(void *context)
{
    struct bt_testcontext * const ctx = context;
    // discard the tree created in setup
    bt_free(ctx->tree);
    const int numbers[] = {1, 2, 3, 4, 5};
    const size_t count = sizeof numbers / sizeof numbers[0];
    
    ctx->tree = bt_new_withvalues(count, 1, 2, 3, 4, 5);
    
    ct_assertfalse(bt_isempty(ctx->tree));
    ct_assertequal(count, bt_size(ctx->tree));
    for (size_t i = 0; i < count; ++i) {
        ct_asserttrue(bt_contains(ctx->tree, numbers[i]));
    }
}

static void btnewwithvalues_insertsvaluesinorder(void *context)
{
    struct bt_testcontext * const ctx = context;
    // discard the tree created in setup
    bt_free(ctx->tree);
    const size_t count = 5;
    
    ctx->tree = bt_new_withvalues(count, 1, 2, 3, 4, 5);
    
    ct_assertequal(count, bt_depth(ctx->tree));
}

static void btisbalanced_istrue_ifemptytree(void *context)
{
    struct bt_testcontext * const ctx = context;
    
    const bool balanced = bt_isbalanced(ctx->tree);
    
    ct_asserttrue(balanced);
}

static void btisbalanced_istrue_ifsinglenode(void *context)
{
    struct bt_testcontext * const ctx = context;
    bt_insert(&ctx->tree, 5);
    
    const bool balanced = bt_isbalanced(ctx->tree);
    
    ct_asserttrue(balanced);
}

static void btisbalanced_istrue_if_twonodes(void *context)
{
    struct bt_testcontext * const ctx = context;
    bt_insert(&ctx->tree, 5);
    bt_insert(&ctx->tree, 7);
    
    const bool balanced = bt_isbalanced(ctx->tree);
    
    ct_asserttrue(balanced);
}

static void btisbalanced_istrue_if_twoleafnodes(void *context)
{
    struct bt_testcontext * const ctx = context;
    bt_insert(&ctx->tree, 5);
    bt_insert(&ctx->tree, 7);
    bt_insert(&ctx->tree, 3);
    
    const bool balanced = bt_isbalanced(ctx->tree);
    
    ct_asserttrue(balanced);
}

static void btisbalanced_isfalse_if_threeinlinenodes(void *context)
{
    struct bt_testcontext * const ctx = context;
    bt_insert(&ctx->tree, 5);
    bt_insert(&ctx->tree, 7);
    bt_insert(&ctx->tree, 9);
    
    const bool balanced = bt_isbalanced(ctx->tree);
    
    ct_assertfalse(balanced);
}

static void btisbalanced_istrue_if_evensubtrees(void *context)
{
    struct bt_testcontext * const ctx = context;
    bt_insert(&ctx->tree, 5);
    bt_insert(&ctx->tree, 2);
    bt_insert(&ctx->tree, 1);
    bt_insert(&ctx->tree, 3);
    bt_insert(&ctx->tree, 7);
    bt_insert(&ctx->tree, 6);
    bt_insert(&ctx->tree, 9);
    
    const bool balanced = bt_isbalanced(ctx->tree);
    
    ct_asserttrue(balanced);
}

static void btisbalanced_isfalse_ifonelayer_unevensubtrees(void *context)
{
    struct bt_testcontext * const ctx = context;
    bt_insert(&ctx->tree, 5);
    bt_insert(&ctx->tree, 2);
    bt_insert(&ctx->tree, 1);
    bt_insert(&ctx->tree, 3);
    bt_insert(&ctx->tree, 7);
    bt_insert(&ctx->tree, 6);
    bt_insert(&ctx->tree, 9);
    bt_insert(&ctx->tree, 11);
    bt_insert(&ctx->tree, 8);
    
    const bool balanced = bt_isbalanced(ctx->tree);
    
    ct_asserttrue(balanced);
}

static void btisbalanced_isfalse_if_unevensubtrees(void *context)
{
    struct bt_testcontext * const ctx = context;
    bt_insert(&ctx->tree, 5);
    bt_insert(&ctx->tree, 2);
    bt_insert(&ctx->tree, 1);
    bt_insert(&ctx->tree, 3);
    bt_insert(&ctx->tree, 7);
    bt_insert(&ctx->tree, 6);
    bt_insert(&ctx->tree, 9);
    bt_insert(&ctx->tree, 11);
    bt_insert(&ctx->tree, 8);
    bt_insert(&ctx->tree, 10);
    bt_insert(&ctx->tree, 12);
    
    const bool balanced = bt_isbalanced(ctx->tree);
    
    ct_assertfalse(balanced);
}

static void btisbalanced_isfalse_if_lopsidedunevensubtrees(void *context)
{
    struct bt_testcontext * const ctx = context;
    bt_insert(&ctx->tree, 5);
    bt_insert(&ctx->tree, 2);
    bt_insert(&ctx->tree, 3);
    bt_insert(&ctx->tree, 7);
    bt_insert(&ctx->tree, 6);
    bt_insert(&ctx->tree, 10);
    bt_insert(&ctx->tree, 9);
    bt_insert(&ctx->tree, 8);
    
    const bool balanced = bt_isbalanced(ctx->tree);
    
    ct_assertfalse(balanced);
}

static void btisbalanced_isfalse_if_forkedtree(void *context)
{
    struct bt_testcontext * const ctx = context;
    bt_insert(&ctx->tree, 5);
    bt_insert(&ctx->tree, 4);
    bt_insert(&ctx->tree, 3);
    bt_insert(&ctx->tree, 2);
    bt_insert(&ctx->tree, 6);
    bt_insert(&ctx->tree, 7);
    bt_insert(&ctx->tree, 8);
    bt_insert(&ctx->tree, 9);
    
    const bool balanced = bt_isbalanced(ctx->tree);
    
    ct_assertfalse(balanced);
}

static void btrebalance_rebalancestree(void *context)
{
    struct bt_testcontext * const ctx = context;
    // discard the tree created in setup
    bt_free(ctx->tree);
    const size_t count = 10;
    ctx->tree = bt_new_withvalues(count, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

    ct_assertequal(count, bt_depth(ctx->tree));
    ct_assertfalse(bt_isbalanced(ctx->tree));
    
    bt_rebalance(&ctx->tree);
    
    ct_assertequal(4u, bt_depth(ctx->tree));
    ct_asserttrue(bt_isbalanced(ctx->tree));
}

static void btrebalance_doesnothing_ifemptytree(void *context)
{
    struct bt_testcontext * const ctx = context;
    
    bt_rebalance(&ctx->tree);
    
    ct_asserttrue(bt_isempty(ctx->tree));
}

static void btrebalance_doesnothing_ifoneelementtree(void *context)
{
    struct bt_testcontext * const ctx = context;
    bt_insert(&ctx->tree, 12);
    
    bt_rebalance(&ctx->tree);
    
    ct_assertequal(1lu, bt_size(ctx->tree));
}

static void btprint_test(void *context)
{
    struct bt_testcontext * const ctx = context;
    bt_insert(&ctx->tree, 5);
    bt_insert(&ctx->tree, 3);
    bt_insert(&ctx->tree, 10);
    bt_insert(&ctx->tree, 6);

    bt_print(ctx->tree);

    ct_asserttrue(true, "Should not happen!");
}

size_t binarytree_tests(int argc, const char *argv[])
{
    const struct ct_testcase tests[] = {
        ct_maketest(btnew_creates_emptytree),
        ct_maketest(btsize_returnszero_ifemptytree),
        ct_maketest(btdepth_returnszero_ifemptytree),
        
        ct_maketest(btinsert_insertsvalue),
        ct_maketest(btinsert_allowszero_ifinserted),
        ct_maketest(btinsert_createstreestructure),
        ct_maketest(btinsert_insertsmultiplevalues),
        
        ct_maketest(btcontains_returnstrue_ifvaluepresent),
        ct_maketest(btcontains_returnstrue_ifvalueiszero),
        ct_maketest(btcontains_returnstrue_ifvalue_among_othervalues),
        ct_maketest(btcontains_returnsfalse_ifvaluenotpresent),
        ct_maketest(btcontains_returnsfalse_ifemptytree),
        
        ct_maketest(btremove_doesnothing_iftreeisempty),
        ct_maketest(btremove_removesvalue),
        ct_maketest(btremove_removesvalue_if_among_othervalues),
        ct_maketest(btremove_supportszero),
        
        ct_maketest(btnewwithvalues_createstree),
        ct_maketest(btnewwithvalues_insertsvaluesinorder),
        
        ct_maketest(btisbalanced_istrue_ifemptytree),
        ct_maketest(btisbalanced_istrue_ifsinglenode),
        ct_maketest(btisbalanced_istrue_if_twonodes),
        ct_maketest(btisbalanced_istrue_if_twoleafnodes),
        ct_maketest(btisbalanced_isfalse_if_threeinlinenodes),
        ct_maketest(btisbalanced_istrue_if_evensubtrees),
        ct_maketest(btisbalanced_isfalse_ifonelayer_unevensubtrees),
        ct_maketest(btisbalanced_isfalse_if_unevensubtrees),
        ct_maketest(btisbalanced_isfalse_if_lopsidedunevensubtrees),
        ct_maketest(btisbalanced_isfalse_if_forkedtree),
        
        ct_maketest(btrebalance_rebalancestree),
        ct_maketest(btrebalance_doesnothing_ifemptytree),
        ct_maketest(btrebalance_doesnothing_ifoneelementtree),

        ct_maketest(btprint_test)
    };
    const struct ct_testsuite suite = ct_makesuite_setup_teardown(tests, setup, teardown);
    
    const size_t results = ct_runsuite_withargs(&suite, argc, argv);
    
    return results;
}
