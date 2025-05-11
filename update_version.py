#!/usr/bin/env python3 -u

import os
import sys
import re
import time
import random
import glob
import json

os.environ['PYTHONUNBUFFERED'] = '1'

def main():
    print("🔧 Starting iOS version bump process", flush=True)

    if len(sys.argv) < 2:
        print("❌ Error: Version number is required.", flush=True)
        print(f"Usage: {sys.argv[0]} <version-number>", flush=True)
        sys.exit(1)

    version = sys.argv[1]
    print(f"📦 Target version: {version}", flush=True)

    if not re.match(r'^\d+\.\d+\.\d+$', version):
        print(f"❌ Error: Version '{version}' is not in the correct format. Expected Major.Minor.Patch (e.g. 1.0.1)")
        sys.exit(1)

    print("✅ Version format validated")
    print("🔍 Searching for project.pbxproj file...")

    simple_glob = glob.glob("**/project.pbxproj", recursive=True)
    explicit_path = "IApplied/IApplied.xcodeproj/project.pbxproj"
    explicit_exists = os.path.exists(explicit_path)

    if explicit_exists:
        project_file = explicit_path
    elif simple_glob:
        project_file = simple_glob[0]
    else:
        print("❌ Error: Could not find project.pbxproj file.")
        sys.exit(1)

    print(f"📄 Using project file: {project_file}")

    build_number = generate_build_number(version)
    update_project_file(project_file, version, build_number)

    print("✅ Project file updated")
    print(f"  - MARKETING_VERSION: {version}")
    print(f"  - CURRENT_PROJECT_VERSION: {build_number}")

def generate_build_number(version, history_file="build_history.json"):
    build_history = {}

    if os.path.exists(history_file):
        try:
            with open(history_file, 'r') as f:
                build_history = json.load(f)
        except json.JSONDecodeError:
            print("⚠️ Warning: Couldn't parse build history, starting fresh.")

    if version in build_history:
        new_build = build_history[version] + 1
        print(f"🔁 Existing version detected. Incrementing build number to {new_build}")
    else:
        print("🆕 No build history found. Generating new build number.")
        major, minor, patch = map(int, version.split('.'))
        version_prefix = major * 1000 + minor * 100 + patch * 10
        timestamp_suffix = int(time.time()) % 100000
        random_component = random.randint(0, 99)
        new_build = version_prefix * 1000000 + timestamp_suffix * 100 + random_component
        new_build = new_build % 2000000000
        print(f"🎲 Generated build number: {new_build}")

    build_history[version] = new_build
    with open(history_file, 'w') as f:
        json.dump(build_history, f, indent=2)

    return str(new_build)

def update_project_file(file_path, version, build_number):
    print(f"📝 Reading: {file_path}")

    try:
        with open(file_path, 'r') as f:
            content = f.read()
            print(f"📥 File read ({len(content)} bytes)")

        marketing_match = re.search(r'MARKETING_VERSION = ([\d\.]+);', content)
        current_match = re.search(r'CURRENT_PROJECT_VERSION = (\d+);', content)

        print("🔎 Existing values:")
        print(f"  - MARKETING_VERSION = {marketing_match.group(1) if marketing_match else 'not found'}")
        print(f"  - CURRENT_PROJECT_VERSION = {current_match.group(1) if current_match else 'not found'}")

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
            print("⚠️ No changes detected in the file.")
        else:
            print("✍️ Writing updates...")

        with open(file_path, 'w') as f:
            f.write(new_content)
            print("✅ File updated")

        with open(file_path, 'r') as f:
            verify_content = f.read()

        verify_marketing = re.search(r'MARKETING_VERSION = ([\d\.]+);', verify_content)
        verify_current = re.search(r'CURRENT_PROJECT_VERSION = (\d+);', verify_content)

        print("🔍 Post-update check:")
        print(f"  - MARKETING_VERSION = {verify_marketing.group(1) if verify_marketing else 'not found'}")
        print(f"  - CURRENT_PROJECT_VERSION = {verify_current.group(1) if verify_current else 'not found'}")

    except Exception as e:
        print(f"❌ Error updating project file: {e}")
        raise

    print(f"📦 Updated {file_path}")
    print(f"  - MARKETING_VERSION → {version}")
    print(f"  - CURRENT_PROJECT_VERSION → {build_number}")

if __name__ == "__main__":
    main()
