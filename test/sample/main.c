//
//  main.c
//  CinyTest-Sample
//
//  Created by Brandon Stansbury on 9/12/15.
//  Copyright (c) 2015 Brandon Stansbury. All rights reserved.
//

#include <stddef.h>

size_t binarytree_tests(int, const char *[]);

int main(int argc, const char *argv[static argc + 1])
{
    const size_t results = binarytree_tests(argc, argv);
    
    return results != 0;
}
