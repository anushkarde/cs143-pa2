import os
import subprocess

# Base directory to search
base_dir = "/afs/ir/class/cs143/examples/"

# Path to the compilation command
compiler = "./mycoolc"

# Loop through all files in the directory recursively
for root, _, files in os.walk(base_dir):
    for file in files:
        if file.endswith(".cl"):  # Only process .cl files
            file_path = os.path.join(root, file)

            # Construct the command
            command = [compiler, file_path]

            print(f"Compiling {file_path}...")
            try:
                result = subprocess.run(command, check=True, capture_output=True, text=True)
                print(result.stdout)
            except subprocess.CalledProcessError as e:
                print(f"Error compiling {file_path}:")
                print(e.stderr)
