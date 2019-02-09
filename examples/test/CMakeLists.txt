cmake_minimum_required(VERSION 3.9.0)

project(HelloWorld)

add_subdirectory(java)
add_subdirectory(python)
add_subdirectory(tcl)

add_executable(helloworld_exe helloworld.cpp)
set_target_properties(helloworld_exe PROPERTIES OUTPUT_NAME helloworld)
add_custom_target(helloworld ALL
    COMMAND ${MONO_EXECUTABLE} helloworld.exe
    DEPENDS helloworld_exe
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)
