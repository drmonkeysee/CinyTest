//
//  CTAssertNotNullTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 5/10/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include <stddef.h>
#include <stdbool.h>
#include "ciny.h"

@interface CTAssertNotNullTests : XCTestCase

@property (nonatomic, assign) BOOL invokedTest;
@property (nonatomic, assign) BOOL sawPostAssertCode;
@property (nonatomic, assign) void *testVariable;
@property (nonatomic, assign) bool useRealPointer;

@end

static void *TestClass;

static void *generate_pointer(bool real_pointer)
{
    return real_pointer ? TestClass : NULL;
}

static void variable_test(void *context)
{
    CTAssertNotNullTests *testObject = (__bridge CTAssertNotNullTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertnotnull(testObject.testVariable, "i see the %p value", testObject.testVariable);
    
    testObject.sawPostAssertCode = YES;
}

static void expression_test(void *context)
{
    CTAssertNotNullTests *testObject = (__bridge CTAssertNotNullTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertnotnull(generate_pointer(testObject.useRealPointer), "oh no i got a fake pointer!!");
    
    testObject.sawPostAssertCode = YES;
}

static void literal_null_test(void *context)
{
    CTAssertNotNullTests *testObject = (__bridge CTAssertNotNullTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertnotnull(NULL);
    
    testObject.sawPostAssertCode = YES;
}

static void literal_notnull_test(void *context)
{
    CTAssertNotNullTests *testObject = (__bridge CTAssertNotNullTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertnotnull((void *)0xffff);
    
    testObject.sawPostAssertCode = YES;
}

@implementation CTAssertNotNullTests

- (void)setUp
{
    [super setUp];
    
    TestClass = (__bridge void *)(self);
}

- (void)tearDown
{
    TestClass = NULL;
    self.testVariable = NULL;
    
    [super tearDown];
}

- (void)test_ctassertnotnull_DoesNotFire_IfVariableIsNotNull
{
    self.testVariable = TestClass;
    struct ct_testcase cases[] = { ct_maketest(variable_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertnotnull_DoesFire_IfVariableIsNull
{
    self.testVariable = NULL;
    struct ct_testcase cases[] = { ct_maketest(variable_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertnotnull_DoesNotFire_IfExpressionReturnsNotNull
{
    self.useRealPointer = true;
    struct ct_testcase cases[] = { ct_maketest(expression_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertnotnull_DoesFire_IfExpressionReturnsNull
{
    self.useRealPointer = false;
    struct ct_testcase cases[] = { ct_maketest(expression_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertnotnull_DoesNotFire_IfLiteralIsNotNull
{
    struct ct_testcase cases[] = { ct_maketest(literal_notnull_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertnotnull_DoesFire_IfLiteralIsNull
{
    struct ct_testcase cases[] = { ct_maketest(literal_null_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

@end
