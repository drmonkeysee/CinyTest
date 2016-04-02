//
//  main.c
//  CinyTest-Sample
//
//  Created by Brandon Stansbury on 9/12/15.
//  Copyright (c) 2015 Brandon Stansbury. All rights reserved.
//

#include <stdlib.h>

size_t binarytree_tests(void);

int main(int argc, const char *argv[])
{
    size_t results = binarytree_tests();
    
    return results != 0;
}
