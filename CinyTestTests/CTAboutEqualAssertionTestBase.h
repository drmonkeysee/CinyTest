//
//  CTAboutEqualAssertionTestBase.h
//  CinyTest
//
//  Created by Brandon Stansbury on 7/11/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#import "CTAssertionTestBase.h"

typedef NS_ENUM(NSUInteger, TEST_ARG_TYPE) {
    TAT_FLOAT,
    TAT_DOUBLE,
    TAT_LDOUBLE
};

enum argument {
    ARG_EXPECTED,
    ARG_ACTUAL,
    ARG_PRECISION
};

#define get_test_arg(T, i) ((T) == TAT_FLOAT ? f_values[i] \
                            : (T) == TAT_DOUBLE ? d_values[i] \
                            : ld_values[i])

extern float f_values[3];
extern double d_values[3];
extern long double ld_values[3];

@interface CTAboutEqualAssertionTestBase : CTAssertionTestBase

@property (nonatomic, assign) TEST_ARG_TYPE expectedType;
@property (nonatomic, assign) TEST_ARG_TYPE actualType;
@property (nonatomic, assign) TEST_ARG_TYPE precisionType;

@end
