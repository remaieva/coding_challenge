import os
import re
import shutil

source_dir = '/path/to/source/directory'
target_root_dir = '/path/to/target/root/directory'

# Use the os module to iterate through all the files in the source directory
for filename in os.listdir(source_dir):
    if not os.path.isfile(os.path.join(source_dir, filename)):
        continue  # Skip directories

    # Parse the date from the file name
    match = re.match(r'^\w{2}\d{3}\.(\d{2})(\d{2})(\d{2})FSRV\.Z01$', filename)
    if not match:
        continue  # Skip files that don't match the naming convention

    # Extract date information from the file name
    year, month, day = '20' + match.group(3), match.group(2), match.group(1)

    # Create the target directory structure based on the date of each file using the os module to create directories if they don't exist.
    target_dir = os.path.join(target_root_dir, year, month, day)
    os.makedirs(target_dir, exist_ok=True)

    # Copy the file to the appropriate target directory.
    shutil.copy2(os.path.join(source_dir, filename), target_dir)

source_files = set(os.listdir(source_dir))
target_files = set()
for root, dirs, files in os.walk(target_root_dir):
    for filename in files:
        target_files.add(filename)

if source_files != target_files:
    print("Error: not all files were moved to target directories!")
