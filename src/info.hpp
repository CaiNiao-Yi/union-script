#pragma once
#include "executor.hpp"
#include <vector>

const char *VERSION = "0.1.0";
const std::vector<ScriptExecutor> executors = {
    ScriptExecutor("Python", ".py", "python"),
    ScriptExecutor("Bash", ".sh", "bash"),
    ScriptExecutor("Fish", ".fish", "fish"),
    ScriptExecutor("Ruby", ".rb", "ruby"),
};
const std::vector<std::string> filters = {".py", ".sh", ".fish", ".rb"};
