//
//  binarytree.h
//  CinyTest-Sample
//
//  Created by Brandon Stansbury on 8/24/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#ifndef CinyTest_Sample_binarytree_h
#define CinyTest_Sample_binarytree_h

#include <stddef.h>

/////
// A simple binary search tree for storing integers.
/////

typedef struct bt_node binarytree;

binarytree *bt_create(void);

binarytree *bt_createwithvalues(size_t n, ...);

void bt_free(binarytree *self);

_Bool bt_isempty(binarytree *self);

void bt_insert(binarytree **treeref, int value);

void bt_remove(binarytree **treeref, int value);

_Bool bt_contains(binarytree *self, int value);

void bt_rebalance(binarytree **treeref);

size_t bt_size(binarytree *self);

size_t bt_depth(binarytree *self);

void bt_print(binarytree *self);

#endif
