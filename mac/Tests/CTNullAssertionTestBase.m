//
//  CTNullAssertionTestBase.m
//  CinyTest
//
//  Created by Brandon Stansbury on 7/11/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#import "CTNullAssertionTestBase.h"

#include <stddef.h>

void *generate_pointer(bool real_pointer)
{
    return real_pointer ? TestClass : NULL;
}

@implementation CTNullAssertionTestBase

- (void)tearDown
{
    self.testVariable = NULL;
    
    [super tearDown];
}

@end
