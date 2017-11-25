//
//  CTAssertEqualStrTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 6/20/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#import "CTStringAssertionTestBase.h"
#include <stddef.h>
#include "ciny.h"

@interface CTAssertEqualStrTests : CTStringAssertionTestBase

@end

static void test_equality_stringn(void *context)
{
    CTAssertEqualStrTests *testObject = (__bridge CTAssertEqualStrTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertequalstrn(testObject.expectedString, testObject.actualString, testObject.compareCount);
    
    testObject.sawPostAssertCode = YES;
}

static void test_equality_stringn_withmessage(void *context)
{
    CTAssertEqualStrTests *testObject = (__bridge CTAssertEqualStrTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertequalstrn("foobar", "barfoo", sizeof "foobar", "not equal strings >:(");
    
    testObject.sawPostAssertCode = YES;
}

static void test_equality_stringn_withformatmessage(void *context)
{
    CTAssertEqualStrTests *testObject = (__bridge CTAssertEqualStrTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    const char * const expected = "foobar", * const actual = "barfoo";
    
    ct_assertequalstrn(expected, actual, sizeof "foobar", "who said %s?!, i said %s", actual, expected);
    
    testObject.sawPostAssertCode = YES;
}

static void test_equality_string_expectedempty(void *context)
{
    CTAssertEqualStrTests *testObject = (__bridge CTAssertEqualStrTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertequalstr("", testObject.actualString);
    
    testObject.sawPostAssertCode = YES;
}

static void test_equality_string_expectedonechar(void *context)
{
    CTAssertEqualStrTests *testObject = (__bridge CTAssertEqualStrTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertequalstr("b", testObject.actualString);
    
    testObject.sawPostAssertCode = YES;
}

static void test_equality_string_expected(void *context)
{
    CTAssertEqualStrTests *testObject = (__bridge CTAssertEqualStrTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertequalstr("foobar", testObject.actualString);
    
    testObject.sawPostAssertCode = YES;
}

static void test_equality_string_withmessage(void *context)
{
    CTAssertEqualStrTests *testObject = (__bridge CTAssertEqualStrTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertequalstr("foobar", "barfoo", "not equal strings :(");
    
    testObject.sawPostAssertCode = YES;
}

static void test_equality_string_withformatmessage(void *context)
{
    CTAssertEqualStrTests *testObject = (__bridge CTAssertEqualStrTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    const char * const actual = "barfoo";
    
    ct_assertequalstr("foobar", actual, "why'd you say %s??", actual);
    
    testObject.sawPostAssertCode = YES;
}

@implementation CTAssertEqualStrTests

#pragma mark - ctassertequalstrn

- (void)test_ctassertequalstrn_ComparesEqual_IfExpectedAndActualAreNull
{
    self.expectedString = NULL;
    self.actualString = NULL;
    self.compareCount = 0;
    const struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertequalstrn_ComparesEqual_IfExpectedAndActualAreNullEvenWithInvalidSize
{
    self.expectedString = NULL;
    self.actualString = NULL;
    self.compareCount = 8;
    const struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertequalstrn_ComparesEqual_IfExpectedAndActualAreEmpty
{
    self.expectedString = "";
    self.actualString = "";
    self.compareCount = sizeof "";
    const struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertequalstrn_ComparesEqual_IfExpectedAndActualAreSingleCharStrings
{
    self.expectedString = "f";
    self.actualString = "f";
    self.compareCount = sizeof "f";
    const struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertequalstrn_ComparesEqual_IfExpectedAndActualAreEqualStrings
{
    self.expectedString = "foobar";
    self.actualString = "foobar";
    self.compareCount = sizeof "foobar";
    const struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertequalstrn_ComparesEqual_IfSizeRefersToEqualSubstrings
{
    self.expectedString = "foobar";
    self.actualString = "fooroo";
    self.compareCount = 3;
    const struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertequalstrn_ComparesEqual_IfUnicodeStrings
{
    self.expectedString = "测试";
    self.actualString = "测试";
    self.compareCount = sizeof "测试";
    const struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertequalstrn_ComparesEqual_IfEmoji
{
    self.expectedString = "💩";
    self.actualString = "💩";
    self.compareCount = sizeof "💩";
    const struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertequalstrn_ComparesEqual_IfUnicodeCharIsComparedToUTF16EscapeSequence
{
    self.expectedString = "⌘";
    self.actualString = "\u2318";
    self.compareCount = sizeof "⌘";
    const struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertequalstrn_ComparesEqual_IfUnicodeCharIsComparedToUTF32EscapeSequence
{
    self.expectedString = "🐴";
    self.actualString = "\U0001F434";
    self.compareCount = sizeof "🐴";
    const struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertequalstrn_ComparesEqual_WithVeryLongString
{
    NSString *longString = [[NSBundle bundleForClass:self.class] localizedStringForKey:@"LongString" value:@"PlaceholderString" table:@"Tests"];
    self.expectedString = (char *)[longString UTF8String];
    NSString *copiedString = [NSString stringWithUTF8String:self.expectedString];
    self.actualString = (char *)[copiedString UTF8String];
    self.compareCount = longString.length + 1;
    const struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_IfMixedCase
{
    self.expectedString = "foobar";
    self.actualString = "FOOBAR";
    self.compareCount = sizeof "foobar";
    const struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_IfActualIsShorterThanExpected
{
    self.expectedString = "foobar";
    self.actualString = "fooba";
    self.compareCount = sizeof "foobar";
    const struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_IfActualIsLongerThanExpected
{
    self.expectedString = "foobar";
    self.actualString = "foobars";
    self.compareCount = sizeof "foobar";
    const struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_IfExpectedIsNull
{
    self.expectedString = NULL;
    self.actualString = "foobar";
    self.compareCount = 0;
    const struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_IfExpectedIsNullWithInvalidSize
{
    self.expectedString = NULL;
    self.actualString = "foobar";
    self.compareCount = 45;
    const struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_IfExpectedIsEmpty
{
    self.expectedString = "";
    self.actualString = "foobar";
    self.compareCount = 1;
    const struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_IfActualIsNull
{
    self.expectedString = "foobar";
    self.actualString = NULL;
    self.compareCount = sizeof "foobar";
    const struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_IfActualIsNullWithInvalidSize
{
    self.expectedString = "foobar";
    self.actualString = NULL;
    self.compareCount = 100;
    const struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_IfActualIsEmpty
{
    self.expectedString = "foobar";
    self.actualString = "";
    self.compareCount = sizeof "foobar";
    const struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_IfDifferentStrings
{
    self.expectedString = "foobar";
    self.actualString = "blarg";
    self.compareCount = sizeof "foobar";
    const struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_IfDifferentUnicodeStrings
{
    self.expectedString = "例子";
    self.actualString = "مثال.إختبار";
    self.compareCount = sizeof "例子";
    const struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_IfDifferentEmoji
{
    self.expectedString = "🐵";
    self.actualString = "🐒";
    self.compareCount = sizeof "🐵";
    const struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_IfUnicodeCharIsComparedToComparableISOSequence
{
    self.expectedString = "’"; // 0xE2 0x80 0x99 (\u2019)
    self.actualString = "â€™"; // 0xE2 0x80 0x99 in ISO-8859-1
    self.compareCount = sizeof "’";
    const struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_WhenVeryLongStringDiffersAtStart
{
    NSString *longString = [[NSBundle bundleForClass:self.class] localizedStringForKey:@"LongString" value:@"PlaceholderString" table:@"Tests"];
    self.expectedString = (char *)[longString UTF8String];
    NSString *copiedString = [NSString stringWithUTF8String:self.expectedString];
    self.actualString = (char *)[copiedString UTF8String];
    ++self.actualString[0];
    self.compareCount = longString.length + 1;
    const struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_WhenVeryLongStringDiffersAtEnd
{
    NSString *longString = [[NSBundle bundleForClass:self.class] localizedStringForKey:@"LongString" value:@"PlaceholderString" table:@"Tests"];
    self.expectedString = (char *)[longString UTF8String];
    NSString *copiedString = [NSString stringWithUTF8String:self.expectedString];
    self.actualString = (char *)[copiedString UTF8String];
    ++self.actualString[longString.length];
    self.compareCount = longString.length + 1;
    const struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

#pragma mark - ctassertequalstr

- (void)test_ctassertequalstrEmpty_ComparesNotEqual_IfNull
{
    self.actualString = NULL;
    const struct ct_testcase tests[] = { ct_maketest(test_equality_string_expectedempty) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertequalstrEmpty_ComparesEqual_IfEmpty
{
    self.actualString = "";
    const struct ct_testcase tests[] = { ct_maketest(test_equality_string_expectedempty) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertequalstrEmpty_ComparesNotEqual_IfSingleChar
{
    self.actualString = "f";
    const struct ct_testcase tests[] = { ct_maketest(test_equality_string_expectedempty) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertequalstrEmpty_ComparesNotEqual_IfNonEmptyString
{
    self.actualString = "foobar";
    const struct ct_testcase tests[] = { ct_maketest(test_equality_string_expectedempty) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertequalstrOneChar_ComparesNotEqual_IfNull
{
    self.actualString = NULL;
    const struct ct_testcase tests[] = { ct_maketest(test_equality_string_expectedonechar) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertequalstrOneChar_ComparesNotEqual_IfEmpty
{
    self.actualString = "";
    const struct ct_testcase tests[] = { ct_maketest(test_equality_string_expectedonechar) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertequalstrOneChar_ComparesEqual_IfSingleChar
{
    self.actualString = "b";
    const struct ct_testcase tests[] = { ct_maketest(test_equality_string_expectedonechar) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertequalstrOneChar_ComparesNotEqual_IfNonEqualSingleChar
{
    self.actualString = "d";
    const struct ct_testcase tests[] = { ct_maketest(test_equality_string_expectedonechar) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertequalstrOneChar_ComparesNotEqual_IfNonEmptyString
{
    self.actualString = "booz";
    const struct ct_testcase tests[] = { ct_maketest(test_equality_string_expectedonechar) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertequalstrFullStr_ComparesNotEqual_IfNull
{
    self.actualString = NULL;
    const struct ct_testcase tests[] = { ct_maketest(test_equality_string_expected) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertequalstrFullStr_ComparesNotEqual_IfEmpty
{
    self.actualString = "";
    const struct ct_testcase tests[] = { ct_maketest(test_equality_string_expected) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertequalstrFullStr_ComparesNotEqual_IfSingleChar
{
    self.actualString = "f";
    const struct ct_testcase tests[] = { ct_maketest(test_equality_string_expected) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertequalstrFullStr_ComparesEqual_IfSameString
{
    self.actualString = "foobar";
    const struct ct_testcase tests[] = { ct_maketest(test_equality_string_expected) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertequalstrFullStr_ComparesNotEqual_IfSuperstring
{
    self.actualString = "foobars";
    const struct ct_testcase tests[] = { ct_maketest(test_equality_string_expected) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

#pragma mark - Messages

- (void)test_ctassertequalstrn_FailsAssertion_WithMessage
{
    const struct ct_testcase tests[] = { ct_maketest(test_equality_stringn_withmessage) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertequalstrn_FailsAssertion_WithFormattedMessage
{
    const struct ct_testcase tests[] = { ct_maketest(test_equality_stringn_withformatmessage) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertequalstr_FailsAssertion_WithMessage
{
    const struct ct_testcase tests[] = { ct_maketest(test_equality_string_withmessage) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertequalstr_FailsAssertion_WithFormattedMessage
{
    const struct ct_testcase tests[] = { ct_maketest(test_equality_string_withformatmessage) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

@end
