find_package(Tcl REQUIRED)
message(STATUS "TCL_TCLSH= ${TCL_TCLSH}")
message(STATUS "TCL_LIBRARY= ${TCL_LIBRARY}")

# tcl lib
add_library(helloworld_tcl_ext SHARED HelloWorldTcl.cpp)
set_target_properties(helloworld_tcl_ext PROPERTIES OUTPUT_NAME HelloWorld)
target_include_directories(helloworld_tcl_ext PUBLIC ${TCL_INCLUDE_PATH})
target_link_libraries(helloworld_tcl_ext PUBLIC ${TCL_LIBRARY})
set_target_properties(helloworld_tcl_ext PROPERTIES OUTPUT_NAME ${PROJECT_NAME})

add_custom_target(helloworld_tcl ALL
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/HelloWorld.tcl ${CMAKE_CURRENT_BINARY_DIR}/HelloWorld.tcl
    COMMAND ${TCL_TCLSH} HelloWorld.tcl
    DEPENDS helloworld_tcl_ext ${CMAKE_CURRENT_SOURCE_DIR}/HelloWorld.tcl
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)
