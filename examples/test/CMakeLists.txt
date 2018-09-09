cmake_minimum_required(VERSION 3.9.0)

project(HelloWorld)

add_subdirectory(csharp)
add_subdirectory(java)
add_subdirectory(python)
add_subdirectory(tcl)

add_executable(helloworld helloworld.cpp)
