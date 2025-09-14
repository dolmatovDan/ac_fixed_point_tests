# Test Makefile - Shared testing system
# Usage: EXECUTABLE=./your_program make test

# Test executable (can be overridden with EXECUTABLE env var)
EXECUTABLE ?= ./main

# Comparator script
COMPARATOR ?= python3 compare.py

# Check if executable exists
check-executable:
	@if [ ! -f "$(EXECUTABLE)" ] && [ ! -f "$$(echo $(EXECUTABLE) | sed 's|^\./||')" ]; then \
		echo "Error: Executable '$(EXECUTABLE)' not found!"; \
		echo "Please set EXECUTABLE environment variable or ensure the executable exists."; \
		echo "Usage: EXECUTABLE=./your_program make test"; \
		exit 1; \
	fi

# Check if comparator exists
check-comparator:
	@if ! command -v python3 >/dev/null 2>&1; then \
		echo "Error: python3 not found! Please install Python 3."; \
		exit 1; \
	fi
	@if [ ! -f "compare.py" ]; then \
		echo "Error: compare.py not found!"; \
		echo "Please ensure compare.py is in the current directory."; \
		exit 1; \
	fi

# Run all tests (only shows failed tests)
test: check-executable check-comparator
	@echo "Running all tests..."
	@test_count=0; \
	passed_count=0; \
	failed_count=0; \
	for test_dir in tests/*/; do \
		if [ -d "$$test_dir" ]; then \
			test_name=$$(basename "$$test_dir"); \
			test_count=$$((test_count + 1)); \
			actual_output=$$($(EXECUTABLE) < "$$test_dir"in.txt); \
			if $(COMPARATOR) "$$test_dir"out.txt "$$actual_output" >/dev/null 2>&1; then \
				passed_count=$$((passed_count + 1)); \
			else \
				echo "Running test: $$test_name"; \
				echo "Input: $$(cat "$$test_dir"in.txt)"; \
				echo "Expected output: $$(cat "$$test_dir"out.txt)"; \
				echo "Actual output:"; \
				echo "$$actual_output"; \
				echo "✗ FAILED"; \
				failed_count=$$((failed_count + 1)); \
				echo ""; \
			fi; \
		fi; \
	done; \
	echo "Test Summary: $$passed_count/$$test_count passed, $$failed_count failed"

# Run all tests (verbose version - shows all tests)
test-verbose: check-executable check-comparator
	@echo "Running all tests with verbose output..."
	@test_count=0; \
	passed_count=0; \
	failed_count=0; \
	for test_dir in tests/*/; do \
		if [ -d "$$test_dir" ]; then \
			test_name=$$(basename "$$test_dir"); \
			test_count=$$((test_count + 1)); \
			echo "=========================================="; \
			echo "Test directory: $$test_dir"; \
			echo "Test name: $$test_name"; \
			echo "Input: $$(cat "$$test_dir"in.txt)"; \
			echo "Expected output: $$(cat "$$test_dir"out.txt)"; \
			echo "Actual output:"; \
			actual_output=$$($(EXECUTABLE) < "$$test_dir"in.txt); \
			echo "$$actual_output"; \
			if $(COMPARATOR) "$$test_dir"out.txt "$$actual_output" >/dev/null 2>&1; then \
				echo "✓ PASSED"; \
				passed_count=$$((passed_count + 1)); \
			else \
				echo "✗ FAILED"; \
				echo "Expected: '$$(cat "$$test_dir"out.txt)'"; \
				echo "Got: '$$actual_output'"; \
				failed_count=$$((failed_count + 1)); \
			fi; \
			echo "=========================================="; \
			echo ""; \
		fi; \
	done; \
	echo "Test Summary: $$passed_count/$$test_count passed, $$failed_count failed"

# Run specific test (usage: make test-single TEST=tests/mult_0_1)
test-single: check-executable check-comparator
	@if [ -z "$(TEST)" ]; then \
		echo "Usage: make test-single TEST=<test_directory_name>"; \
		echo "Example: make test-single TEST=tests/mult_0_1"; \
		echo "Available tests:"; \
		for test_dir in tests/*/; do \
			if [ -d "$$test_dir" ]; then \
				echo "  $$(basename "$$test_dir")"; \
			fi; \
		done; \
		exit 1; \
	fi
	@if [ ! -d "$(TEST)" ]; then \
		echo "Test directory $(TEST) not found!"; \
		echo "Available tests:"; \
		for test_dir in tests/*/; do \
			if [ -d "$$test_dir" ]; then \
				echo "  $$(basename "$$test_dir")"; \
			fi; \
		done; \
		exit 1; \
	fi
	@if [ ! -f "$(TEST)/in.txt" ]; then \
		echo "Input file $(TEST)/in.txt not found!"; \
		exit 1; \
	fi
	@if [ ! -f "$(TEST)/out.txt" ]; then \
		echo "Expected output file $(TEST)/out.txt not found!"; \
		exit 1; \
	fi
	@echo "=========================================="; \
	echo "Test directory: $(TEST)"; \
	echo "Input: $$(cat "$(TEST)/in.txt")"; \
	echo "Expected output: $$(cat "$(TEST)/out.txt")"; \
	echo "Actual output:"; \
	actual_output=$$($(EXECUTABLE) < "$(TEST)/in.txt"); \
	echo "$$actual_output"; \
	if $(COMPARATOR) "$(TEST)/out.txt" "$$actual_output" >/dev/null 2>&1; then \
		echo "✓ PASSED"; \
	else \
		echo "✗ FAILED"; \
		echo "Expected: '$$(cat "$(TEST)/out.txt")'"; \
		echo "Got: '$$actual_output'"; \
	fi; \
	echo "=========================================="

# Show help
help:
	@echo "Test Makefile - Shared testing system"
	@echo ""
	@echo "Usage:"
	@echo "  EXECUTABLE=./your_program make test          # Run all tests (show only failures)"
	@echo "  EXECUTABLE=./your_program make test-verbose  # Run all tests (show all)"
	@echo "  EXECUTABLE=./your_program make test-single TEST=tests/test_name  # Run single test"
	@echo ""
	@echo "Environment Variables:"
	@echo "  EXECUTABLE - Path to the executable to test (default: ./main)"
	@echo "  COMPARATOR - Path to the comparator script (default: python3 compare.py)"
	@echo ""
	@echo "Files Required:"
	@echo "  compare.py - Output comparison script (must be in current directory)"
	@echo ""
	@echo "Test Structure:"
	@echo "  Each test should be in tests/<test_name>/ with:"
	@echo "    - in.txt  (input)"
	@echo "    - out.txt (expected output)"
	@echo ""
	@echo "Examples:"
	@echo "  EXECUTABLE=./my_program make test"
	@echo "  EXECUTABLE=python3 my_script.py make test"

# Phony targets
.PHONY: test test-verbose test-single check-executable check-comparator help
