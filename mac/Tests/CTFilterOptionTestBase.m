//
//  CTFilterOptionTestBase.m
//  Tests
//
//  Created by Brandon Stansbury on 12/2/17.
//  Copyright © 2017 Brandon Stansbury. All rights reserved.
//

#import "CTFilterOptionTestBase.h"

#include "ciny.h"

#include <stddef.h>
#include <stdlib.h>

enum {
    RUN_SUITE1,
    RUN_SUITE2
};

static struct ct_testsuite Suites[2];
static RUN_TEST_FLAGS Suite1Flags, Suite2Flags;

static void set_test_flag(const void *ctx, RUN_TEST_FLAGS flag)
{
    RUN_TEST_FLAGS * const testvar = (RUN_TEST_FLAGS)ctx == RUN_SUITE2 ? &Suite2Flags : &Suite1Flags;
    *testvar |= flag;
}

static void test_foobar(void *context)
{
    set_test_flag(context, RUN_TEST_FOOBAR);
}

static void test_barfoo(void *context)
{
    set_test_flag(context, RUN_TEST_BARFOO);
}

static void test_bort(void *context)
{
    set_test_flag(context, RUN_TEST_BORT);
}

static void test_bart(void *context)
{
    set_test_flag(context, RUN_TEST_BART);
}

static void test_Bart(void *context)
{
    set_test_flag(context, RUN_TEST_TITLE_BART);
}

static void test_ebert(void *context)
{
    set_test_flag(context, RUN_TEST_EBERT);
}

static void test_ededeedtedered(void *context)
{
    set_test_flag(context, RUN_TEST_REPETITIVE);
}

static void test_èxtended_chærs(void *context)
{
    set_test_flag(context, RUN_TEST_EXTENDED);
}

static void test_测试漢(void *context)
{
    set_test_flag(context, RUN_TEST_EAST_ASIAN);
}

static void test_🐴🐎(void *context)
{
    set_test_flag(context, RUN_TEST_HORSE);
}

static void suite1_setup(void *context[static 1])
{
    *context = (void *)RUN_SUITE1;
}

static void suite2_setup(void *context[static 1])
{
    *context = (void *)RUN_SUITE2;
}

static struct ct_testsuite make_suite(const char *name, ct_setupteardown_function *setup)
{
    static const struct ct_testcase tests[] = {
        ct_maketest(test_foobar),
        ct_maketest(test_barfoo),
        ct_maketest(test_bort),
        ct_maketest(test_bart),
        ct_maketest(test_Bart),
        ct_maketest(test_ebert),
        ct_maketest(test_ededeedtedered),
        ct_maketest(test_èxtended_chærs),
        ct_maketest(test_测试漢),
        ct_maketest(test_🐴🐎)
    };
    
    return ct_makesuite_setup_teardown_named(name, tests, sizeof tests / sizeof tests[0], setup, NULL);
}

@implementation CTFilterOptionTestBase

+ (void)setUp
{
    [super setUp];
    
    Suites[0] = make_suite("suite_far", suite1_setup);
    Suites[1] = make_suite("suite_bar", suite2_setup);
}

- (void)setUp
{
    [super setUp];
    
    unsetenv(self.envProperty.UTF8String);
}

- (void)tearDown
{
    unsetenv(self.envProperty.UTF8String);
    
    [super tearDown];
}

- (void)assertFilters:(NSArray *)filters suite1Expected:(RUN_TEST_FLAGS)suite1Expected suite2Expected:(RUN_TEST_FLAGS)suite2Expected
{
    Suite1Flags = Suite2Flags = RUN_TEST_NONE;
    
    const int argc = (int)filters.count;
    const char *argv[argc];
    for (int i = 0; i < argc; ++i) {
        argv[i] = [filters[i] UTF8String];
    }
    
    ct_run_withargs(Suites, argc, argv);
    
    XCTAssertEqual(suite1Expected, Suite1Flags);
    XCTAssertEqual(suite2Expected, Suite2Flags);
}

@end
