find_package(Java REQUIRED)
find_package(JNI REQUIRED)
message(STATUS "Java_VERSION= ${Java_VERSION}")
message(STATUS "Java_JAVA_EXECUTABLE= ${Java_JAVA_EXECUTABLE}")
message(STATUS "Java_JAVAC_EXECUTABLE= ${Java_JAVAC_EXECUTABLE}")
message(STATUS "JNI_INCLUDE_DIRS= ${JNI_INCLUDE_DIRS}")
message(STATUS "JNI_LIBRARIES= ${JNI_LIBRARIES}")

# jni lib
add_library(helloworld_jni SHARED HelloWorld_JNI.cpp)
set_target_properties(helloworld_jni PROPERTIES OUTPUT_NAME ${PROJECT_NAME})
target_include_directories(helloworld_jni PUBLIC ${JNI_INCLUDE_DIRS})  

# jar
file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/classes")
add_custom_command(
    COMMAND "${Java_JAVAC_EXECUTABLE}" ${CLASSPATH} ${CMAKE_JAVA_COMPILE_FLAGS} -d classes ${CMAKE_CURRENT_SOURCE_DIR}/HelloWorld.java
    COMMAND "${Java_JAR_EXECUTABLE}" -cfM HelloWorld.jar -C classes .
    DEPENDS helloworld_jni ${CMAKE_CURRENT_SOURCE_DIR}/HelloWorld.java
    OUTPUT HelloWorld.jar
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)
add_custom_target(helloworld_jar ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/HelloWorld.jar)
add_dependencies(helloworld_jar helloworld_jni)

add_custom_target(helloworld_java ALL
    COMMAND ${Java_JAVA_EXECUTABLE} -cp HelloWorld.jar HelloWorld
    DEPENDS helloworld_jar helloworld_jni
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)
