//
//  CTAssertionTestBase.h
//  CinyTest
//
//  Created by Brandon Stansbury on 7/11/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#import "CTTestBase.h"
#include <stddef.h>

// these are macros instead of objc methods so the
// XCTest exceptions are still raised at the unit test call site,
// otherwise all test failures are reported as coming from CTAssertionTestBase
#define successful_assertion_expected(test_result) \
            do { \
                XCTAssertEqual(0u, test_result); \
                XCTAssertTrue(self.invokedTest); \
                XCTAssertTrue(self.sawPostAssertCode); \
            } while (0);

#define failed_assertion_expected(test_result) \
            do { \
                XCTAssertEqual(1u, test_result); \
                XCTAssertTrue(self.invokedTest); \
                XCTAssertFalse(self.sawPostAssertCode); \
            } while (0);

extern void *TestClass;

@interface CTAssertionTestBase : CTTestBase

@property (nonatomic, assign) BOOL invokedTest;
@property (nonatomic, assign) BOOL sawPostAssertCode;

@end
