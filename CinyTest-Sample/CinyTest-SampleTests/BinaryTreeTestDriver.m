//
//  BinaryTreeTestDriver.m
//  CinyTest-Sample
//
//  Created by Brandon Stansbury on 8/24/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#import <XCTest/XCTest.h>

size_t binarytree_tests(void);

@interface BinaryTreeTestDriver : XCTestCase

@end

@implementation BinaryTreeTestDriver

- (void)test_BinaryTree_Suite
{
    size_t results = binarytree_tests();
    
    XCTAssertEqual(0, results);
}

@end
