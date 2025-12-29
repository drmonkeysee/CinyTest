//
//  main.c
//  CinyTest-Sample
//
//  Created by Brandon Stansbury on 8/24/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include "binarytree.h"

#include <stdio.h>
#include <stdlib.h>

static void tree_output(binarytree *tree)
{
    if (bt_isbalanced(tree)) {
        puts("This tree has been dewackified:");
    } else {
        puts("This tree is wack:");
    }
    bt_print(tree);
}

int main(int, char *[])
{
    auto tree = bt_new_withvalues(12, 1, 2, 3, 6, 5, 4, 10, 11, 12, 13, 14, 15);
    tree_output(tree);

    bt_rebalance(&tree);
    tree_output(tree);

    bt_free(tree);

    return EXIT_SUCCESS;
}
