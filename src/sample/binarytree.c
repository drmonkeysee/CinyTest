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
    struct bt_node *left;
    struct bt_node *right;
    int value;
};

static struct bt_node *make_node(int value)
{
    struct bt_node *new_node = malloc(sizeof *new_node);
    new_node->value = value;
    new_node->left = BT_EMPTY;
    new_node->right = BT_EMPTY;
    return new_node;
}

static struct bt_node **find_childref(struct bt_node *parent, int value)
{
    struct bt_node **child_ref = parent->value > value ? &parent->left : &parent->right;
    if (!(*child_ref) || (*child_ref)->value == value) {
        return child_ref;
    }
    return find_childref(*child_ref, value);
}

static struct bt_node *minimum_child(struct bt_node *tree)
{
    struct bt_node *minimum_child = tree;
    while (minimum_child->left) {
        minimum_child = minimum_child->left;
    }
    return minimum_child;
}

static void remove_node(struct bt_node *tree, int value)
{
    struct bt_node **node_ref = find_childref(tree, value);
    struct bt_node *node = *node_ref;
    
    if (!node) return;
    
    if (node->left && node->right) {
        struct bt_node *successor = minimum_child(node->right);
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

static void print_tree(struct bt_node *tree, int indent, char label)
{
    if (!tree) return;
    
    for (int indent_count = indent; indent_count > 0; --indent_count) {
        printf("\t");
    }
    printf("%c(%d)\n", label, tree->value);
    print_tree(tree->left, indent + 1, 'L');
    print_tree(tree->right, indent + 1, 'R');
}

static void inline_tree(struct bt_node *tree, struct bt_node *nodes[], ptrdiff_t *current_index)
{
    if (tree->left) {
        inline_tree(tree->left, nodes, current_index);
    }
    
    nodes[(*current_index)++] = tree;
    
    if (tree->right) {
        inline_tree(tree->right, nodes, current_index);
    }
}

static struct bt_node *rebalance_node(struct bt_node *node_list[], ptrdiff_t start_index, ptrdiff_t end_index)
{
    if (start_index > end_index) return BT_EMPTY;
    
    ptrdiff_t distance = end_index - start_index;
    ptrdiff_t middle_index = start_index + (distance / 2);
    struct bt_node *node = node_list[middle_index];
    
    node->left = rebalance_node(node_list, start_index, middle_index - 1);
    node->right = rebalance_node(node_list, middle_index + 1, end_index);
    
    return node;
}

/////
// Public API Implementation
/////

binarytree *bt_create(void)
{
    return BT_EMPTY;
}

binarytree *bt_createwithvalues(size_t n, ...)
{
    struct bt_node *new_tree = bt_create();
    
    va_list args;
    va_start(args, n);
    for (size_t i = 0; i < n; ++i) {
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

bool bt_isempty(binarytree *tree)
{
    return tree == BT_EMPTY;
}

void bt_insert(binarytree **treeref, int value)
{
    if (!treeref) return;
    
    if (!*treeref) {
        *treeref = make_node(value);
    } else if ((*treeref)->value > value) {
        bt_insert(&(*treeref)->left, value);
    } else if ((*treeref)->value < value) {
        bt_insert(&(*treeref)->right, value);
    }
}

void bt_remove(binarytree **treeref, int value)
{
    if (!treeref || !*treeref) return;
    
    if ((*treeref)->value == value) {
        bt_free(*treeref);
        *treeref = BT_EMPTY;
        return;
    }
    
    remove_node(*treeref, value);
}

bool bt_contains(binarytree *tree, int value)
{
    if (!tree) return false;
    
    if (tree->value == value) return true;
    
    struct bt_node **child_ref = find_childref(tree, value);
    return *child_ref != BT_EMPTY;
}

void bt_rebalance(binarytree **treeref)
{
    if (!treeref || !*treeref) return;
    
    size_t size = bt_size(*treeref);
    struct bt_node *sorted_nodes[size];
    
    ptrdiff_t start = 0;
    ptrdiff_t end = size - 1;
    ptrdiff_t current_index = start;
    inline_tree(*treeref, sorted_nodes, &current_index);
    
    *treeref = rebalance_node(sorted_nodes, start, end);
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