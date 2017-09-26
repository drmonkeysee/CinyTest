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
    RUN_TEST_BART = 1 << 3,
    RUN_TEST_EXTENDED = 1 << 4,
    RUN_TEST_EAST_ASIAN = 1 << 5,
    RUN_TEST_HORSE = 1 << 6
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
    return RUN_TEST_FOOBAR | RUN_TEST_BARFOO | RUN_TEST_BORT | RUN_TEST_BART | RUN_TEST_EXTENDED | RUN_TEST_EAST_ASIAN | RUN_TEST_HORSE;
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

static void test_bart(void *context)
{
    set_test_flag(context, RUN_TEST_BART);
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
        ct_maketest(test_bart),
        ct_maketest(test_èxtended_chærs),
        ct_maketest(test_测试漢),
        ct_maketest(test_🐴🐎)
    };
    
    return ct_makesuite_setup_teardown_named(name, tests, sizeof tests / sizeof tests[0], setup, NULL);
}

@interface CTIncludeOptionTests : CTTestBase

@end

@implementation CTIncludeOptionTests

+ (void)setUp
{
    [super setUp];
    
    Suites[0] = make_suite("suite_foo", suite1_setup);
    Suites[1] = make_suite("suite_bar", suite2_setup);
}

- (void)setUp
{
    [super setUp];

    Suite1Flags = Suite2Flags = RUN_TEST_NONE;
}

- (void)test_allTestsRunIfNoFilter
{
    [self assertFilters:@[] suite1Expected:all_tests() suite2Expected:all_tests()];
}

- (void)test_noTestsRunIfEmptyFilter
{
    [self assertFilters:@[@"--ct-include="] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
}

- (void)test_noTestsRunIfEmptyQuotedFilter
{
    [self assertFilters:@[@"--ct-include=''"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
}

- (void)test_noTestsRunIfEmptyDoubleQuotedFilter
{
    [self assertFilters:@[@"--ct-include=\"\""] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
}

- (void)test_allTestsRunIfWildcardFilter
{
    [self assertFilters:@[@"--ct-include=*"] suite1Expected:all_tests() suite2Expected:all_tests()];
}

- (void)test_allTestsRunIfQuotedWildcardFilter
{
    [self assertFilters:@[@"--ct-include='*'"] suite1Expected:all_tests() suite2Expected:all_tests()];
}

- (void)test_allTestsRunIfDoubleQuotedWildcardFilter
{
    [self assertFilters:@[@"--ct-include=\"*\""] suite1Expected:all_tests() suite2Expected:all_tests()];
}

- (void)test_runsSpecificSuiteAndTest
{
    [self assertFilters:@[@"--ct-include=suite_foo:test_bort"] suite1Expected:RUN_TEST_BORT suite2Expected:RUN_TEST_NONE];
}

- (void)test_ignoresSingleQuotes
{
    [self assertFilters:@[@"--ct-include='suite_foo:test_bort'"] suite1Expected:RUN_TEST_BORT suite2Expected:RUN_TEST_NONE];
}

- (void)test_ignoresDoubleQuotes
{
    [self assertFilters:@[@"--ct-include='\"suite_foo:test_bort\""] suite1Expected:RUN_TEST_BORT suite2Expected:RUN_TEST_NONE];
}

- (void)test_ignoresRandomSingleQuotes
{
    [self assertFilters:@[@"--ct-include=suite_'foo':test_bort'"] suite1Expected:RUN_TEST_BORT suite2Expected:RUN_TEST_NONE];
}

- (void)test_ignoresRandomDoubleQuotes
{
    [self assertFilters:@[@"--ct-include=suite_\"foo\":test_bort'"] suite1Expected:RUN_TEST_BORT suite2Expected:RUN_TEST_NONE];
}

- (void)test_doesNotIgnoreWhitespace
{
    [self assertFilters:@[@"--ct-include=suite_foo:test_bort "] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
    [self assertFilters:@[@"--ct-include= suite_foo:test_bort"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
    [self assertFilters:@[@"--ct-include= suite_foo:test_bort "] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
}

- (void)test_runsAllTestsSpecificSuite
{
    [self assertFilters:@[@"--ct-include=suite_foo:"] suite1Expected:all_tests() suite2Expected:RUN_TEST_NONE];
}

- (void)test_runsSpecificTestAllSuites
{
    [self assertFilters:@[@"--ct-include=:test_bort"] suite1Expected:RUN_TEST_BORT suite2Expected:RUN_TEST_BORT];
}

- (void)test_runWildcardLetterTests
{
    RUN_TEST_FLAGS expected = RUN_TEST_BORT | RUN_TEST_BART;
    [self assertFilters:@[@"--ct-include=:test_b?rt"] suite1Expected:expected suite2Expected:expected];
}

- (void)test_runWildcardLetterTestsWithSuite
{
    RUN_TEST_FLAGS expected = RUN_TEST_BORT | RUN_TEST_BART;
    [self assertFilters:@[@"--ct-include=suite_bar:test_b?rt"] suite1Expected:RUN_TEST_NONE suite2Expected:expected];
}

- (void)test_runWildcardLetterSuites
{
    Suites[0] = make_suite("suite_far", suite1_setup);
    
    [self assertFilters:@[@"--ct-include=suite_?ar:"] suite1Expected:all_tests() suite2Expected:all_tests()];
}

- (void)test_runWildcardLetterSuitesWithTest
{
    Suites[0] = make_suite("suite_far", suite1_setup);
    
    [self assertFilters:@[@"--ct-include=suite_?ar:test_foobar"] suite1Expected:RUN_TEST_FOOBAR suite2Expected:RUN_TEST_FOOBAR];
}

- (void)test_runsNothingIfNoMatch
{
    [self assertFilters:@[@"--ct-include=foo"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
}

- (void)test_runsWildcardMatches
{
    [self assertFilters:@[@"--ct-include=*foo*"] suite1Expected:RUN_TEST_FOOBAR | RUN_TEST_BARFOO suite2Expected:RUN_TEST_NONE];
}

- (void)test_runsEndWildcardMatches
{
    [self assertFilters:@[@"--ct-include=*foo"] suite1Expected:RUN_TEST_BARFOO suite2Expected:RUN_TEST_NONE];
}

- (void)test_runsStartWildcardMatches
{
    [self assertFilters:@[@"--ct-include=suite_f*"] suite1Expected:all_tests() suite2Expected:RUN_TEST_NONE];
}

- (void)test_runsWildcardTestsOnly
{
    RUN_TEST_FLAGS expected = RUN_TEST_BARFOO | RUN_TEST_BART;
    [self assertFilters:@[@"--ct-include=:*bar*"] suite1Expected:expected suite2Expected:expected];
}

- (void)test_runsWildcardSuitesOnly
{
    [self assertFilters:@[@"--ct-include=*bar:"] suite1Expected:RUN_TEST_NONE suite2Expected:all_tests()];
}

- (void)test_runsMixWildcardLetterAndWildcard
{
    Suites[0] = make_suite("suite_far", suite1_setup);
    
    RUN_TEST_FLAGS expected = RUN_TEST_FOOBAR | RUN_TEST_BARFOO;
    [self assertFilters:@[@"--ct-include=suite_?ar:*foo*"] suite1Expected:expected suite2Expected:expected];
}

- (void)test_extendedWildcard
{
    [self assertFilters:@[@"--ct-include=*æ*"] suite1Expected:RUN_TEST_EXTENDED suite2Expected:RUN_TEST_EXTENDED];
}

- (void)test_eastAsianWildcard
{
    [self assertFilters:@[@"--ct-include=*试*"] suite1Expected:RUN_TEST_EAST_ASIAN suite2Expected:RUN_TEST_EAST_ASIAN];
}

- (void)test_horseWildcard
{
    [self assertFilters:@[@"--ct-include=*🐴*"] suite1Expected:RUN_TEST_HORSE suite2Expected:RUN_TEST_HORSE];
}

- (void)test_wildcardLetterSupportsSingleByteUnicode
{
    [self assertFilters:@[@"--ct-include=:test_?xtended_chærs"] suite1Expected:RUN_TEST_EXTENDED suite2Expected:RUN_TEST_EXTENDED];
}

- (void)test_wildcardLetterDoesNotSupportMultibyteUnicode
{
    [self assertFilters:@[@"--ct-include=:test_测试?"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
    [self assertFilters:@[@"--ct-include=:test_🐴?"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
}

- (void)test_runsMultipleExactMatches
{
    [self assertFilters:@[@"--ct-include=suite_foo:test_bort,suite_bar:test_barfoo"] suite1Expected:RUN_TEST_BORT suite2Expected:RUN_TEST_BARFOO];
}

- (void)test_doesNotIgnoreWhitespaceBetweenExpressions
{
    [self assertFilters:@[@"--ct-include=suite_foo:test_bort, suite_bar:test_barfoo"] suite1Expected:RUN_TEST_BORT suite2Expected:RUN_TEST_NONE];
    [self assertFilters:@[@"--ct-include=suite_foo:test_bort ,suite_bar:test_barfoo"] suite1Expected:RUN_TEST_BORT suite2Expected:RUN_TEST_NONE];
    [self assertFilters:@[@"--ct-include=suite_foo:test_bort , suite_bar:test_barfoo"] suite1Expected:RUN_TEST_BORT suite2Expected:RUN_TEST_NONE];
}

- (void)test_runsMultipleWildcardExpressions
{
    [self assertFilters:@[@"--ct-include=*foo*,suite_bar:test_b?rt"] suite1Expected:all_tests() suite2Expected:RUN_TEST_BART | RUN_TEST_BORT];
}

- (void)test_runsOverlappingWildcards
{
    [self assertFilters:@[@"--ct-include=*foo,:test_ba*,suite_bar:*rt"] suite1Expected:RUN_TEST_BARFOO | RUN_TEST_BART suite2Expected:RUN_TEST_BARFOO | RUN_TEST_BART | RUN_TEST_BORT];
}

- (void)assertFilters:(NSArray *)filters suite1Expected:(RUN_TEST_FLAGS)suite1Expected suite2Expected:(RUN_TEST_FLAGS)suite2Expected
{
    const int argc = (int)filters.count;
    const char *argv[argc];
    for (int i = 0; i < argc; ++i) {
        argv[i] = [filters[i] UTF8String];
    }
    
    ct_run_withargs(Suites, sizeof Suites / sizeof Suites[0], argc, argv);
    
    XCTAssertEqual(suite1Expected, Suite1Flags);
    XCTAssertEqual(suite2Expected, Suite2Flags);
}

@end
