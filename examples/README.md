# MSVCDocker example

Here we show an example of how you might build Docker images on top of the MSVCDocker base images.

Suppose you're doing Java JNI or Python extension modules.  How could you test that code?

After you've built your base image, `msvc15`, you can build an image that has Windows Java and Python:

```
make windev15
```

Now setup a shortcut to use our image:
```
function vcwine() { docker run -v$HOME:/host/$HOME -w/host/$PWD -u 0:$UID -eMSVCARCH=$MSVCARCH --rm -t -i windev:15 "$@"; }
```

Then we can build the example project that uses Java JNI / Python Extensions / TCL Extensions:

```
✗ mkdir .build; cd .build

✗ vcwine cmake ../test -DCMAKE_BUILD_TYPE=RELEASE -G "NMake Makefiles JOM"
-- The C compiler identification is MSVC 19.15.26726.0
-- The CXX compiler identification is MSVC 19.15.26726.0
-- Check for working C compiler: C:/Program Files (x86)/Microsoft Visual Studio/2017/BuildTools/VC/Tools/MSVC/14.15.26726/bin/Hostx64/x64/cl.exe
-- Check for working C compiler: C:/Program Files (x86)/Microsoft Visual Studio/2017/BuildTools/VC/Tools/MSVC/14.15.26726/bin/Hostx64/x64/cl.exe -- works
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Detecting C compile features
-- Detecting C compile features - done
-- Check for working CXX compiler: C:/Program Files (x86)/Microsoft Visual Studio/2017/BuildTools/VC/Tools/MSVC/14.15.26726/bin/Hostx64/x64/cl.exe
-- Check for working CXX compiler: C:/Program Files (x86)/Microsoft Visual Studio/2017/BuildTools/VC/Tools/MSVC/14.15.26726/bin/Hostx64/x64/cl.exe -- works
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Detecting CXX compile features
-- Detecting CXX compile features - done
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
-- Build files have been written to: Z:/host/Users/paleozogt/Development/test/MSVCDocker/examples/.build

✗ vcwine jom

jom 1.1.3 - empower your cores

jom: parallel job execution disabled for Makefile
Scanning dependencies of target helloworld
Scanning dependencies of target helloworld_jni
Scanning dependencies of target helloworld_tcl_ext
Scanning dependencies of target helloworld_py
[ 11%] Building CXX object CMakeFiles/helloworld.dir/helloworld.cpp.obj
helloworld.cpp
[ 88%] Linking CXX executable helloworld.exe
[ 33%] Building CXX object tcl/CMakeFiles/helloworld_tcl_ext.dir/HelloWorldTcl.cpp.obj
HelloWorldTcl.cpp
[ 66%] Linking CXX shared library HelloWorld.dll
   Creating library HelloWorld.lib and object HelloWorld.exp
[ 44%] Building CXX object python/CMakeFiles/helloworld_py.dir/HelloWorldPy.cpp.obj
HelloWorldPy.cpp
[ 77%] Linking CXX shared module helloworld.pyd
   Creating library helloworld.lib and object helloworld.exp
[ 22%] Building CXX object java/CMakeFiles/helloworld_jni.dir/HelloWorld_JNI.cpp.obj
HelloWorld_JNI.cpp
[ 55%] Linking CXX shared library HelloWorld.dll
   Creating library HelloWorld.lib and object HelloWorld.exp
[ 88%] Built target helloworld_tcl_ext
[ 88%] Built target helloworld_py
[ 88%] Built target helloworld_jni
[ 88%] Built target helloworld
Scanning dependencies of target helloworld_tcl
Scanning dependencies of target helloworld_python
Scanning dependencies of target helloworld_jar
Hello World from Python Extensions!
[100%] Generating HelloWorld.jar
Hello World from TCL!
[100%] Built target helloworld_python
[100%] Built target helloworld_tcl
[100%] Built target helloworld_jar
Scanning dependencies of target helloworld_java
Hello World from JNI!
[100%] Built target helloworld_java

```

And behold, we can test Windows JNI:
```
✗ vcwine jom helloworld_java
...
Hello World from JNI!
```

And behold, we can test Windows Python Extensions:
```
✗ vcwine jom helloworld_python
...
Hello World from Python Extensions!
```


And behold, we can test Windows Tcl Extensions:
```
✗ vcwine jom helloworld_tcl
...
Hello World from TCL!
```
