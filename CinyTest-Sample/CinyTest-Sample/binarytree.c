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
    int value;
    binarytree *left;
    binarytree *right;
};

static binarytree *create_node(int value)
{
    binarytree *new_node = malloc(sizeof *new_node);
    new_node->value = value;
    new_node->left = BT_EMPTY;
    new_node->right = BT_EMPTY;
    return new_node;
}

static binarytree **find_child_ref(binarytree *parent, int value)
{
    binarytree **child_ref = parent->value > value ? &parent->left : &parent->right;
    if (!(*child_ref) || (*child_ref)->value == value) {
        return child_ref;
    }
    return find_child_ref(*child_ref, value);
}

static binarytree *minimum_child(binarytree *tree)
{
    binarytree *minimum_child = tree;
    while (minimum_child->left) {
        minimum_child = minimum_child->left;
    }
    return minimum_child;
}

static void remove_node(binarytree *tree, int value)
{
    binarytree **node_ref = find_child_ref(tree, value);
    binarytree *node = *node_ref;
    
    if (!node) return;
    
    if (node->left && node->right) {
        binarytree *successor = minimum_child(node->right);
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

static void print_tree(binarytree *tree, int indent, char label)
{
    if (!tree) return;
    
    for (int indent_count = indent; indent_count > 0; --indent_count) printf("\t");
    printf("%c%d\n", label, tree->value);
    print_tree(tree->left, indent + 1, 'L');
    print_tree(tree->right, indent + 1, 'R');
}

static void inline_tree(binarytree *tree, binarytree *nodes[], ptrdiff_t *current_index)
{
    if (tree->left) {
        inline_tree(tree->left, nodes, current_index);
    }
    
    nodes[(*current_index)++] = tree;
    
    if (tree->right) {
        inline_tree(tree->right, nodes, current_index);
    }
}

static binarytree *rebalance_node(binarytree *node_list[], ptrdiff_t start_index, ptrdiff_t end_index)
{
    if (start_index > end_index) return BT_EMPTY;
    
    ptrdiff_t distance = end_index - start_index;
    ptrdiff_t middle_index = start_index + (distance / 2);
    binarytree *node = node_list[middle_index];
    
    node->left = rebalance_node(node_list, start_index, middle_index - 1);
    node->right = rebalance_node(node_list, middle_index + 1, end_index);
    
    return node;
}

binarytree *bt_create(void)
{
    return BT_EMPTY;
}

binarytree *bt_create_with_values(size_t count, ...)
{
    binarytree *new_tree = bt_create();
    
    va_list args;
    va_start(args, count);
    for (size_t i = 0; i < count; ++i) {
        bt_insert(&new_tree, va_arg(args, int));
    }
    va_end(args);
    
    return new_tree;
}

void bt_free(binarytree *tree)
{
    if (tree) {
        bt_free(tree->left);
        bt_free(tree->right);
    }
    free(tree);
}

bool bt_is_empty(binarytree *tree)
{
    return tree == BT_EMPTY;
}

void bt_insert(binarytree **tree_ref, int value)
{
    if (!tree_ref) return;
    
    if (!*tree_ref) {
        *tree_ref = create_node(value);
    } else if ((*tree_ref)->value > value) {
        bt_insert(&(*tree_ref)->left, value);
    } else if ((*tree_ref)->value < value) {
        bt_insert(&(*tree_ref)->right, value);
    }
}

void bt_remove(binarytree **tree_ref, int value)
{
    if (!tree_ref) return;
    
    if (!*tree_ref || (*tree_ref)->value == value) {
        bt_free(*tree_ref);
        *tree_ref = BT_EMPTY;
        return;
    }
    
    remove_node(*tree_ref, value);
}

bool bt_contains(binarytree *tree, int value)
{
    if (!tree) return false;
    
    if (tree->value == value) return true;
    
    binarytree **child_ref = find_child_ref(tree, value);
    return *child_ref;
}

void bt_rebalance(binarytree **tree_ref)
{
    if (!*tree_ref) return;
    
    size_t size = bt_size(*tree_ref);
    binarytree *sorted_nodes[size];
    
    ptrdiff_t start = 0;
    ptrdiff_t end = size - 1;
    ptrdiff_t current_index = start;
    inline_tree(*tree_ref, sorted_nodes, &current_index);
    
    *tree_ref = rebalance_node(sorted_nodes, start, end);
}

size_t bt_size(binarytree *tree)
{
    size_t size = 0;
    if (tree) {
        ++size;
        size += bt_size(tree->left);
        size += bt_size(tree->right);
    }
    return size;
}

size_t bt_depth(binarytree *tree)
{
    if (!tree) return 0;
    
    size_t left_depth = bt_depth(tree->left);
    size_t right_depth = bt_depth(tree->right);
    return (left_depth > right_depth ? left_depth : right_depth) + 1;
}

void bt_print(binarytree *tree)
{
    print_tree(tree, 0, 'T');
}
