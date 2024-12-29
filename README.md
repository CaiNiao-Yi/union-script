# Union Script

**Union Script** is a versatile tool designed to simplify the execution of various scripts. Currently in its early development stage, the project aims to support multiple scripting languages and environments, streamlining both script management and execution.

> **Note**: Union Script is in its early development stage. Features may be incomplete or subject to change. Feedback and suggestions are highly appreciated!

## Features

- **Multi-language support** (planned): Execute Python, Bash, Fish, and more.
- **User-friendly interface**: A simple command-line interface for quick script execution.
- **Cross-platform compatibility**: Supports Windows, Linux, and macOS.
- **Modular design**: Easy to extend and customize.
## Usage

Union Script provides a variety of commands for managing and running scripts. Below are the available commands:

```bash
Usage:
  us list           - List all available scripts
  us ls-exe         - List all executors
  us edit <script>  - Edit a specific script
  us run <script>   - Run a specific script

Environment Variables:
  US_REPOSITORIES   - Path to the script repositories
```
## Getting Started

### Clone the Repository
First, clone the repository to your local machine:
```bash
git clone https://github.com/your-username/union-script.git
cd union-script
```
### Build the Project
Build the project using Zig:
```bash
zig build
```
### Set the Environment
Set the environment variable to specify the path of your script repositories:
```bash
export US_REPOSITORIES=<script repositories path>
```

### Run a Script
Execute a script by running the following command:
```bash
us run <script name>
```

## Planned Features
- Support for additional scripting languages and runtimes.
- Multi-repository support to manage multiple script locations.

## Contributing

Contributions are welcome! If you encounter any issues or have ideas for improvements, feel free to open an issue or submit a pull request. Your feedback will help improve the project!
