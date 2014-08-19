# CinyTest

CinyTest is a simple unit-test library for C. CinyTest provides a lightweight set of tools to write and run suites of unit tests.

## Features

- unit test and suite creation
- unit suite execution and output
- test assertions including:
    - value equality, including approximate equality for floating point
    - pointer equality and NULL testing
    - C-string equality
    - general true/false asserts

## Build CinyTest

Add make file

## Example

A simple example testing a rectangle module that shows how to create and call unit test suites and use some of the test assertions in CinyTest.

**Rectangle.h**

```c
#ifndef Rectangle_h
#define Rectangle_h

/////
// Rectangle struct definition
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

**RectangleTests.c**
```c
#include <stdlib.h>
#include <ciny.h>
#include "Rectangle.h"

/////
// Setup and Teardown functions to set buffer for tostring tests
/////

static const size_t buffer_size = 50;

static void rect_tests_setup(void **context)
{
    *context = malloc(buffer_size);
}

static void rect_tests_teardown(void **context)
{
    free(*context);
}

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
    char *output = (char *)context;
    
    int characters_written = rectangle_tostring(rect, output, buffer_size);
    
    ct_asserttrue(characters_written < buffer_size, "Test buffer too small for rectangle_tostring");
    ct_assertequalstr("Rectangle { w: 6, h: 8 }", output);
}

/////
// Main driver function; return non-zero if any tests failed.
/////

int main(int argc, char *argv[])
{
    struct ct_testcase tests[] = {
        ct_maketest(makerectangle_createsrectangle),
        ct_maketest(rectanglearea_calculatesarea),
        ct_maketest(rectanglehypotenuse_calculateshypotenuse),
        ct_maketest(rectangletostring_buildsrectanglestring)
    };
    struct ct_testsuite suite = ct_makesuite_setup_teardown(tests, rect_tests_setup, rect_tests_teardown);
    
    size_t results = ct_runsuite(&suite);
    
    printf("uh oh, %zu tests failed!", results);
    
    return results != 0;
}
```

## Project Structure

CinyTest is made up of a single header file and source file: **ciny.h** and **ciny.c**. To build and use CinyTest only these two files are needed. It was developed in Xcode and is made up of two projects:

- **CinyTest** - main project consisting of CinyTest code and [XCTest] classes that test CinyTest. builds CinyTest and runs the CinyTest unit tests.
- **CinyTest-Sample** - sample project illustrating the use of CinyTest to unit test a simple binary tree module.

## Why CinyTest?

The idea for CinyTest arose out of an exploration of the existing landscape of C unit testing frameworks. I was looking for a test library that specifically targeted C instead of C++ and did not require standalone executables or linker tricks in order to define or run tests. I wanted a library that could be used within an IDE for red-green-refactor test-driven development.

Many C test frameworks did not fit the bill; some required Make files as part of the execution cycle, others needed per-suite linker flags or multiple `main` function definitions. Some frameworks I found could be run in an IDE but were either heavier than I wanted or had what I felt were awkward or dated APIs. I decided to try writing my own.

[cmocka]'s design provided initial inspiration for CinyTest. While the design goals of the two libraries are different, [cmocka]'s API was a guide for the generality and brevity I wanted to achieve with CinyTest.

As can be seen in the sample project included in this repo, CinyTest is easy to use as a test framework for C code. While CinyTest does not integrate *directly* into an IDE test framework (due to lack of tool support) it is trivial to include bare-bones driver code to hook into any test framework of choice while still maintaining all the actual test code in native C.

In the sample code included in the CinyTest workspace, CinyTest is bootstrapped into [XCTest] using a very simple Objective-C test class. A similar approach would work for any other programming environment that can interoperate with C. In addition CinyTest could be run as a native C executable by defining and calling any test suites within a `main` function, for anyone desiring the more authentic command-line programming environment of old-school C. This approach is shown in the Example section of this document.

### Constraints and Assumptions

While I hope CinyTest is useful to others it is also a hobby exercise of mine. Its criteria fit my specific use case and I approached the problem in a very deliberate way. I wanted to see if I could write a library that used no vendor-specific compiler features and targeted the latest C language standard, C11. It uses C11 features that are, as of this writing, not widely available.

It was developed on Xcode 5 using [clang] and should work with any modern C11-compliant compiler. Currently that only includes [clang]. It *may* work with [gcc]. It will almost certainly not work with [cl.exe], nor does it make any effort to target other less common C compilers or embedded system compilers.

CinyTest relies on the following C11 features:

- `_Generic`
- `_Static_assert`
- `_Noreturn`
- Anonymous unions

CinyTest also assumes the presence of the following optional C11 features:

- `_Complex` type and its associated mathematical functions (does not assume \_Imaginary type)
- `_Atomic` types

### How do I pronounce CinyTest?

- TinyTest
- ChinyTest
- SinyTest
- ShinyTest
- ???

## Next Features

[XCTest]: https://developer.apple.com/library/ios/documentation/ToolsLanguages/Conceptual/Xcode_Overview/UnitTestYourApp/UnitTestYourApp.html
[clang]: http://clang.llvm.org
[gcc]: https://gcc.gnu.org
[cl.exe]: http://msdn.microsoft.com/en-us/library/9s7c9wdw.aspx
[cmocka]: http://cmocka.org
