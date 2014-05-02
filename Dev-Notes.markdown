# Dev Notes

- basic assertions
    - assert fail
    - assert true
    - assert false
    - assert null
    - assert not null
    - assert equal
    - assert not equal
    - assert equal within epsilon
    - assert not equal within epsilon
- setup / teardown
- define suite list
- suite = list of tests + name + optional setup/teardown
- stdout/stderr output with color
- string comparison
- struct comparison
- memory comparison
- create stub and mock functions?
- ignore tests

## OutputFormat

Started test suite 'File+Function or Given Name' at DateTime.

Running count tests:

[✓ (\u2713, green)] - test name success (seconds)

[✗ (\u2717, red)] - test name failure (seconds)

Failure message : File Name : Line Number

Test suite 'File+Function or Given Name' completed at DateTime.

Ran count tests (seconds): x passed, x failed, x ignored.

## TODO

- does setup/teardown error count as test failure?
