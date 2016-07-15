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

CinyTest was developed using Xcode so the primary way to build it would be with the Xcode project under the **mac** folder. There is also a [Makefile] that will build CinyTest for either macOS ([clang] by default) or Linux ([gcc] by default). The Xcode project and the [Makefile] will give you identical libraries on macOS so pick whichever build method is more convenient.

The [Makefile] has the following build targets:

- `release`: the default target; build CinyTest library and binary tree sample executables with full optimizations
- `debug`: build CinyTest library and binary tree sample executables with debug symbols and no optimizations
- `check`: verify CinyTest by running the sample tests
- `clean`: delete all build artifacts; run this when switching between debug and release builds to make sure all artifacts are rebuilt

All of the [Makefile] artifacts are placed in a folder named **build**.

## Repo Structure

The CinyTest repo is structured fairly traditionally for a C/C++ project. **src** contains all source code and headers, **test** contains all test-related source code and headers, and **doc** contains a [Doxygen] configuration file. The generated documentation is packaged as part of the zip files found under the releases tab in GitHub.

The macOS-specific IDE files are all contained under the **mac** folder. There is a single Xcode project made up of the following targets:

- **CinyTest**: main target for CinyTest source code and unit tests; builds the CinyTest static library and runs the XCTest unit tests
- **Sample**: additional target illustrating the use of CinyTest to test a binary tree module; includes command-line binary to exercise the binary tree module and an XCTest class for bootstrapping the binary tree unit tests into Xcode

## Example

A simple example demonstrating the use of CinyTest as an external dependency can be found in the [CinyTest-Example](https://github.com/drmonkeysee/CinyTest-Example) repo.

Running this example on the command line (assuming all tests pass) will output something like the following:

	====-- CinyTest Run --====
	Starting test suite 'main' at 2014-10-26 04:27:35
	Running 4 tests:
	[✔] - 'makerectangle_createsrectangle' success
	[✔] - 'rectanglearea_calculatesarea' success
	[✔] - 'rectanglehypotenuse_calculateshypotenuse' success
	[✔] - 'rectangletostring_buildsrectanglestring' success
	Test suite 'main' completed at 2014-10-26 04:27:35
	Ran 4 tests (0.009 seconds): 4 passed, 0 failed, 0 ignored.
	====-- CinyTest End --====

## Why CinyTest?

The idea for CinyTest arose out of an exploration of the current landscape of C unit testing frameworks. I was looking for a test library that specifically targeted C instead of C++ and did not require standalone executables or linker tricks. I wanted a library that could be used within an IDE for red-green-refactor test-driven development.

Many C test frameworks did not fit the bill; some required make files as part of the execution cycle, others needed per-suite linker flags or multiple `main` function definitions. Some frameworks I found could be run in an IDE but were either heavier than I wanted or had what I felt were awkward or dated APIs. I decided to write my own and CinyTest is the result.

[cmocka]'s design provided initial inspiration for CinyTest. While the design goals of the two libraries are different, [cmocka]'s API was a guide for the generality and brevity I wanted to achieve with CinyTest.

CinyTest provides a straightforward and terse public API for writing unit tests in C. While CinyTest does not integrate *directly* into an IDE test framework (due to lack of tool support) it is trivial to include bare-bones driver code to hook into any test framework of choice while still maintaining all the actual test code in native C.

In the sample code included in the CinyTest project, CinyTest is bootstrapped into XCTest using a small Objective-C test class. A similar approach would work for any other programming environment that can interoperate with C. In addition CinyTest could be run as a native C executable by defining and calling any test suites within a `main` function, which could then be built and run using whatever tool fits your needs. This approach is shown in the [CinyTest-Example](https://github.com/drmonkeysee/CinyTest-Example) repo and as the `check` build target in the Makefile.

### Constraints and Assumptions

While I hope CinyTest is useful to others it is also a hobby exercise of mine. Its criteria fit my specific use case and I approached the problem in a very deliberate way. I wanted to see if I could write a library that used no platform-specific compiler features and targeted the latest C language standard, C11.

I had to dive into platform-specific code in one case: macOS does not yet implement `timespec_get()` in **time.h** so I had to fall back to the POSIX function `gettimeofday()` in **sys/time.h** to get millisecond time resolution when measuring elapsed time of a test run. The platform functions are isolated to **ciny_posix.c** behind a standards-compliant interface declared in **ciny.c** (since they are not intended to be public functions). This makes it easy to include or exclude the file and allow a non-POSIX platform to provide its own definitions at build time.

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

### A Word on Warnings

CinyTest uses variadic macros for its test assertions. The call signature has an optional assert message and can be called either as `ct_assert_true(foo)` or `ct_assert_true(foo, "Expected true expression")`.

However if you compile with `-pedantic` the `ct_assert_true(foo)` form will trigger a missing variadic arguments warning. This can be suppressed either by always specifying an assert message (as shown above) or by including a trailing comma which satisfies the preprocessor: `ct_assert_true(foo,)`. In addition any tests that don't use the test context parameter will trigger unused parameter warnings. This can be suppressed by casting the argument to void: `(void)context;`.

I always strive for zero warnings for production code; CinyTest itself has no warnings under `-Wall -Wextra -pedantic`. However I tend to be more lax for test code so I would likely omit the warnings for unit tests using CinyTest. In my experience all warnings triggered by usage of CinyTest would be caught by `-Wno-unused-parameter -Wno-gnu-zero-variadic-macro-arguments` (gcc does not define the latter flag so use `-Wno-pedantic` on test builds). If that's an unappealing option then use one of the syntax remedies described above.

The Xcode targets strive for the same degree of warning rigor as the Makefile. This is accomplished for CinyTest, the sample executable, and the sample tests written with CinyTest (using the above caveats). However XCTest uses some GNU extensions and a couple macros that trigger pedantic warnings so the warning level begins with `-Wall -Wextra -pedantic` but selectively scales back certain warnings as necessary either on the target or as compiler pragmas.

### How do I pronounce CinyTest?

I don't know. The name is a visual pun on "C" and "Tiny". Some possibilities:

- TinyTest
- ChinyTest
- SinyTest
- ShinyTest
- ???

## Dev Wishlist

List of features I would like to eventually add to CinyTest:

- test auto registration
- stub function support
- mock function support

[clang]: http://clang.llvm.org
[gcc]: https://gcc.gnu.org
[cl.exe]: http://msdn.microsoft.com/en-us/library/9s7c9wdw.aspx
[cmocka]: http://cmocka.org
[Doxygen]: http://www.doxygen.org
[Makefile]: http://www.gnu.org/software/make/
