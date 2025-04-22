#pragma once

#include "info.hpp"
#include <filesystem>
#include <iostream>
#include <optional>
#include <unordered_map>
#include <vector>
namespace fs = std::filesystem;

inline std::vector<fs::path>
getScriptList(const fs::path &repoPath,
              const std::vector<std::string> &filters) {
  std::vector<fs::path> scripts;
  if (!fs::exists(repoPath) || !fs::is_directory(repoPath)) {
    std::cerr << "[getScriptList] Invalid repository path: " << repoPath
              << std::endl;
    return scripts;
  }
  for (const auto &entry : fs::directory_iterator(repoPath)) {
    if (!entry.is_regular_file())
      continue;
    auto ext = entry.path().extension().string();
    if (std::find(filters.begin(), filters.end(), ext) != filters.end()) {
      scripts.push_back(entry.path());
    }
  }
  return scripts;
}
inline std::optional<fs::path>
getScript(const fs::path &repoPath, const std::vector<std::string> &filters,
          const std::string &scriptName) {
  std::unordered_map<std::string, fs::path> scriptMap;
  const std::vector<fs::path> scripts = getScriptList(repoPath, filters);
  for (const auto &extension : filters) {
    for (const auto &script : scripts) {
      if (script.stem() == scriptName) {
        return script;
      }
    }
  }
  return {};
}

inline void printVersion() {
  std::cout << "Union Script\n";
  std::cout << "version: " << VERSION << "\n";
  std::cout << "build: clang-" << __clang_version__ << "\n";
}
inline void printHelp() {
  printVersion();
  std::cout << R"(
Usage:
  us run <script> [args...]     - run a script        (alias: r)
  us edit <script>              - edit a script       (alias: e)
  us ls                         - list all scripts    (alias: list)
  us ls-exe                     - list all executors  (alias: le)
  us version                    - show version        (alias: v)
  us help                       - show help           (alias: h)

Environment Variables:
  US_REPOSITORIES     - script repository directory)" << std::endl;
}
