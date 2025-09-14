Test Makefile - Shared testing system

Usage:
  EXECUTABLE=./your_program make test          # Run all tests (show only failures)
  EXECUTABLE=./your_program make test-verbose  # Run all tests (show all)
  EXECUTABLE=./your_program make test-single TEST=tests/test_name  # Run single test

Environment Variables:
  EXECUTABLE - Path to the executable to test (default: ./main)
  COMPARATOR - Path to the comparator script (default: python3 compare.py)

Files Required:
  compare.py - Output comparison script (must be in current directory)

Test Structure:
  Each test should be in tests/<test_name>/ with:
    - in.txt  (input)
    - out.txt (expected output)

Examples:
  EXECUTABLE=./my_program make test
  EXECUTABLE=python3 my_script.py make test
  EXECUTABLE=java MyClass make test
