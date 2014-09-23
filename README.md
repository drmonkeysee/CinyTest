# CinyTest

CinyTest is a lightweight library for defining and running unit tests in C.

## Features

- unit test and suite creation
- unit suite execution, including setup and teardown support
- detailed test run output to stdout
- test assertions including:
    - value equality, including approximate equality for floating point
    - pointer equality and NULL testing
    - C-string equality
    - general true/false asserts

## Build CinyTest

CinyTest was developed using Xcode; on OS X the workspace will build the library with [clang]. The workspace is current for Xcode 6. There is also a [make] file that will build CinyTest using [gcc].

The [make] file has the following build targets:

- `build`: the default target
- `clean`: delete all [make] file artifacts
- `rebuild`: `clean`, then `build`

All of the [make] file artifacts are placed in a folder named **makebuild**.

## Project Structure

CinyTest consists of a header file and two source files: **ciny.h**, **ciny.c**, and **ciny_posix.c**. CinyTest was developed in Xcode and uses the project structure for that IDE, though a [make] file is available. Of course a unit testing library should itself be tested, so CinyTest has a battery of unit tests written in XCTest. The notable parts of the repository are:

- **CinyTest**: main project consisting of CinyTest code and XCTest unit tests. builds the library and runs the tests.
- **CinyTest-Sample**: sample project illustrating the use of CinyTest to test a binary tree module.
- **Documentation**: a [Doxygen] configuration file for the CinyTest header file. the generated doc files are packaged as part of the zip files found under the releases tab in GitHub.

## Example

This example shows how to test a simple rectangle module. For a more extensive example see the **CinyTest-Sample** project in the workspace included in this repository. For a complete listing of CinyTest features consult the API documentation included in the release zip or header file.

### Rectangle.h
```c
#ifndef Rectangle_h
#define Rectangle_h

/////
// Rectangle definition
/////

struct rectangle {
    int width;
    int height;
};

/////
// Rectangle module operations
/////

struct rectangle make_rectangle(int width, int height);

int rectangle_area(struct rectangle rect);

double rectangle_hypotenuse(struct rectangle rect);

int rectangle_tostring(struct rectangle rect, char *output, size_t size);

#endif
```

### RectangleTests.c
```c
#include <ciny.h>
#include "Rectangle.h"

/////
// Unit Tests for Rectangle module
/////

static void makerectangle_createsrectangle(void *context)
{
    int expected_width = 8;
    int expected_height = 5;
    
    struct rectangle rect = make_rectangle(expected_width, expected_height);
    
    ct_assertequal(expected_width, rect.width);
    ct_assertequal(expected_height, rect.height);
}

static void rectanglearea_calculatesarea(void *context)
{
    struct rectangle rect = make_rectangle(8, 5);
    
    int area = rectangle_area(rect);
    
    ct_assertequal(40, area);
}

static void rectanglehypotenuse_calculateshypotenuse(void *context)
{
    struct rectangle rect = make_rectangle(3, 7);
    
    double hypo = rectangle_hypotenuse(rect);
    
    ct_assertaboutequal(7.62, hypo, 0.01);
}

static void rectangletostring_buildsrectanglestring(void *context)
{
    struct rectangle rect = make_rectangle(6, 8);
    char output[50];
    
    int characters_written = rectangle_tostring(rect, output, sizeof(output));
    
    ct_asserttrue(characters_written < sizeof(output), "Test buffer too small for rectangle_tostring");
    ct_assertequalstr("Rectangle { w: 6, h: 8 }", output);
}

/////
// Main driver function; returns non-zero if any tests failed.
/////

int main(int argc, char *argv[])
{
    struct ct_testcase tests[] = {
        ct_maketest(makerectangle_createsrectangle),
        ct_maketest(rectanglearea_calculatesarea),
        ct_maketest(rectanglehypotenuse_calculateshypotenuse),
        ct_maketest(rectangletostring_buildsrectanglestring)
    };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t results = ct_runsuite(&suite);
    
    return results != 0;
}
```

Running this program on the command line (assuming all tests pass) will output:

    ====-- CinyTest Run --====
    Starting test suite 'main' at 2014-09-07 20:37:30
    Running 4 tests:
    [✔] - 'makerectangle_createsrectangle' success
    [✔] - 'rectanglearea_calculatesarea' success
    [✔] - 'rectanglehypotenuse_calculateshypotenuse' success
    [✔] - 'rectangletostring_buildsrectanglestring' success
    Test suite 'main' completed at 2014-09-07 20:37:30
    Ran 4 tests (0.003 seconds): 4 passed, 0 failed, 0 ignored.
    ====-- CinyTest End --====

For reference here is the Rectangle module definition used to run the example code and verify its correctness.

### Rectangle.c
```c
#include <stdio.h>
#include <math.h>
#include "Rectangle.h"

struct rectangle make_rectangle(int width, int height)
{
    return (struct rectangle){ width, height };
}

int rectangle_area(struct rectangle rect)
{
    return rect.width * rect.height;
}

double rectangle_hypotenuse(struct rectangle rect)
{
    return sqrt(pow(rect.width, 2) + pow(rect.height, 2));
}

int rectangle_tostring(struct rectangle rect, char *output, size_t size)
{
    static const char * const restrict template = "Rectangle { w: %d, h: %d }";
    int num_chars = snprintf(output, size, template, rect.width, rect.height);
    return num_chars;
}
```

## Why CinyTest?

The idea for CinyTest arose out of an exploration of the current landscape of C unit testing frameworks. I was looking for a test library that specifically targeted C instead of C++ and did not require standalone executables or linker tricks. I wanted a library that could be used within an IDE for red-green-refactor test-driven development.

Many C test frameworks did not fit the bill; some required make files as part of the execution cycle, others needed per-suite linker flags or multiple `main` function definitions. Some frameworks I found could be run in an IDE but were either heavier than I wanted or had what I felt were awkward or dated APIs. I decided to write my own and CinyTest is the result.

[cmocka]'s design provided initial inspiration for CinyTest. While the design goals of the two libraries are different, [cmocka]'s API was a guide for the generality and brevity I wanted to achieve with CinyTest.

CinyTest provides a straightforward and terse public API for writing unit tests in C. While CinyTest does not integrate *directly* into an IDE test framework (due to lack of tool support) it is trivial to include bare-bones driver code to hook into any test framework of choice while still maintaining all the actual test code in native C.

In the sample code included in the CinyTest workspace, CinyTest is bootstrapped into XCTest using a small Objective-C test class. A similar approach would work for any other programming environment that can interoperate with C. In addition CinyTest could be run as a native C executable by defining and calling any test suites within a `main` function, which could then be built and run using whatever tool fits your needs. This approach is shown in the Example section of this document.

### Constraints and Assumptions

While I hope CinyTest is useful to others it is also a hobby exercise of mine. Its criteria fit my specific use case and I approached the problem in a very deliberate way. I wanted to see if I could write a library that used no platform-specific compiler features and targeted the latest C language standard, C11.

I had to dive into platform-specific code in one case: OS X does not yet implement `timespec_get()` in **time.h** so I had to fall back to the POSIX function `gettimeofday()` in **sys/time.h** to get millisecond time resolution when measuring elapsed time of a test run. The platform functions are isolated to **ciny_posix.c** behind a standards-compliant interface declared in **ciny.c** (since they are not intended to be public functions). This makes it easy to include or exclude the file and allow a non-POSIX platform to provide its own definitions at build time.

CinyTest uses C11 features that are, as of this writing, available largely on POSIX platforms only. It was developed on Xcode using [clang] and should work with any modern C11-compliant compiler. It has been tested with [clang] and [gcc]. It will almost certainly not work with [cl.exe], nor does it make any effort to target other less common C compilers or embedded system compilers.

CinyTest relies on the following C11 features:

- `_Generic`
- `_Static_assert`
- `_Noreturn`
- Anonymous unions

CinyTest also assumes the presence of the following optional C11 features:

- `_Complex` type and its associated mathematical functions (does not assume `_Imaginary` type)
- `_Atomic` types

CinyTest's header includes (and is dependent upon) the following standard library headers:

- `stddef.h`
- `limits.h`
- `stdint.h`

### How do I pronounce CinyTest?

I don't know. The name is a visual pun on "C" and "Tiny". Some possibilities:

- TinyTest
- ChinyTest
- SinyTest
- ShinyTest
- ???

## Dev Wishlist

List of features I would like to eventually add to CinyTest:

- ability to route output to channels other than stdout
- stub function support
- mock function support

[clang]: http://clang.llvm.org
[gcc]: https://gcc.gnu.org
[cl.exe]: http://msdn.microsoft.com/en-us/library/9s7c9wdw.aspx
[cmocka]: http://cmocka.org
[Doxygen]: http://www.doxygen.org
[make]: http://www.gnu.org/software/make/
