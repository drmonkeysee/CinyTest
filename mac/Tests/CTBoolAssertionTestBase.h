//
//  CTBoolAssertionTestBase.h
//  CinyTest
//
//  Created by Brandon Stansbury on 7/11/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#import "CTAssertionTestBase.h"

#include <stdbool.h>

@interface CTBoolAssertionTestBase : CTAssertionTestBase

@property (nonatomic, assign) bool testVariable;
@property (nonatomic, assign) NSInteger gtExpressionLhs;
@property (nonatomic, assign) NSInteger gtExpressionRhs;

@end
