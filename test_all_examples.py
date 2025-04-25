#!/usr/bin/env python3

import subprocess
import os
import sys
import re

REFERENCE_PARSER = "/afs/ir/class/cs143/bin/parser"
LEXER = "./lexer"
CUSTOM_PARSER = "./parser"
EXAMPLES_DIR = "/afs/ir/class/cs143/examples/"

def normalize_line(line):
    # Remove line numbers like "#5", "#12", etc.
    return re.sub(r'#\d+', '#LINE', line)

def run_pipeline(file_path, parser_cmd):
    lexer_process = subprocess.Popen([LEXER, file_path], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    parser_process = subprocess.Popen(parser_cmd, stdin=lexer_process.stdout, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    lexer_process.stdout.close()
    out, err = parser_process.communicate()
    return out.decode('utf-8').splitlines(), err.decode('utf-8').splitlines()

def compare_outputs(file_path):
    ref_out, ref_err = run_pipeline(file_path, [REFERENCE_PARSER])
    custom_out, custom_err = run_pipeline(file_path, [CUSTOM_PARSER])

    # Normalize lines to ignore line numbers
    ref_out = [normalize_line(line) for line in ref_out]
    custom_out = [normalize_line(line) for line in custom_out]
    ref_err = [normalize_line(line) for line in ref_err]
    custom_err = [normalize_line(line) for line in custom_err]

    # Compare stdout
    for i, (ref_line, custom_line) in enumerate(zip(ref_out, custom_out), start=1):
        if ref_line != custom_line:
            print(f"❌ Mismatch in stdout at line {i} for file: {file_path}")
            print(f"Reference: {ref_line}")
            print(f"Custom   : {custom_line}")
            return False

    if len(ref_out) != len(custom_out):
        print(f"❌ Output length mismatch in stdout for file: {file_path}")
        return False

    # Compare stderr
    for i, (ref_line, custom_line) in enumerate(zip(ref_err, custom_err), start=1):
        if ref_line != custom_line:
            print(f"❌ Mismatch in stderr at line {i} for file: {file_path}")
            print(f"Reference: {ref_line}")
            print(f"Custom   : {custom_line}")
            return False

    if len(ref_err) != len(custom_err):
        print(f"❌ Output length mismatch in stderr for file: {file_path}")
        return False

    print(f"✅ {file_path} passed.\n")
    return True

def main():
    try:
        files = sorted([
            f for f in os.listdir(EXAMPLES_DIR)
            if os.path.isfile(os.path.join(EXAMPLES_DIR, f)) and f.endswith(".cl")
        ])
    except FileNotFoundError:
        print(f"Could not find examples directory: {EXAMPLES_DIR}")
        sys.exit(1)

    if not files:
        print("No .cl files found in examples directory.")
        sys.exit(1)

    failed = []
    for file_name in files:
        file_path = os.path.join(EXAMPLES_DIR, file_name)
        if not compare_outputs(file_path):
            failed.append(file_name)

    print("=== Test Summary ===")
    if failed:
        print(f"{len(failed)} file(s) failed:\n" + "\n".join(failed))
        sys.exit(1)
    else:
        print("All files passed! ✅")

if __name__ == "__main__":
    main()
