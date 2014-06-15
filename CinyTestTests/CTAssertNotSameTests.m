//
//  CTAssertNotSameTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 6/14/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include <stddef.h>
#include "ciny.h"

@interface CTAssertNotSameTests : XCTestCase

@property (nonatomic, assign) BOOL invokedTest;
@property (nonatomic, assign) BOOL sawPostAssertCode;
@property (nonatomic, assign) void *expectedPointer;
@property (nonatomic, assign) void *actualPointer;

@end

static void *TestClass;

static void identity_test(void *context)
{
    CTAssertNotSameTests *testObject = (__bridge CTAssertNotSameTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertnotsame(testObject.expectedPointer, testObject.actualPointer);
    
    testObject.sawPostAssertCode = YES;
}

static void identity_test_withmessage(void *context)
{
    CTAssertNotSameTests *testObject = (__bridge CTAssertNotSameTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    int i = 20;
    
    ct_assertnotsame(&i, &i, "these pointers are equal!");
    
    testObject.sawPostAssertCode = YES;
}

static void identity_test_withformattedmessage(void *context)
{
    CTAssertNotSameTests *testObject = (__bridge CTAssertNotSameTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    const char *s = "foobar";
    char *c = (char *)s;
    
    ct_assertnotsame(s, c, "\"%s\" is the same as '%c'", s, *c);
    
    testObject.sawPostAssertCode = YES;
}

@implementation CTAssertNotSameTests

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

- (void)test_ctassertnotsame_ComparesSame_IfNullInputs
{
    self.expectedPointer = NULL;
    self.actualPointer = NULL;
    struct ct_testcase tests[] = { ct_maketest(identity_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertnotsame_ComparesNotSame_IfExpectedIsNull
{
    int testValue = 10;
    self.expectedPointer = NULL;
    self.actualPointer = &testValue;
    struct ct_testcase tests[] = { ct_maketest(identity_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertnotsame_ComparesNotSame_IfActualIsNull
{
    int testValue = 10;
    self.expectedPointer = &testValue;
    self.actualPointer = NULL;
    struct ct_testcase tests[] = { ct_maketest(identity_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertnotsame_ComparesSame_IfBothPointToSameObject
{
    int testValue = 10;
    self.expectedPointer = &testValue;
    self.actualPointer = &testValue;
    struct ct_testcase tests[] = { ct_maketest(identity_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertnotsame_ComparesNotSame_IfPointingAtDifferentObjects
{
    int expectedTestValue = 10;
    int actualTestValue = 10;
    self.expectedPointer = &expectedTestValue;
    self.actualPointer = &actualTestValue;
    struct ct_testcase tests[] = { ct_maketest(identity_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertnotsame_ComparesNotSame_IfPointingAtDifferentPartsOfSameObject
{
    int values[] = { 2, 4, 5 };
    self.expectedPointer = values;
    self.actualPointer = values + 1;
    struct ct_testcase tests[] = { ct_maketest(identity_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertnotsame_ComparesSame_IfExpectedIsAliasedVersionOfActual
{
    int testValue = 10;
    int *aliasedPointer = &testValue;
    self.expectedPointer = aliasedPointer;
    self.actualPointer = &testValue;
    struct ct_testcase tests[] = { ct_maketest(identity_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertnotsame_ComparesSame_IfActualIsAliasedVersionOfExpected
{
    int testValue = 10;
    int *aliasedPointer = &testValue;
    self.expectedPointer = &testValue;
    self.actualPointer = aliasedPointer;
    struct ct_testcase tests[] = { ct_maketest(identity_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertnotsame_FiresAssertion_WithMessage
{
    struct ct_testcase tests[] = { ct_maketest(identity_test_withmessage) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertnotsame_FiresAssertion_WithFormattedMessage
{
    struct ct_testcase tests[] = { ct_maketest(identity_test_withformattedmessage) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

@end
