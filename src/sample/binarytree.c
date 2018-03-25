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

struct bt_node {
    struct bt_node *left, *right;
    int value;
};
static struct bt_node * const EmptyTree = NULL;

static struct bt_node *create_node(int value)
{
    struct bt_node * const new_node = malloc(sizeof *new_node);
    new_node->value = value;
    new_node->left = new_node->right = EmptyTree;
    return new_node;
}

static struct bt_node **find_childref(struct bt_node *self, int value)
{
    struct bt_node ** const child_ref = self->value > value ? &self->left : &self->right;
    
    if (!(*child_ref) || (*child_ref)->value == value) return child_ref;
    
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
    struct bt_node ** const node_ref = find_childref(self, value),
                    * const node = *node_ref;
    
    if (!node) return;
    
    if (node->left && node->right) {
        struct bt_node * const successor = minimum_child(node->right);
        node->value = successor->value;
        bt_remove(&node->right, successor->value);
    } else if (node->left) {
        *node_ref = node->left;
        node->left = EmptyTree;
        bt_free(node);
    } else if (node->right) {
        *node_ref = node->right;
        node->right = EmptyTree;
        bt_free(node);
    } else {
        *node_ref = EmptyTree;
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
    if (start_index > end_index) return EmptyTree;
    
    const ptrdiff_t distance = end_index - start_index,
                    middle_index = start_index + (distance / 2);
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
    return EmptyTree;
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

bool bt_isempty(const binarytree *self)
{
    return self == EmptyTree;
}

void bt_insert(binarytree **self_ref, int value)
{
    if (!self_ref) return;
    
    if (!(*self_ref)) {
        *self_ref = create_node(value);
    } else if ((*self_ref)->value > value) {
        bt_insert(&(*self_ref)->left, value);
    } else if ((*self_ref)->value < value) {
        bt_insert(&(*self_ref)->right, value);
    }
}

void bt_remove(binarytree **self_ref, int value)
{
    if (!self_ref || !(*self_ref)) return;
    
    if ((*self_ref)->value == value) {
        bt_free(*self_ref);
        *self_ref = EmptyTree;
        return;
    }
    
    remove_node(*self_ref, value);
}

bool bt_contains(const binarytree *self, int value)
{
    if (!self) return false;
    
    if (self->value == value) return true;
    
    // find_childref does not change self so cast-away const is safe
    struct bt_node ** const child_ref = find_childref((binarytree *)self, value);
    return *child_ref != EmptyTree;
}

bool bt_isbalanced(const binarytree *self)
{
    if (!self) return true;
    
    size_t depth;
    return balanced_tree(self, &depth);
}

void bt_rebalance(binarytree **self_ref)
{
    if (!self_ref || !(*self_ref)) return;
    
    const size_t size = bt_size(*self_ref);
    struct bt_node *sorted_nodes[size];
    
    const ptrdiff_t start = 0, end = size - 1;
    ptrdiff_t current_index = start;
    inline_tree(*self_ref, sorted_nodes, &current_index);
    
    *self_ref = rebalance_node(sorted_nodes, start, end);
}

size_t bt_size(const binarytree *self)
{
    size_t size = 0;
    if (self) {
        ++size;
        size += bt_size(self->left);
        size += bt_size(self->right);
    }
    return size;
}

size_t bt_depth(const binarytree *self)
{
    if (!self) return 0;
    
    size_t depth;
    balanced_tree(self, &depth);
    return depth;
}

void bt_print(const binarytree *self)
{
    print_tree(self, 0, 'T');
}
