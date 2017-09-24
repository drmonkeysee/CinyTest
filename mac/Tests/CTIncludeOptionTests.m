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
    RUN_TEST_HORSE = 1 << 5
};

typedef NS_ENUM(NSUInteger, RUN_SUITE) {
    RUN_SUITE1,
    RUN_SUITE2
};

static struct ct_testsuite Suites[2];
static RUN_TEST_FLAGS Suite1Flags;
static RUN_TEST_FLAGS Suite2Flags;

static RUN_TEST_FLAGS all_tests(void)
{
    return RUN_TEST_FOOBAR | RUN_TEST_BARFOO | RUN_TEST_BORT | RUN_TEST_EXTENDED | RUN_TEST_EAST_ASIAN | RUN_TEST_HORSE;
}

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

static void test_èxtended_chærs(void *context)
{
    set_test_flag(context, RUN_TEST_EXTENDED);
}

static void test_测试(void *context)
{
    set_test_flag(context, RUN_TEST_EAST_ASIAN);
}

static void test_🐴(void *context)
{
    set_test_flag(context, RUN_TEST_HORSE);
}

static void suite1_setup(void **contextref)
{
    *contextref = (void *)RUN_SUITE1;
}

static void suite2_setup(void **contextref)
{
    *contextref = (void *)RUN_SUITE2;
}

static struct ct_testsuite make_suite(const char * restrict name, ct_setupteardown_function setup)
{
    static const struct ct_testcase tests[] = {
        ct_maketest(test_foobar),
        ct_maketest(test_barfoo),
        ct_maketest(test_bort),
        ct_maketest(test_èxtended_chærs),
        ct_maketest(test_测试),
        ct_maketest(test_🐴)
    };
    
    return ct_makesuite_setup_teardown_named(name, tests, sizeof tests / sizeof tests[0], setup, NULL);
}

@interface CTIncludeOptionTests : CTTestBase

@end

@implementation CTIncludeOptionTests

+ (void)setUp
{
    [super setUp];
    
    Suites[0] = make_suite("suite1", suite1_setup);
    Suites[1] = make_suite("suite2", suite2_setup);
}

- (void)setUp
{
    [super setUp];

    Suite1Flags = Suite2Flags = RUN_TEST_NONE;
}

- (void)test_allTestsRunIfNoFilter
{
    const char *argv[] = {};
    const int argc = 0;
    
    ct_run_withargs(Suites, sizeof Suites / sizeof Suites[0], argc, argv);
    
    XCTAssertEqual(all_tests(), Suite1Flags);
    XCTAssertEqual(all_tests(), Suite2Flags);
}

- (void)test_allTestsRunIfEmptyFilter
{
    const char *argv[] = { "--ct-include=" };
    const int argc = sizeof argv / sizeof argv[0];
    
    ct_run_withargs(Suites, sizeof Suites / sizeof Suites[0], argc, argv);
    
    XCTAssertEqual(all_tests(), Suite1Flags);
    XCTAssertEqual(all_tests(), Suite2Flags);
}

- (void)test_allTestsRunIfEmptyQuotedFilter
{
    const char *argv[] = { "--ct-include=''" };
    const int argc = sizeof argv / sizeof argv[0];
    
    ct_run_withargs(Suites, sizeof Suites / sizeof Suites[0], argc, argv);
    
    XCTAssertEqual(all_tests(), Suite1Flags);
    XCTAssertEqual(all_tests(), Suite2Flags);
}

- (void)test_allTestsRunIfEmptyDoubleQuotedFilter
{
    const char *argv[] = { "--ct-include=\"\"" };
    const int argc = sizeof argv / sizeof argv[0];
    
    ct_run_withargs(Suites, sizeof Suites / sizeof Suites[0], argc, argv);
    
    XCTAssertEqual(all_tests(), Suite1Flags);
    XCTAssertEqual(all_tests(), Suite2Flags);
}

- (void)test_allTestsRunIfWildcardFilter
{
    const char *argv[] = { "--ct-include=*" };
    const int argc = sizeof argv / sizeof argv[0];
    
    ct_run_withargs(Suites, sizeof Suites / sizeof Suites[0], argc, argv);
    
    XCTAssertEqual(all_tests(), Suite1Flags);
    XCTAssertEqual(all_tests(), Suite2Flags);
}

- (void)test_allTestsRunIfQuotedWildcardFilter
{
    const char *argv[] = { "--ct-include='*'" };
    const int argc = sizeof argv / sizeof argv[0];
    
    ct_run_withargs(Suites, sizeof Suites / sizeof Suites[0], argc, argv);
    
    XCTAssertEqual(all_tests(), Suite1Flags);
    XCTAssertEqual(all_tests(), Suite2Flags);
}

- (void)test_allTestsRunIfDoubleQuotedWildcardFilter
{
    const char *argv[] = { "--ct-include=\"*\"" };
    const int argc = sizeof argv / sizeof argv[0];
    
    ct_run_withargs(Suites, sizeof Suites / sizeof Suites[0], argc, argv);
    
    XCTAssertEqual(all_tests(), Suite1Flags);
    XCTAssertEqual(all_tests(), Suite2Flags);
}

@end
