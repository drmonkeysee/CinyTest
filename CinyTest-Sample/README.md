# CinyTest Sample

This project illustrates the integration of CinyTest into Xcode to test a binary tree module written in C. The project contains two targets:

- **CinyTest-Sample**: a console app that defines a binary tree type, creates an instance of a binary tree, and prints information about it to stdout.
- **CinyTest-SampleTests**: an [XCTest] bundle that uses CinyTest to unit test the binary tree. This project shows how [XCTest] can be used to boostrap CinyTest into Xcode using an `XCTestCase` class.

## Running the Sample

To run the tests either open the project directly or select the **CinyTest-Sample** scheme in the CinyTest workspace. The "Run" action will run the console app which demonstrates a simple use of the binary tree type. The "Test" action will execute the [XCTest] bundle and run the CinyTest binary tree tests. The output will be found in Xcode's output window.

[XCTest]: https://developer.apple.com/library/ios/documentation/ToolsLanguages/Conceptual/Xcode_Overview/UnitTestYourApp/UnitTestYourApp.html