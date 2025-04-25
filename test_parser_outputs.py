#!/usr/bin/env python3

import subprocess
import sys
import os

REFERENCE_PARSER = "/afs/ir/class/cs143/bin/parser"
LEXER = "./lexer"
CUSTOM_PARSER = "./parser"
EXAMPLES_DIR = "/afs/ir/class/cs143/examples/"

def run_pipeline(file_name, parser_cmd):
    file_path = os.path.join(EXAMPLES_DIR, file_name)
    lexer_process = subprocess.Popen([LEXER, file_path], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    parser_process = subprocess.Popen(parser_cmd, stdin=lexer_process.stdout, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    lexer_process.stdout.close()
    out, err = parser_process.communicate()
    return out.decode('utf-8').splitlines(), err.decode('utf-8').splitlines()

def compare_outputs(file_name):
    print(f"Testing file: {file_name}")
    ref_out, ref_err = run_pipeline(file_name, [REFERENCE_PARSER])
    custom_out, custom_err = run_pipeline(file_name, [CUSTOM_PARSER])

    # Compare stdout line by line
    for i, (ref_line, custom_line) in enumerate(zip(ref_out, custom_out), start=1):
        if ref_line != custom_line:
            print(f"❌ Mismatch at line {i} of stdout:")
            print(f"Reference: {ref_line}")
            print(f"Custom   : {custom_line}")
            sys.exit(1)

    # Check if one output is longer than the other
    if len(ref_out) != len(custom_out):
        print(f"❌ Output length mismatch in stdout.")
        print(f"Reference has {len(ref_out)} lines, custom has {len(custom_out)} lines.")
        sys.exit(1)

    # Same for stderr
    for i, (ref_line, custom_line) in enumerate(zip(ref_err, custom_err), start=1):
        if ref_line != custom_line:
            print(f"❌ Mismatch at line {i} of stderr:")
            print(f"Reference: {ref_line}")
            print(f"Custom   : {custom_line}")
            sys.exit(1)

    if len(ref_err) != len(custom_err):
        print(f"❌ Output length mismatch in stderr.")
        print(f"Reference has {len(ref_err)} lines, custom has {len(custom_err)} lines.")
        sys.exit(1)

    print("✅ Output matches reference parser.\n")

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 test_parser_outputs.py FILE1.cl [FILE2.cl ...]")
        sys.exit(1)

    for file_name in sys.argv[1:]:
        compare_outputs(file_name)

if __name__ == "__main__":
    main()
