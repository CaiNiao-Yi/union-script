#include "commands.hpp"
#include "info.hpp"
#include "utils.hpp"
#include <cstdlib>
#include <filesystem>
#include <iostream>

int main(int argc, char *argv[]) {
  if (argc < 2) {
    printHelp();
    return 1;
  }

  const std::string repo = std::getenv("US_REPOSITORIES");
  const std::filesystem::path repoPath = std::filesystem::path(repo);
  const std::string command = argv[1];

  if ((command == "run" || command == "r") && argc >= 3) {
    std::string args;
    for (int i = 3; i < argc; ++i) {
      args += std::string(argv[i]) + " ";
    }
    run(repoPath, filters, executors, std::string(argv[2]), args);
    return 0;
  } else if (command == "list" || command == "ls") {
    list(repoPath, filters);
    return 0;
  } else if ((command == "edit" || command == "e") && argc >= 3) {
    edit(repo, filters, std::string(argv[2]));
    return 0;
  } else if (command == "ls-exe" || command == "le") {
    listExecutors(executors);
    return 0;
  } else if (command == "version" || command == "v") {
    printVersion();
    return 0;
  }else if (command == "help" || command == "h") {
    printHelp();
    return 0;
  }else {
      std::cerr << "Unknown command: " << command << std::endl;
      return 1;
  }
  return 0;
}
