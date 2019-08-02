//
//  CTTestBase.m
//  CinyTest
//
//  Created by Brandon Stansbury on 1/7/17.
//  Copyright © 2017 Brandon Stansbury. All rights reserved.
//

#import "CTTestBase.h"

#include <stdlib.h>

@implementation CTTestBase

- (void)setUp
{
    [super setUp];
    
    setenv("CINYTEST_COLORIZED", "NO", 1);
}

- (void)tearDown
{
    unsetenv("CINYTEST_COLORIZED");
    
    [super tearDown];
}

@end
