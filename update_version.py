#!/usr/bin/env python3 -u

import os
import sys
import re
import time
import random
import glob

os.environ['PYTHONUNBUFFERED'] = '1'

def main():
    print("Starting version update process...", flush=True)

    if len(sys.argv) < 2:
        print("Error: Version number is required.", flush=True)
        print(f"Usage: {sys.argv[0]} <version-number>", flush=True)
        print(f"Example: {sys.argv[0]} 1.0.1", flush=True)
        sys.exit(1)

    version = sys.argv[1]
    print(f"Processing version: {version}", flush=True)

    if not re.match(r'^\d+\.\d+\.\d+$', version):
        print(f"Error: Version '{version}' is not in the correct format.")
        print("Expected format: Major.Minor.Patch (e.g., 1.0.1)")
        sys.exit(1)

    print("Version format validated.")
    print("Searching for project.pbxproj file...")

    print(f"Current working directory: {os.getcwd()}")

    simple_glob = glob.glob("**/project.pbxproj", recursive=True)
    print(f"Simple glob found: {simple_glob}")

    explicit_path = "IApplied/IApplied.xcodeproj/project.pbxproj"
    explicit_exists = os.path.exists(explicit_path)
    print(f"Explicit path '{explicit_path}' exists: {explicit_exists}")

    if explicit_exists:
        project_file = explicit_path
    elif simple_glob:
        project_file = simple_glob[0]
    else:
        print("Error: Could not find project.pbxproj file.")
        sys.exit(1)

    print(f"Using project file: {project_file}")

    build_number = generate_build_number(version)
    update_project_file(project_file, version, build_number)

    print("✅ Successfully updated project file")
    print(f"  - Version: {version}")
    print(f"  - Build: {build_number}")

def generate_build_number(version):
    major, minor, patch = map(int, version.split('.'))
    version_prefix = major * 1000 + minor * 100 + patch * 10
    timestamp_suffix = int(time.time()) % 100000
    random_component = random.randint(0, 99)
    build_number = version_prefix * 1000000 + timestamp_suffix * 100 + random_component
    return str(build_number % 2000000000)

def update_project_file(file_path, version, build_number):
    print(f"Reading project file: {file_path}")

    try:
        with open(file_path, 'r') as f:
            content = f.read()
            print(f"Successfully read file ({len(content)} bytes)")

        marketing_match = re.search(r'MARKETING_VERSION = ([\d\.]+);', content)
        current_match = re.search(r'CURRENT_PROJECT_VERSION = (\d+);', content)

        current_marketing = marketing_match.group(1) if marketing_match else "not found"
        current_project = current_match.group(1) if current_match else "not found"

        print("Current values found:")
        print(f"  - MARKETING_VERSION = {current_marketing}")
        print(f"  - CURRENT_PROJECT_VERSION = {current_project}")

        new_content = content
        if marketing_match:
            new_content = new_content.replace(
                marketing_match.group(0),
                f"MARKETING_VERSION = {version};"
            )
        if current_match:
            new_content = new_content.replace(
                current_match.group(0),
                f"CURRENT_PROJECT_VERSION = {build_number};"
            )

        if content == new_content:
            print("Warning: No changes were made to the file content.")
        else:
            print("Changes detected. Writing updated file...")

        with open(file_path, 'w') as f:
            f.write(new_content)
            print("Successfully wrote updated file")

        with open(file_path, 'r') as f:
            verify_content = f.read()

        verify_marketing = re.search(r'MARKETING_VERSION = ([\d\.]+);', verify_content)
        verify_current = re.search(r'CURRENT_PROJECT_VERSION = (\d+);', verify_content)

        print("Verification after update:")
        print(f"  - MARKETING_VERSION = {verify_marketing.group(1) if verify_marketing else 'not found'}")
        print(f"  - CURRENT_PROJECT_VERSION = {verify_current.group(1) if verify_current else 'not found'}")

    except Exception as e:
        print(f"Error updating project file: {e}")
        raise

    print(f"Updated {file_path}")
    print(f"  - Set MARKETING_VERSION to {version}")
    print(f"  - Set CURRENT_PROJECT_VERSION to {build_number}")

if __name__ == "__main__":
    main()
