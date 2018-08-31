# Microsoft Visual C via Wine in Docker

CI with MSVC is unnecessarily difficult. Can't we just use Docker?

It turns out we can-- by running MSVC in [Wine](https://www.winehq.org/).  Lots of folks have tried to do this over the years [[1](README.md#references)], but the setup is involved and fiddly.  But scripting complicated setups is what Docker was made for!

The big blocker to getting MSVC in Wine is that even though the software itself works under Wine, the installers don't.  We dodge that problem by using [Vagrant](https://www.vagrantup.com/downloads.html) to drive a real MSVC installer in [VirtualBox](https://www.virtualbox.org/wiki/Downloads), export a snapshot of the installation, and then the Docker build copies the snapshot into Wine.

### Building an Image

To create an `msvc:15` Docker image:

```
make snapshot15
make msvc15
```

MSVC 12, 14, and 15 are supported.

Note: The snapshot step can take quite some time, as the MSVC installers are notoriously gigantic and slow.

### Usage

The Docker images are setup to run everything through Wine.  So for example, you can do DOS things like `dir`:

```
✗ docker run -v$PWD:$PWD -w$PWD --rm -t -i msvc:15 cmd /c dir
Volume in drive Z has no label.
Volume Serial Number is 0000-0000

Directory of Z:\Users\asimmons\Development\test\MSVCDocker

 8/31/2018   9:08 PM  <DIR>         .
 8/31/2018   9:21 PM  <DIR>         ..
 8/31/2018   8:55 PM  <DIR>         build
 8/31/2018   9:07 PM         3,421  Dockerfile
 8/31/2018   9:07 PM  <DIR>         dockertools
 8/31/2018   9:07 PM           464  Makefile
 8/31/2018   9:08 PM            45  README.md
 8/31/2018   9:07 PM  <DIR>         test
 8/31/2018   9:07 PM         2,654  Vagrantfile
 8/31/2018   9:07 PM  <DIR>         vagranttools
       4 files                    6,584 bytes
       6 directories     97,359,118,336 bytes free
```

Compiling a Hello World:
```
✗ docker run -v$PWD:$PWD -w$PWD --rm -t -i msvc:15 cl test/helloworld.cpp 
Microsoft (R) C/C++ Optimizing Compiler Version 19.15.26726 for x64
Copyright (C) Microsoft Corporation.  All rights reserved.

helloworld.cpp
C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Tools\MSVC\14.15.26726\include\xlocale(319): warning C4530: C++ exception handler used, but unwind semantics are not enabled. Specify /EHsc
Microsoft (R) Incremental Linker Version 14.15.26726.0
Copyright (C) Microsoft Corporation.  All rights reserved.

/out:helloworld.exe 
helloworld.obj 
```

Running Hello World:
```
✗ docker run -v$PWD:$PWD -w$PWD --rm -t -i msvc:15 helloworld.exe        
hello world from win x86_64 msvc v1915
```

[CMake](https://cmake.org/) and [JOM](https://wiki.qt.io/Jom) are also included, so you can build Hello World that way:
```
✗ mkdir -p build/test

✗ docker run -v$PWD:$PWD -w$PWD/build/test --rm -t -i msvc:15 cmake ../../test -DCMAKE_BUILD_TYPE=RELEASE -G "NMake Makefiles JOM"
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
-- Configuring done
-- Generating done
-- Build files have been written to: Z:/Users/asimmons/Development/test/MSVCDocker/build/test

✗ docker run -v$PWD:$PWD -w$PWD/build/test --rm -t -i msvc:15 jom
jom 1.1.2 - empower your cores
jom: parallel job execution disabled for Makefile
Scanning dependencies of target helloworld
[ 50%] Building CXX object CMakeFiles/helloworld.dir/helloworld.cpp.obj
helloworld.cpp
[100%] Linking CXX executable helloworld.exe
[100%] Built target helloworld

✗ docker run -v$PWD:$PWD -w$PWD/build/test --rm -t -i msvc:15 helloworld.exe
hello world from win x86_64 msvc v1915

```

### Requirements

 * [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
 * [Vagrant](https://www.vagrantup.com/downloads.html)
 * [Docker](https://www.docker.com/get-started)

### References
 * https://hackernoon.com/a-c-hello-world-and-a-glass-of-wine-oh-my-263434c0b8ad
 * https://dekken.github.io/2015/12/29/MSVC2015-on-Debian-with-Wine-and-Maiken.html
 * http://kegel.com/wine/cl-howto.html
 * https://sites.google.com/site/mookmoz2/linux-msvc-cross-compile
