//
//  CTStringAssertionTestBase.h
//  CinyTest
//
//  Created by Brandon Stansbury on 7/11/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#import "CTAssertionTestBase.h"
#include <stddef.h>

@interface CTStringAssertionTestBase : CTAssertionTestBase

@property (nonatomic, assign) char *expectedString;
@property (nonatomic, assign) char *actualString;
@property (nonatomic, assign) size_t compareCount;

@end
