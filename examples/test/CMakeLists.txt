cmake_minimum_required(VERSION 3.9.0)

project(HelloWorld)

add_subdirectory(java)
add_subdirectory(python)

add_executable(helloworld helloworld.cpp)
