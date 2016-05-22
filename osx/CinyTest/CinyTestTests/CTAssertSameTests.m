//
//  CTAssertSameTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 6/14/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#import "CTSameAssertionTestBase.h"
#include "ciny.h"

@interface CTAssertSameTests : CTSameAssertionTestBase

@end

static void identity_test(void *context)
{
    CTAssertSameTests *testObject = (__bridge CTAssertSameTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertsame(testObject.expectedPointer, testObject.actualPointer);
    
    testObject.sawPostAssertCode = YES;
}

static void identity_test_withmessage(void *context)
{
    CTAssertSameTests *testObject = (__bridge CTAssertSameTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    int i = 20;
    double d = 4.5;
    
    ct_assertsame(&i, &d, "these pointers are not equal!");
    
    testObject.sawPostAssertCode = YES;
}

static void identity_test_withformattedmessage(void *context)
{
    CTAssertSameTests *testObject = (__bridge CTAssertSameTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    const char *s = "foobar";
    char c = 'A';
    
    ct_assertsame(s, &c, "\"%s\" is something other than '%c'", s, c);
    
    testObject.sawPostAssertCode = YES;
}

static void identity_test_pointerstopointers(void *context)
{
    CTAssertSameTests *testObject = (__bridge CTAssertSameTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    int value = 10;
    int *pvalue = &value;
    int **ppvalue = &pvalue;
    
    ct_assertsame(&pvalue, ppvalue);
    
    testObject.sawPostAssertCode = YES;
}

static void identity_test_pointer_andpointertopointer(void *context)
{
    CTAssertSameTests *testObject = (__bridge CTAssertSameTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    int value = 10;
    int *pvalue = &value;
    int **ppvalue = &pvalue;
    
    ct_assertsame(pvalue, ppvalue);
    
    testObject.sawPostAssertCode = YES;
}

@implementation CTAssertSameTests

- (void)test_ctassertsame_ComparesSame_IfNullInputs
{
    self.expectedPointer = NULL;
    self.actualPointer = NULL;
    const struct ct_testcase tests[] = { ct_maketest(identity_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertsame_ComparesNotSame_IfExpectedIsNull
{
    int testValue = 10;
    self.expectedPointer = NULL;
    self.actualPointer = &testValue;
    const struct ct_testcase tests[] = { ct_maketest(identity_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertsame_ComparesNotSame_IfActualIsNull
{
    int testValue = 10;
    self.expectedPointer = &testValue;
    self.actualPointer = NULL;
    const struct ct_testcase tests[] = { ct_maketest(identity_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertsame_ComparesSame_IfBothPointToSameObject
{
    int testValue = 10;
    self.expectedPointer = &testValue;
    self.actualPointer = &testValue;
    const struct ct_testcase tests[] = { ct_maketest(identity_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertsame_ComparesNotSame_IfPointingAtDifferentObjects
{
    int expectedTestValue = 10;
    int actualTestValue = 10;
    self.expectedPointer = &expectedTestValue;
    self.actualPointer = &actualTestValue;
    const struct ct_testcase tests[] = { ct_maketest(identity_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertsame_ComparesNotSame_IfPointingAtDifferentPartsOfSameObject
{
    int values[] = { 2, 4, 5 };
    self.expectedPointer = values;
    self.actualPointer = values + 1;
    const struct ct_testcase tests[] = { ct_maketest(identity_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertsame_ComparesSame_IfExpectedIsAliasedVersionOfActual
{
    int testValue = 10;
    int *aliasedPointer = &testValue;
    self.expectedPointer = aliasedPointer;
    self.actualPointer = &testValue;
    const struct ct_testcase tests[] = { ct_maketest(identity_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertsame_ComparesSame_IfActualIsAliasedVersionOfExpected
{
    int testValue = 10;
    int *aliasedPointer = &testValue;
    self.expectedPointer = &testValue;
    self.actualPointer = aliasedPointer;
    const struct ct_testcase tests[] = { ct_maketest(identity_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertsame_ComparesSame_IfPointersToPointers
{
    const struct ct_testcase tests[] = { ct_maketest(identity_test_pointerstopointers) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertsame_ComparesNotSame_IfPointerAndPointerToPointer
{
    const struct ct_testcase tests[] = { ct_maketest(identity_test_pointer_andpointertopointer) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertsame_FiresAssertion_WithMessage
{
    const struct ct_testcase tests[] = { ct_maketest(identity_test_withmessage) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertsame_FiresAssertion_WithFormattedMessage
{
    const struct ct_testcase tests[] = { ct_maketest(identity_test_withformattedmessage) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

@end
