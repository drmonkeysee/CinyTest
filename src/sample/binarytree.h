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

binarytree *bt_new(void);

binarytree *bt_new_withvalues(size_t n, ...);

void bt_free(binarytree *self);

_Bool bt_isempty(const binarytree *self);

void bt_insert(binarytree *self[static 1], int value);

void bt_remove(binarytree *self[static 1], int value);

_Bool bt_contains(const binarytree *self, int value);

_Bool bt_isbalanced(const binarytree *self);

void bt_rebalance(binarytree *self[static 1]);

size_t bt_size(const binarytree *self);

size_t bt_depth(const binarytree *self);

void bt_print(const binarytree *self);

#endif
