//
//  CTAssertEqualStrTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 6/20/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include <stddef.h>
#include "ciny.h"

@interface CTAssertEqualStrTests : XCTestCase

@property (nonatomic, assign) BOOL invokedTest;
@property (nonatomic, assign) BOOL sawPostAssertCode;
@property (nonatomic, assign) char *expectedString;
@property (nonatomic, assign) char *actualString;
@property (nonatomic, assign) size_t compareCount;

@end

static void *TestClass;

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
    
    const char *expected = "foobar";
    const char *actual = "barfoo";
    
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
    
    const char *actual = "barfoo";
    
    ct_assertequalstr("foobar", actual, "why'd you say %s??", actual);
    
    testObject.sawPostAssertCode = YES;
}

@implementation CTAssertEqualStrTests

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

#pragma mark - ctassertequalstrn

- (void)test_ctassertequalstrn_ComparesEqual_IfExpectedAndActualAreNull
{
    self.expectedString = NULL;
    self.actualString = NULL;
    self.compareCount = 0;
    struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrn_ComparesEqual_IfExpectedAndActualAreNullEvenWithInvalidSize
{
    self.expectedString = NULL;
    self.actualString = NULL;
    self.compareCount = 8;
    struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrn_ComparesEqual_IfExpectedAndActualAreEmpty
{
    self.expectedString = "";
    self.actualString = "";
    self.compareCount = sizeof "";
    struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrn_ComparesEqual_IfExpectedAndActualAreSingleCharStrings
{
    self.expectedString = "f";
    self.actualString = "f";
    self.compareCount = sizeof "f";
    struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrn_ComparesEqual_IfExpectedAndActualAreEqualStrings
{
    self.expectedString = "foobar";
    self.actualString = "foobar";
    self.compareCount = sizeof "foobar";
    struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrn_ComparesEqual_IfSizeRefersToEqualSubstrings
{
    self.expectedString = "foobar";
    self.actualString = "fooroo";
    self.compareCount = 3;
    struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrn_ComparesEqual_IfUnicodeStrings
{
    self.expectedString = "测试";
    self.actualString = "测试";
    self.compareCount = sizeof "测试";
    struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrn_ComparesEqual_IfEmoji
{
    self.expectedString = "💩";
    self.actualString = "💩";
    self.compareCount = sizeof "💩";
    struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrn_ComparesEqual_IfUnicodeCharIsComparedToUTF16EscapeSequence
{
    self.expectedString = "⌘";
    self.actualString = "\u2318";
    self.compareCount = sizeof "⌘";
    struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrn_ComparesEqual_IfUnicodeCharIsComparedToUTF32EscapeSequence
{
    self.expectedString = "🐴";
    self.actualString = "\U0001F434";
    self.compareCount = sizeof "🐴";
    struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrn_ComparesEqual_WithVeryLongString
{
    NSString *longString = [[NSBundle bundleForClass:self.class] objectForInfoDictionaryKey:@"LongString"];
    self.expectedString = (char *)[longString UTF8String];
    NSString *copiedString = [NSString stringWithUTF8String:self.expectedString];
    self.actualString = (char *)[copiedString UTF8String];
    self.compareCount = longString.length + 1;
    struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_IfMixedCase
{
    self.expectedString = "foobar";
    self.actualString = "FOOBAR";
    self.compareCount = sizeof "foobar";
    struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_IfActualIsShorterThanExpected
{
    self.expectedString = "foobar";
    self.actualString = "fooba";
    self.compareCount = sizeof "foobar";
    struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_IfActualIsLongerThanExpected
{
    self.expectedString = "foobar";
    self.actualString = "foobars";
    self.compareCount = sizeof "foobar";
    struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_IfExpectedIsNull
{
    self.expectedString = NULL;
    self.actualString = "foobar";
    self.compareCount = 0;
    struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_IfExpectedIsNullWithInvalidSize
{
    self.expectedString = NULL;
    self.actualString = "foobar";
    self.compareCount = 45;
    struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_IfExpectedIsEmpty
{
    self.expectedString = "";
    self.actualString = "foobar";
    self.compareCount = 1;
    struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_IfActualIsNull
{
    self.expectedString = "foobar";
    self.actualString = NULL;
    self.compareCount = sizeof "foobar";
    struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_IfActualIsNullWithInvalidSize
{
    self.expectedString = "foobar";
    self.actualString = NULL;
    self.compareCount = 100;
    struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_IfActualIsEmpty
{
    self.expectedString = "foobar";
    self.actualString = "";
    self.compareCount = sizeof "foobar";
    struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_IfDifferentStrings
{
    self.expectedString = "foobar";
    self.actualString = "blarg";
    self.compareCount = sizeof "foobar";
    struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_IfDifferentUnicodeStrings
{
    self.expectedString = "例子";
    self.actualString = "مثال.إختبار";
    self.compareCount = sizeof "例子";
    struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_IfDifferentEmoji
{
    self.expectedString = "🐵";
    self.actualString = "🐒";
    self.compareCount = sizeof "🐵";
    struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_IfUnicodeCharIsComparedToComparableISOSequence
{
    self.expectedString = "’"; // 0xE2 0x80 0x99 (\u2019)
    self.actualString = "â€™"; // 0xE2 0x80 0x99 in ISO-8859-1
    self.compareCount = sizeof "’";
    struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_WhenVeryLongStringDiffersAtStart
{
    NSString *longString = [[NSBundle bundleForClass:self.class] objectForInfoDictionaryKey:@"LongString"];
    self.expectedString = (char *)[longString UTF8String];
    NSString *copiedString = [NSString stringWithUTF8String:self.expectedString];
    self.actualString = (char *)[copiedString UTF8String];
    ++self.actualString[0];
    self.compareCount = longString.length + 1;
    struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrn_ComparesNotEqual_WhenVeryLongStringDiffersAtEnd
{
    NSString *longString = [[NSBundle bundleForClass:self.class] objectForInfoDictionaryKey:@"LongString"];
    self.expectedString = (char *)[longString UTF8String];
    NSString *copiedString = [NSString stringWithUTF8String:self.expectedString];
    self.actualString = (char *)[copiedString UTF8String];
    ++self.actualString[longString.length];
    self.compareCount = longString.length + 1;
    struct ct_testcase tests[] = { ct_maketest(test_equality_stringn) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

#pragma mark - ctassertequalstr

- (void)test_ctassertequalstrEmpty_ComparesNotEqual_IfNull
{
    self.actualString = NULL;
    struct ct_testcase tests[] = { ct_maketest(test_equality_string_expectedempty) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrEmpty_ComparesEqual_IfEmpty
{
    self.actualString = "";
    struct ct_testcase tests[] = { ct_maketest(test_equality_string_expectedempty) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrEmpty_ComparesNotEqual_IfSingleChar
{
    self.actualString = "f";
    struct ct_testcase tests[] = { ct_maketest(test_equality_string_expectedempty) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrEmpty_ComparesNotEqual_IfNonEmptyString
{
    self.actualString = "foobar";
    struct ct_testcase tests[] = { ct_maketest(test_equality_string_expectedempty) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrOneChar_ComparesNotEqual_IfNull
{
    self.actualString = NULL;
    struct ct_testcase tests[] = { ct_maketest(test_equality_string_expectedonechar) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrOneChar_ComparesNotEqual_IfEmpty
{
    self.actualString = "";
    struct ct_testcase tests[] = { ct_maketest(test_equality_string_expectedonechar) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrOneChar_ComparesEqual_IfSingleChar
{
    self.actualString = "b";
    struct ct_testcase tests[] = { ct_maketest(test_equality_string_expectedonechar) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrOneChar_ComparesNotEqual_IfNonEqualSingleChar
{
    self.actualString = "d";
    struct ct_testcase tests[] = { ct_maketest(test_equality_string_expectedonechar) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrOneChar_ComparesNotEqual_IfNonEmptyString
{
    self.actualString = "booz";
    struct ct_testcase tests[] = { ct_maketest(test_equality_string_expectedonechar) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrFullStr_ComparesNotEqual_IfNull
{
    self.actualString = NULL;
    struct ct_testcase tests[] = { ct_maketest(test_equality_string_expected) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrFullStr_ComparesNotEqual_IfEmpty
{
    self.actualString = "";
    struct ct_testcase tests[] = { ct_maketest(test_equality_string_expected) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrFullStr_ComparesNotEqual_IfSingleChar
{
    self.actualString = "f";
    struct ct_testcase tests[] = { ct_maketest(test_equality_string_expected) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrFullStr_ComparesEqual_IfSameString
{
    self.actualString = "foobar";
    struct ct_testcase tests[] = { ct_maketest(test_equality_string_expected) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrFullStr_ComparesNotEqual_IfSuperstring
{
    self.actualString = "foobars";
    struct ct_testcase tests[] = { ct_maketest(test_equality_string_expected) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

#pragma mark - Messages

- (void)test_ctassertequalstrn_FailsAssertion_WithMessage
{
    struct ct_testcase tests[] = { ct_maketest(test_equality_stringn_withmessage) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequalstrn_FailsAssertion_WithFormattedMessage
{
    struct ct_testcase tests[] = { ct_maketest(test_equality_stringn_withformatmessage) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequalstr_FailsAssertion_WithMessage
{
    struct ct_testcase tests[] = { ct_maketest(test_equality_string_withmessage) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequalstr_FailsAssertion_WithFormattedMessage
{
    struct ct_testcase tests[] = { ct_maketest(test_equality_string_withformatmessage) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

@end
