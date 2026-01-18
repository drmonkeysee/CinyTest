//
//  main.c
//  CinyTest-Sample
//
//  Created by Brandon Stansbury on 9/12/15.
//  Copyright (c) 2015 Brandon Stansbury. All rights reserved.
//

#include <stddef.h>

size_t binarytree_tests(int, char *[]);

int main(int argc, char *argv[argc+1])
{
    auto results = binarytree_tests(argc, argv);

    return results != 0;
}
