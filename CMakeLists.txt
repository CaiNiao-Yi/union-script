cmake_minimum_required(VERSION 3.16)
PROJECT(union_script LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

INCLUDE(FetchContent)

FetchContent_Declare(
    Catch2
    GIT_REPOSITORY https://github.com/catchorg/Catch2.git
    GIT_TAG        v3.4.0
)
FetchContent_MakeAvailable(Catch2)

ADD_EXECUTABLE(us
    src/main.cpp
)
ADD_EXECUTABLE(tests tests/python_executor_text.cpp)

TARGET_INCLUDE_DIRECTORIES(us PRIVATE src)

TARGET_LINK_LIBRARIES(tests PRIVATE  Catch2::Catch2WithMain)

INCLUDE(CTest)
INCLUDE(Catch)
catch_discover_tests(tests)
