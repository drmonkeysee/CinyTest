//
//  CTVersionTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 3/4/17.
//  Copyright © 2017 Brandon Stansbury. All rights reserved.
//

#import "CTTestBase.h"

#include "ciny.h"

@interface CTVersionTests : CTTestBase

@end

@implementation CTVersionTests

- (void)test_ctversionhex_Generates_Expected_Value
{
    struct ct_version v = {5, 21, 205};
    
    auto vhex = ct_versionhex(&v);
    
    XCTAssertEqual(0x000515cdu, vhex);
}

- (void)test_ctversionhex_Matches_Current_Version
{
    auto v = ct_getversion();
    
    auto vhex = ct_versionhex(&v);

    auto expected = (uint32_t)(0 | v.major << 16 | v.minor << 8 | v.patch);
    XCTAssertEqual(expected, vhex);
}

- (void)test_ctversionhex_Compares_Major_Properly
{
    struct ct_version smaller = {2, 1, 1};
    struct ct_version bigger = {3, 1, 1};
    
    auto shex = ct_versionhex(&smaller), bhex = ct_versionhex(&bigger);

    XCTAssertLessThan(shex, bhex);
}

- (void)test_ctversionhex_Compares_Minor_Properly
{
    struct ct_version smaller = {2, 9, 1};
    struct ct_version bigger = {2, 12, 1};
    
    auto shex = ct_versionhex(&smaller), bhex = ct_versionhex(&bigger);

    XCTAssertLessThan(shex, bhex);
}

- (void)test_ctversionhex_Compares_Patch_Properly
{
    struct ct_version smaller = {2, 5, 23};
    struct ct_version bigger = {2, 5, 154};
    
    auto shex = ct_versionhex(&smaller), bhex = ct_versionhex(&bigger);
    
    XCTAssertLessThan(shex, bhex);
}

@end
