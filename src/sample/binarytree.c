//
//  binarytree.c
//  CinyTest-Sample
//
//  Created by Brandon Stansbury on 8/24/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdbool.h>
#include "binarytree.h"

#define BT_EMPTY NULL

struct bt_node {
    struct bt_node *left, *right;
    int value;
};

static struct bt_node *create_node(int value)
{
    struct bt_node * const new_node = malloc(sizeof *new_node);
    new_node->value = value;
    new_node->left = BT_EMPTY;
    new_node->right = BT_EMPTY;
    return new_node;
}

static struct bt_node **find_childref(struct bt_node *self, int value)
{
    struct bt_node ** const child_ref = self->value > value ? &self->left : &self->right;
    if (!(*child_ref) || (*child_ref)->value == value) {
        return child_ref;
    }
    return find_childref(*child_ref, value);
}

static struct bt_node *minimum_child(struct bt_node *self)
{
    struct bt_node *minimum_child = self;
    while (minimum_child->left) {
        minimum_child = minimum_child->left;
    }
    return minimum_child;
}

static void remove_node(struct bt_node *self, int value)
{
    struct bt_node ** const node_ref = find_childref(self, value);
    struct bt_node * const node = *node_ref;
    
    if (!node) return;
    
    if (node->left && node->right) {
        struct bt_node * const successor = minimum_child(node->right);
        node->value = successor->value;
        bt_remove(&node->right, successor->value);
    } else if (node->left) {
        *node_ref = node->left;
        node->left = BT_EMPTY;
        bt_free(node);
    } else if (node->right) {
        *node_ref = node->right;
        node->right = BT_EMPTY;
        bt_free(node);
    } else {
        *node_ref = BT_EMPTY;
        bt_free(node);
    }
}

static void print_tree(const struct bt_node *self, int indent, char label)
{
    if (!self) return;
    
    for (int indent_count = indent; indent_count > 0; --indent_count) {
        printf("\t");
    }
    printf("%c(%d)\n", label, self->value);
    print_tree(self->left, indent + 1, 'L');
    print_tree(self->right, indent + 1, 'R');
}

static bool balanced_tree(const struct bt_node *self, size_t *depth)
{
    size_t ldepth = 0, rdepth = 0;
    bool lbalanced = true, rbalanced = true;
    
    if (self->left) {
        lbalanced = balanced_tree(self->left, &ldepth);
    }
    if (self->right) {
        rbalanced = balanced_tree(self->right, &rdepth);
    }
    
    *depth = (ldepth > rdepth ? ldepth : rdepth) + 1;
    const ptrdiff_t depth_diff = ldepth - rdepth;
    return lbalanced && rbalanced && depth_diff >= -1 && depth_diff <= 1;
}

static void inline_tree(struct bt_node *self, struct bt_node *nodes[], ptrdiff_t *current_index)
{
    if (self->left) {
        inline_tree(self->left, nodes, current_index);
    }
    
    nodes[(*current_index)++] = self;
    
    if (self->right) {
        inline_tree(self->right, nodes, current_index);
    }
}

static struct bt_node *rebalance_node(struct bt_node *node_list[], ptrdiff_t start_index, ptrdiff_t end_index)
{
    if (start_index > end_index) return BT_EMPTY;
    
    const ptrdiff_t distance = end_index - start_index;
    const ptrdiff_t middle_index = start_index + (distance / 2);
    struct bt_node * const node = node_list[middle_index];
    
    node->left = rebalance_node(node_list, start_index, middle_index - 1);
    node->right = rebalance_node(node_list, middle_index + 1, end_index);
    
    return node;
}

/////
// Public API Implementation
/////

binarytree *bt_new(void)
{
    return BT_EMPTY;
}

binarytree *bt_new_withvalues(size_t n, ...)
{
    struct bt_node *new_tree = bt_new();
    
    va_list args;
    va_start(args, n);
    for (size_t i = 0; i < n; ++i) {
        bt_insert(&new_tree, va_arg(args, int));
    }
    va_end(args);
    
    return new_tree;
}

void bt_free(binarytree *self)
{
    if (self) {
        bt_free(self->left);
        bt_free(self->right);
    }
    free(self);
}

bool bt_isempty(binarytree *self)
{
    return self == BT_EMPTY;
}

void bt_insert(binarytree **selfref, int value)
{
    if (!selfref) return;
    
    if (!*selfref) {
        *selfref = create_node(value);
    } else if ((*selfref)->value > value) {
        bt_insert(&(*selfref)->left, value);
    } else if ((*selfref)->value < value) {
        bt_insert(&(*selfref)->right, value);
    }
}

void bt_remove(binarytree **selfref, int value)
{
    if (!selfref || !*selfref) return;
    
    if ((*selfref)->value == value) {
        bt_free(*selfref);
        *selfref = BT_EMPTY;
        return;
    }
    
    remove_node(*selfref, value);
}

bool bt_contains(binarytree *self, int value)
{
    if (!self) return false;
    
    if (self->value == value) return true;
    
    struct bt_node * const * const child_ref = find_childref(self, value);
    return *child_ref != BT_EMPTY;
}

bool bt_isbalanced(binarytree *self)
{
    if (!self) return true;
    
    size_t depth;
    return balanced_tree(self, &depth);
}

void bt_rebalance(binarytree **selfref)
{
    if (!selfref || !*selfref) return;
    
    const size_t size = bt_size(*selfref);
    struct bt_node *sorted_nodes[size];
    
    const ptrdiff_t start = 0, end = size - 1;
    ptrdiff_t current_index = start;
    inline_tree(*selfref, sorted_nodes, &current_index);
    
    *selfref = rebalance_node(sorted_nodes, start, end);
}

size_t bt_size(binarytree *self)
{
    size_t size = 0;
    if (self) {
        ++size;
        size += bt_size(self->left);
        size += bt_size(self->right);
    }
    return size;
}

size_t bt_depth(binarytree *self)
{
    if (!self) return 0;
    
    size_t depth;
    balanced_tree(self, &depth);
    return depth;
}

void bt_print(binarytree *self)
{
    print_tree(self, 0, 'T');
}
