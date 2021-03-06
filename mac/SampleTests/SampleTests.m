//
//  SampleTests.m
//  SampleTests
//
//  Created by Brandon Stansbury on 7/6/16.
//  Copyright © 2016 Brandon Stansbury. All rights reserved.
//

#import <XCTest/XCTest.h>

#include <stddef.h>

size_t binarytree_tests(int, char *[]);

@interface SampleTests : XCTestCase

@end

@implementation SampleTests

- (void)test_BinaryTree_Suite
{
    char *argv[] = {"XCTestRun", "--ct-colorized=no"};
    const int argc = sizeof argv / sizeof argv[0];

    const size_t results = binarytree_tests(argc, argv);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
    XCTAssertEqual(0u, results, "%zu binary tree tests failed", results);
#pragma clang diagnostic pop
}

@end
