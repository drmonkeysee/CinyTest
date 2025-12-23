//
//  CTNullAssertionTestBase.m
//  CinyTest
//
//  Created by Brandon Stansbury on 7/11/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#import "CTNullAssertionTestBase.h"

void *generate_pointer(bool real_pointer)
{
    return real_pointer ? TestClass : nullptr;
}

@implementation CTNullAssertionTestBase

- (void)tearDown
{
    self.testVariable = nullptr;
    
    [super tearDown];
}

@end
