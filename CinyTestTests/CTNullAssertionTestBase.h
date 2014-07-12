//
//  CTNullAssertionTestBase.h
//  CinyTest
//
//  Created by Brandon Stansbury on 7/11/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#import "CTAssertionTestBase.h"
#include <stdbool.h>

void *generate_pointer(bool real_pointer);

@interface CTNullAssertionTestBase : CTAssertionTestBase

@property (nonatomic, assign) void *testVariable;
@property (nonatomic, assign) bool useRealPointer;

@end
