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

- (void)test_cthexversion_Matches_Current_Version
{
    const struct ct_version v = ct_getversion();
    
    const uint32_t vhex = ct_versionhex(&v);
    
    const uint32_t expected = 0u | v.major << 16 | v.minor << 8 | v.patch;
    XCTAssertEqual(expected, vhex);
}

- (void)test_cthexversion_Compares_Major_Properly
{
    const struct ct_version smaller = { 2, 1, 1 };
    const struct ct_version bigger = { 3, 1, 1 };
    
    const uint32_t shex = ct_versionhex(&smaller);
    const uint32_t bhex = ct_versionhex(&bigger);
    
    XCTAssertLessThan(shex, bhex);
}

- (void)test_cthexversion_Compares_Minor_Properly
{
    const struct ct_version smaller = { 2, 9, 1 };
    const struct ct_version bigger = { 2, 12, 1 };
    
    const uint32_t shex = ct_versionhex(&smaller);
    const uint32_t bhex = ct_versionhex(&bigger);
    
    XCTAssertLessThan(shex, bhex);
}

- (void)test_cthexversion_Compares_Patch_Properly
{
    const struct ct_version smaller = { 2, 5, 23 };
    const struct ct_version bigger = { 2, 5, 154 };
    
    const uint32_t shex = ct_versionhex(&smaller);
    const uint32_t bhex = ct_versionhex(&bigger);
    
    XCTAssertLessThan(shex, bhex);
}

@end
