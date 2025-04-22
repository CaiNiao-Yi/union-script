#pragma once
#include <iostream>
#include <string>

class ScriptExecutor {
public:
  const std::string &name() const { return name_; }
  const std::string &extension() const { return extension_; }
  const std::string &executable() const { return extension_; }

  ScriptExecutor(std::string name, std::string extension,
                 std::string executable)
      : name_(std::move(name)), extension_(std::move(extension)),
        executable_(std::move(executable)) {}
  bool execute(const std::string &fullPath, const std::string &args) const {
      std::string command = executable_ + " \"" + fullPath + "\" " + args;
      std::cout << "[ScriptExecutor] Executing command: " << command << std::endl;
      return system(command.c_str()) == 0;
  };

protected:
  std::string name_;
  std::string extension_;
  std::string executable_;
};
