//
//  CTIncludeOptionTests.m
//  Tests
//
//  Created by Brandon Stansbury on 9/21/17.
//  Copyright © 2017 Brandon Stansbury. All rights reserved.
//

#import "CTTestBase.h"
#include <stddef.h>
#include "ciny.h"

typedef NS_ENUM(NSUInteger, RUN_TEST_FLAGS) {
    RUN_TEST_NONE = 0,
    RUN_TEST_FOOBAR = 1 << 0,
    RUN_TEST_BARFOO = 1 << 1,
    RUN_TEST_BORT = 1 << 2,
    RUN_TEST_EXTENDED = 1 << 3,
    RUN_TEST_EAST_ASIAN = 1 << 4,
    RUN_TEST_HORSE = 1 << 5,
    RUN_SUITE1 = 1 << 6,
    RUN_SUITE2 = 1 << 7
};

static void test_foobar(void *context)
{

}

static void test_barfoo(void *context)
{

}

static void test_bort(void *context)
{

}

static void test_èxtended_chærs(void *context)
{

}

static void test_测试(void *context)
{

}

static void test_🐴(void *context)
{

}

static void suite1_setup(void **contextref)
{

}

static void suite2_setup(void **contextref)
{

}

static void *TestClass;

@interface CTIncludeOptionTests : CTTestBase

@property (atomic, assign) RUN_TEST_FLAGS runFlags;

@end

@implementation CTIncludeOptionTests

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

@end
