//
//  CTCaptureOutputOptionTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 9/3/17.
//  Copyright © 2017 Brandon Stansbury. All rights reserved.
//

#import "CTOutputAssertionTestBase.h"
#include <unistd.h>
#include <stdio.h>
#include <fcntl.h>

@interface CTSuppressOutputOptionTests : CTOutputAssertionTestBase

@end

@implementation CTSuppressOutputOptionTests

- (void)test_suppressOutputEnabledByDefault
{
    printf("BEFORE DUP\n");
    const int std_out = dup(fileno(stdout));
    const int dev_null = open("/dev/null", O_WRONLY);
    printf("BEFORE DUP2\n");
    fflush(stdout);
    int result = dup2(dev_null, fileno(stdout));
    printf("SHOULDN'T SEE\n");
    FILE *my_stdout = fdopen(std_out, "w");
    fprintf(my_stdout, "SHOULD SEE\n");
    fflush(stdout);
    fflush(my_stdout);
    // don't close before dup2
    //fclose(my_stdout);
    dup2(std_out, fileno(stdout));
    fclose(my_stdout);
    // close unnecessary after fclose
    //close(std_out);
    printf("AFTER RESTORE\n");
}

@end
