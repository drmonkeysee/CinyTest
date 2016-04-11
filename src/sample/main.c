//
//  main.c
//  CinyTest-Sample
//
//  Created by Brandon Stansbury on 8/24/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include <stdio.h>
#include "binarytree.h"

int main(int argc, const char *argv[])
{
    binarytree *tree = bt_createwithvalues(12, 1, 2, 3, 6, 5, 4, 10, 11, 12, 13, 14, 15);
    printf("This tree is wack:\n");
    bt_print(tree);
    
    bt_rebalance(&tree);
    printf("This tree has been dewackified:\n");
    bt_print(tree);

    bt_free(tree);
    
    return 0;
}