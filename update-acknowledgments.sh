#!/bin/bash

# This is a script to update our Settings.bundle with up-to-date acknowledgments for any
# 3rd party dependencies.

# Install https://github.com/FelixHerrmann/swift-package-list first using brew
# so we can continue to update our acknowledgments.
brew tap FelixHerrmann/tap
brew install swift-package-list

# Run the command to update the acknowledgments. These will be auto-generated based on our Package.swift file.
swift-package-list Package.swift --output-type json --requires-license --output-path SupportingFiles
