# SwiftUI Boilerplate Project with SPM and Sourcery Support

This repository provides a sample project setup to streamline SwiftUI development using Swift Package Manager (SPM) and Sourcery for code generation. 

## Features

- **Swift Package Manager (SPM)**: Modularise your SwiftUI project with SPM, improving compile times and minimizing merge conflicts with `.xcodeproj` files.
- **Sourcery Integration**: Automate code generation using Sourcery. This setup includes support for Sourcery as an SPM plugin.

## Benefits of Using SPM

1. **Modularisation**: Break down your project into modules, which can be developed and tested independently.
2. **Avoid Merge Conflicts**: No more worrying about `.xcodeproj` file conflicts.
3. **Faster Compile Times**: Build features in isolation for quicker compile times.
4. **Dependency Management**: Easily manage dependencies and see what package depends on which feature.

## Getting Started

### Prerequisites

- **Homebrew**: Ensure you have Homebrew installed. You can install it from [here](https://brew.sh/).
- **Sourcery**: Install Sourcery via Homebrew.

### Installation

1. **Clone the repository**:
    ```sh
    git clone git@github.com:Muhammed9991/SampleSwiftProject.git
    cd Sample
    ```

2. **Install Sourcery**:
    ```sh
    brew install sourcery
    ```

3. **Run Sourcery**:
    In the root folder of the project, run:
    ```sh
    sourcery
    ```
    This will start auto-generating the necessary code.

## Usage

- Start building your SwiftUI features in isolation using the modular structure provided by SPM.
- Leverage Sourcery to automate repetitive coding tasks and maintain clean, maintainable code.

## Extra
More info on the `AutoCopy.stencil` -> https://gist.github.com/Muhammed9991/6275ce278816de9d54a8bde5a13c7833
