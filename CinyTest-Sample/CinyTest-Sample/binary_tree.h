//
//  binary_tree.h
//  CinyTest-Sample
//
//  Created by Brandon Stansbury on 8/24/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#ifndef CinyTest_Sample_binary_tree_h
#define CinyTest_Sample_binary_tree_h

#include <stddef.h>

typedef struct bt_node binary_tree;

binary_tree *bt_create(void);

binary_tree *bt_create_with_values(size_t, ...);

void bt_free(binary_tree *);

_Bool bt_is_empty(binary_tree *);

void bt_insert(binary_tree **, int);

void bt_remove(binary_tree **, int);

_Bool bt_contains(binary_tree *, int);

void bt_rebalance(binary_tree **);

size_t bt_size(binary_tree *);

size_t bt_depth(binary_tree *);

void bt_print(binary_tree *);

#endif
