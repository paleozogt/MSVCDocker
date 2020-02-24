# MSVCDocker example

Here we show an example of how you might do some real software development using Docker images build on top of the MSVCDocker base images by installing
tools into wine.

Here we install the [CMake](https://cmake.org/) and [JOM](https://wiki.qt.io/Jom) build tools along with some high-level language development kits.

Suppose you're writing high-level language bindings to a C++ native library.  For example, C# PInvoke, Java JNI, Python extension modules, or Tcl extensions.
Sure these languages can be run on a linux host, but how would you test the native part?

After you've built your base image, `msvc15`, you can build an image that has Windows Java and Python:

```
make windev15
```

Now setup a shortcut to use our image:
```
function vcwine() { docker run -v$HOME:/host/$HOME -w/host/$PWD -u $(id -u):$(id -g) -eMSVCARCH=$MSVCARCH --rm -t -i windev:15 "$@"; }
```

Then we can build the example project using CMake and JOM:

```
✗ mkdir .build; cd .build

✗ vcwine cmake ../test -DCMAKE_BUILD_TYPE=RELEASE -G "NMake Makefiles JOM"
-- The C compiler identification is MSVC 18.0.31101.0
-- The CXX compiler identification is MSVC 18.0.31101.0
-- Check for working C compiler: C:/Program Files (x86)/Microsoft Visual Studio 12.0/VC/bin/x86_amd64/cl.exe
-- Check for working C compiler: C:/Program Files (x86)/Microsoft Visual Studio 12.0/VC/bin/x86_amd64/cl.exe -- works
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Detecting C compile features
-- Detecting C compile features - done
-- Check for working CXX compiler: C:/Program Files (x86)/Microsoft Visual Studio 12.0/VC/bin/x86_amd64/cl.exe
-- Check for working CXX compiler: C:/Program Files (x86)/Microsoft Visual Studio 12.0/VC/bin/x86_amd64/cl.exe -- works
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- CSHARP_COMPILER= C:/Program Files (x86)/MSBuild/12.0/Bin/csc.exe
-- Found Java: C:/Program Files/Java/jdk1.8.0_202/bin/java.exe (found version "1.8.0_202") 
-- Found JNI: C:/Program Files/Java/jdk1.8.0_202/lib/jawt.lib  
-- Java_VERSION= 1.8.0.202
-- Java_JAVA_EXECUTABLE= C:/Program Files/Java/jdk1.8.0_202/bin/java.exe
-- Java_JAVAC_EXECUTABLE= C:/Program Files/Java/jdk1.8.0_202/bin/javac.exe
-- JNI_INCLUDE_DIRS= C:/Program Files/Java/jdk1.8.0_202/include;C:/Program Files/Java/jdk1.8.0_202/include/win32;C:/Program Files/Java/jdk1.8.0_202/include
-- JNI_LIBRARIES= C:/Program Files/Java/jdk1.8.0_202/lib/jawt.lib;C:/Program Files/Java/jdk1.8.0_202/lib/jvm.lib
-- Found PythonInterp: C:/Python27/python.exe (found version "2.7.12") 
-- Found PythonLibs: C:/Python27/libs/python27.lib (found version "2.7.12") 
-- PYTHON_EXECUTABLE= C:/Python27/python.exe
-- PYTHON_INCLUDE_PATH= C:/Python27/include
-- PYTHON_LIBRARIES= C:/Python27/libs/python27.lib
-- Found Tclsh: C:/ActiveTcl/bin/tclsh.exe (found version "8.6") 
-- Found TCL: C:/ActiveTcl/lib/tcl86t.lib  
-- Found TCLTK: C:/ActiveTcl/lib/tcl86t.lib  
-- Found TK: C:/ActiveTcl/lib/tk86t.lib  
-- TCL_TCLSH= C:/ActiveTcl/bin/tclsh.exe
-- TCL_LIBRARY= C:/ActiveTcl/lib/tcl86t.lib
-- Configuring done
-- Generating done
-- Build files have been written to: Z:/host/Users/asimmons/Development/test/MSVCDocker/examples/.build

✗ vcwine jom

jom 1.1.3 - empower your cores

jom: parallel job execution disabled for Makefile
Scanning dependencies of target helloworld_csharp_native
Scanning dependencies of target helloworld_exe
Scanning dependencies of target helloworld_jni
Scanning dependencies of target helloworld_py
[ 16%] Building CXX object CMakeFiles/helloworld_exe.dir/helloworld.cpp.obj
helloworld.cpp
[ 50%] Linking CXX executable helloworld.exe
[ 25%] Building CXX object java/CMakeFiles/helloworld_jni.dir/HelloWorld_JNI.cpp.obj
HelloWorld_JNI.cpp
[ 41%] Linking CXX shared library HelloWorld.dll
   Creating library HelloWorld.lib and object HelloWorld.exp
[ 66%] Built target helloworld_jni
[ 66%] Built target helloworld_exe
[ 16%] Building CXX object csharp/CMakeFiles/helloworld_csharp_native.dir/HelloWorldNative.cpp.obj
HelloWorldNative.cpp
[ 58%] Linking CXX shared library HelloWorld.dll
   Creating library HelloWorld.lib and object HelloWorld.exp
[ 33%] Building CXX object python/CMakeFiles/helloworld_py.dir/HelloWorldPy.cpp.obj
HelloWorldPy.cpp
[ 66%] Linking CXX shared module helloworld.pyd
   Creating library helloworld.lib and object helloworld.exp
[ 66%] Built target helloworld_csharp_native
[ 66%] Built target helloworld_py
Scanning dependencies of target helloworld_tcl_ext
Scanning dependencies of target helloworld_jar
[ 75%] Building CXX object tcl/CMakeFiles/helloworld_tcl_ext.dir/HelloWorldTcl.cpp.obj
Scanning dependencies of target helloworld
HelloWorldTcl.cpp
Scanning dependencies of target helloworld_csharp_assembly
[ 83%] Generating HelloWorld.jar
hello world from win x86_64 msvc v1800
[ 91%] Built target helloworld
[ 91%] Generating HelloWorldCSharp.exe
[100%] Linking CXX shared library HelloWorld.dll
Scanning dependencies of target helloworld_python
   Creating library HelloWorld.lib and object HelloWorld.exp
[100%] Built target helloworld_tcl_ext
Hello World from Python Extensions!
[100%] Built target helloworld_python
Scanning dependencies of target helloworld_tcl
Hello World from TCL!
[100%] Built target helloworld_tcl
[100%] Built target helloworld_jar
Scanning dependencies of target helloworld_java
Hello World from JNI!
[100%] Built target helloworld_java
Microsoft (R) Visual C# Compiler version 12.0.31101.0
for C# 5
Copyright (C) Microsoft Corporation. All rights reserved.
[100%] Built target helloworld_csharp_assembly
Scanning dependencies of target helloworld_csharp
Hello World from C# Native Is64BitProcess=True IsMono=False
[100%] Built target helloworld_csharp
```

And behold, we can test native bindings from various high-level languages!

  * C# PInvoke:
    ```
    ✗ vcwine jom helloworld_csharp
    ...
    Hello World from C# Native Is64BitProcess=True IsMono=False
    ...
    ```

  * Java JNI:
    ```
    ✗ vcwine jom helloworld_java
    ...
    Hello World from JNI!
    ```

  * Python Extensions:
    ```
    ✗ vcwine jom helloworld_python
    ...
    Hello World from Python Extensions!
    ```

  * Tcl Extensions:
    ```
    ✗ vcwine jom helloworld_tcl
    ...
    Hello World from TCL!
    ```
