# Union Script

**Union Script** is a command-line tool that allows you to run scripts written in different languages from a unified interface. Based on the script file extension, it automatically selects the appropriate interpreter and executes the script. It is especially useful for organizing personal script repositories and simplifying scripting workflows.

---

## ✨ Features

- 🧠 Auto-select script executor by extension (`.py`, `.sh`, etc.)
- 📁 Support for multiple script repositories via environment variable
- 📝 Quick script editing and listing
- ⚙️ Easy-to-extend executor system

---

## 📦 Environment

- **C++ Standard:** C++20
- **Build system:** CMake

---

## 🛠️ Installation & Build

```bash
# Clone the project
git clone https://github.com/your-username/union-script.git
cd union-script

# Configure with CMake (Release mode, using Homebrew Clang)
cmake -B build -S .

# Build only the 'us' executable
cmake --build build --target us
