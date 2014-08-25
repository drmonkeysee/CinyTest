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

typedef struct bt_node binarytree;

binarytree *bt_create(void);

binarytree *bt_create_with_values(size_t, ...);

void bt_free(binarytree *);

_Bool bt_is_empty(binarytree *);

void bt_insert(binarytree **, int);

void bt_remove(binarytree **, int);

_Bool bt_contains(binarytree *, int);

void bt_rebalance(binarytree **);

size_t bt_size(binarytree *);

size_t bt_depth(binarytree *);

void bt_print(binarytree *);

#endif
