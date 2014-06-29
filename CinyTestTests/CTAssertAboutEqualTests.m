//
//  CTAssertAboutEqualTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 6/28/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include "ciny.h"

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

@interface CTAssertAboutEqualTests : XCTestCase

@property (nonatomic, assign) BOOL invokedTest;
@property (nonatomic, assign) BOOL sawPostAssertCode;
@property (nonatomic, assign) TEST_ARG_TYPE expectedType;
@property (nonatomic, assign) TEST_ARG_TYPE actualType;
@property (nonatomic, assign) TEST_ARG_TYPE precisionType;

@end

static void *TestClass;

#define get_test_arg(T, i) ((T) == TAT_FLOAT ? f_values[i] \
                                    : (T) == TAT_DOUBLE ? d_values[i] \
                                    : ld_values[i])

static float f_values[3];
static double d_values[3];
static long double ld_values[3];

static void about_equality_test(void *context)
{
    CTAssertAboutEqualTests *testObject = (__bridge CTAssertAboutEqualTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertaboutequal(get_test_arg(testObject.expectedType, ARG_EXPECTED), get_test_arg(testObject.actualType, ARG_ACTUAL), get_test_arg(testObject.precisionType, ARG_PRECISION));
    
    testObject.sawPostAssertCode = YES;
}

@implementation CTAssertAboutEqualTests

- (void)setUp
{
    [super setUp];
    
    TestClass = (__bridge void *)(self);
}

- (void)tearDown
{
    TestClass = NULL;
    
    [super tearDown];
}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
