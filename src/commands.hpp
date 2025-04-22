#pragma once
#include "executor.hpp"
#include "utils.hpp"
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
namespace fs = std::filesystem;

inline void edit(const fs::path &repoPath,
                 const std::vector<std::string> &filters,
                 const std::string &scriptName) {
  const char *editor = std::getenv("EDITOR");
  auto fullPath = getScript(repoPath, filters, scriptName);
  if (fullPath.has_value()) {
    std::string command = (editor ? editor : "nvim") + std::string(" ") +
                          fullPath.value().string();
    std::system(command.c_str());
  }
}
inline void run(fs::path repoPath, const std::vector<std::string> &filters,
                const std::vector<ScriptExecutor> &executors,
                const std::string &scriptName,
                const std::string &args) {
  auto fullPathR = getScript(repoPath, filters, scriptName);
  if (!fullPathR.has_value()) {
    std::cout << "[Commands]Script not found" << std::endl;
    return;
  }
  fs::path fullPath = fullPathR.value();
  std::string ext = fullPath.extension().string();
  for (const auto &exe : executors) {
    if (exe.extension() == ext) {
      exe.execute(fullPath, args);
      return;
    }
  }
  std::cerr << "[Commands] No executor found for script" << std::endl;
}
inline void list(const fs::path &repoPath, const std::vector<std::string> &filters) {
    std::vector<fs::path> scriptList = getScriptList(repoPath,filters);
    for (const auto &script : scriptList) {
        std::cout << script.stem() << std::endl;
    }
}
inline void listExecutors(const std::vector<ScriptExecutor> &executors) {
    for (const auto &exe : executors) {
        std::cout << exe.name() << "\t"<< exe.extension() << std::endl;
    }
}
