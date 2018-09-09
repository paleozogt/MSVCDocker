find_program(CSHARP_COMPILER csc REQUIRED)
message(STATUS "CSHARP_COMPILER= ${CSHARP_COMPILER}")

if (NOT MSVC)
    find_program(MONO_EXECUTABLE mono REQUIRED)
    message(STATUS "MONO_EXECUTABLE= ${MONO_EXECUTABLE}")
endif()

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(CLR_PLAT x64)
elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(CLR_PLAT x86)
endif()

# native lib
add_library(helloworld_csharp_native SHARED HelloWorldNative.cpp)
set_target_properties(helloworld_csharp_native PROPERTIES OUTPUT_NAME ${PROJECT_NAME})

# build the assembly
add_custom_command(
    COMMAND "${CSHARP_COMPILER}" -platform:${CLR_PLAT} -out:${CMAKE_CURRENT_BINARY_DIR}/HelloWorldCSharp.exe ${CMAKE_CURRENT_SOURCE_DIR}/HelloWorld.cs
    DEPENDS helloworld_csharp_native ${CMAKE_CURRENT_SOURCE_DIR}/HelloWorld.cs
    OUTPUT HelloWorldCSharp.exe
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
add_custom_target(helloworld_csharp_assembly DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/HelloWorldCSharp.exe)
add_dependencies(helloworld_csharp_assembly helloworld_csharp_native)

add_custom_target(helloworld_csharp ALL
    COMMAND ${MONO_EXECUTABLE} HelloWorldCSharp.exe
    DEPENDS helloworld_csharp_assembly helloworld_csharp_native
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)
