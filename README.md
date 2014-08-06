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

## Project Structure

## Why CinyTest?

The idea for CinyTest arose out of an exploration of the existing landscape of C unit testing frameworks. I was looking for a test library that specifically targeted C instead of C++ and did not require standalone executables or linker tricks in order to define or run tests. I wanted a library that could be used within an IDE for red-green-refactor test-driven development.

Many C test frameworks did not fit the bill; some required Make files as part of the execution cycle, others needed per-suite linker flags or multiple `main` function definitions. Some frameworks I found could be run in an IDE but were either heavier than I wanted or had what I felt were awkward or dated APIs. I decided to try writing my own.

CMocka's design provided initial inspiration for CinyTest. While the design goals of the two libraries are different, CMocka's API was a guide for the generality and brevity I wanted to achieve with CinyTest.

As can be seen in the sample project included in this repo, CinyTest is easy to use as a test framework for C code. While CinyTest does not integrate *directly* into an IDE test framework (due to lack of tool support) it is trivial to include bare-bones driver code to hook into any test framework of choice while still maintaining all the actual test code in native C.

In the sample code included in the CinyTest workspace, CinyTest is bootstrapped into **XCTest** using a very simple Objective-C test class. A similar approach would work for any other programming environment that can interoperate with C. In addition CinyTest could be run as a native C executable by defining and calling any test suites within a `main` function, for anyone desiring the more authentic command-line programming environment of old-school C. This approach is shown in the Example section of this document.

### Constraints and Assumptions

While I hope CinyTest is useful to others it is also a hobby exercise of mine. Its criteria fit my specific use case and I approached the problem in a very deliberate way. I wanted to see if I could write a library that used no vendor-specific compiler features and targeted the latest C language standard, C11. It uses C11 features that are, as of this writing, not widely available.

It was developed on Xcode 5 using Clang and should work with any modern C11-compliant compiler. Currently that only includes Clang. It *may* work with gcc. It will almost certainly not work with Microsoft's C compiler (cl.exe), nor does it make any effort to target other less common C compilers or embedded system compilers.

CinyTest relies on the following C11 features:

- \_Generic
- \_Static\_assert
- \_Noreturn
- Anonymous unions

CinyTest also assumes the presence of the following optional C11 features:

- \_Complex type and its associated mathematical functions (does not assume \_Imaginary type)
- \_Atomic types

### How do I pronounce CinyTest?

- TinyTest
- ChinyTest
- SinyTest
- ShinyTest
- ???

## Next Features
