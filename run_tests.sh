#!/bin/bash

# Name of your test file
TEST_FILE="test-spec.cl"

# Run the reference parser
./lexer "$TEST_FILE" | /afs/ir/class/cs143/bin/parser > ref_output.txt

# Run your own parser
./myparser "$TEST_FILE" > my_output.txt

# Compare outputs
if diff -u ref_output.txt my_output.txt > diff_output.txt; then
    echo "✅ Outputs match!"
else
    echo "❌ Outputs differ! Showing diff:"
    cat diff_output.txt
fi