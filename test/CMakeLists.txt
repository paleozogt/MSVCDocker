cmake_minimum_required(VERSION 3.9.0)

project(helloworld)
set(CMAKE_CXX_STANDARD 11)

add_executable(helloworld helloworld.cpp)

if (MSVC)
    # workaround problem with loading CRT debug DLLs
    file(GLOB_RECURSE CRT_DLLS C:/Windows/System32/MSVC*D.dll)
    file(COPY ${CRT_DLLS} DESTINATION ${PROJECT_BINARY_DIR})
endif()
