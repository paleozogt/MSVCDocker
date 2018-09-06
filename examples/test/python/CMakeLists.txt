find_package(PythonInterp)
find_package(PythonLibs)
message(STATUS "PYTHON_EXECUTABLE= ${PYTHON_EXECUTABLE}")
message(STATUS "PYTHON_INCLUDE_PATH= ${PYTHON_INCLUDE_PATH}")
message(STATUS "PYTHON_LIBRARIES= ${PYTHON_LIBRARIES}")

if (WIN32)
    set(PYLIB_SUFFIX .pyd)
else()
    set(PYLIB_SUFFIX .so)
endif()

# python extension lib
add_library(helloworld_py MODULE HelloWorldPy.cpp)
set_target_properties(helloworld_py PROPERTIES PREFIX "")
set_target_properties(helloworld_py PROPERTIES SUFFIX ${PYLIB_SUFFIX})
set_target_properties(helloworld_py PROPERTIES OUTPUT_NAME helloworld)
target_include_directories(helloworld_py PUBLIC ${PYTHON_INCLUDE_PATH})  
target_link_libraries(helloworld_py ${PYTHON_LIBRARIES})

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/test.py "import helloworld; print helloworld.helloworld()")
add_custom_target(helloworld_python ALL
    COMMAND ${PYTHON_EXECUTABLE} test.py
    DEPENDS helloworld_py
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)
