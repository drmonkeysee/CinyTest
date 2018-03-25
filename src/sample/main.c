//
//  main.c
//  CinyTest-Sample
//
//  Created by Brandon Stansbury on 8/24/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include "binarytree.h"

static void tree_output(const binarytree *tree)
{
    if (bt_isbalanced(tree)) {
        printf("This tree has been dewackified:\n");
    } else {
        printf("This tree is wack:\n");
    }
    bt_print(tree);
}

int main(int argc, const char *argv[])
{
    (void)argc, (void)argv;

    binarytree *tree = bt_new_withvalues(12, 1, 2, 3, 6, 5, 4, 10, 11, 12, 13, 14, 15);
    tree_output(tree);
    
    bt_rebalance(&tree);
    tree_output(tree);

    bt_free(tree);
    tree = NULL;
    
    return EXIT_SUCCESS;
}
