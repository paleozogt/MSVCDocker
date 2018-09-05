# Microsoft Visual C via Wine in Docker

CI with [MSVC](https://visualstudio.microsoft.com/vs/community/) is unnecessarily difficult. Can't we just use [Docker](https://www.docker.com/get-started)?

It turns out we can-- by running MSVC in [Wine](https://www.winehq.org/).  Lots of folks have tried to do this over the years [[1](README.md#references)], but the setup is involved and fiddly.  But scripting complicated setups is what Docker was made for!

The big blocker to getting MSVC in Wine is that even though the software itself works under Wine, the installers *don't*.  We dodge that problem by using [Vagrant](https://www.vagrantup.com/downloads.html) to drive the MSVC installer in a real Windows OS within [VirtualBox](https://www.virtualbox.org/wiki/Downloads), export a snapshot of the installation, and then [Docker](https://www.docker.com/get-started) copies the snapshot into Wine.

### Requirements

 * [Docker](https://www.docker.com/get-started)
 * [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
 * [Vagrant](https://www.vagrantup.com/downloads.html)
    * [Vagrant Reload Plugin](https://github.com/aidanns/vagrant-reload)

### Building an Image

To create an `msvc:15` Docker image:

```
make msvc15
```

MSVC 11, 12, 14, and 15 are supported.

Note: The snapshot step can take quite some time, as the MSVC installers are notoriously gigantic and slow.

### Usage

Let's simplify our Docker command:
```
function vcwine() { docker run -v$HOME:$HOME -w$PWD -u 0:$UID -eMSVCARCH=$MSVCARCH --rm -t -i msvc:15 "$@"; }
```

The Docker images are setup to run everything through Wine.  So for example, you can do DOS things like `dir`:

```
✗ vcwine cmd /c dir
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
✗ vcwine cl test/helloworld.cpp 
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
✗ vcwine helloworld.exe
hello world from win x86_64 msvc v1915
```

Even though its 2018, maybe you want to build for 32-bit:
```
✗ MSVCARCH=32 vcwine cl test/helloworld.cpp
Microsoft (R) C/C++ Optimizing Compiler Version 18.00.31101 for x86
Copyright (C) Microsoft Corporation.  All rights reserved.

helloworld.cpp
C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\INCLUDE\xlocale(337) : warning C4530: C++ exception handler used, but unwind semantics are not enabled. Specify /EHsc
Microsoft (R) Incremental Linker Version 12.00.31101.0
Copyright (C) Microsoft Corporation.  All rights reserved.

/out:helloworld.exe
helloworld.obj
```

Running the 32-bit Hello World:
```
✗ vcwine helloworld.exe
hello world from win x86 msvc v1915
```

[CMake](https://cmake.org/) and [JOM](https://wiki.qt.io/Jom) are also included, so you can build Hello World that way:
```
✗ mkdir -p build/test
✗ cd build/test
✗ vcwine cmake ../../test -DCMAKE_BUILD_TYPE=RELEASE -G "NMake Makefiles JOM"
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

✗ vcwine jom
jom 1.1.2 - empower your cores
jom: parallel job execution disabled for Makefile
Scanning dependencies of target helloworld
[ 50%] Building CXX object CMakeFiles/helloworld.dir/helloworld.cpp.obj
helloworld.cpp
[100%] Linking CXX executable helloworld.exe
[100%] Built target helloworld

✗ vcwine helloworld.exe
hello world from win x86_64 msvc v1915

```

### Known Issues

* MSBuild doesn't work, so you can't do things like

  ```
  vcwine cmake ../../test -G "Visual Studio 15 2017 Win64"
  vcwine msbuild
  ```

  MSBuild depends heavily on .Net, which Wine often has trouble with (especially with `WINEARCH=win64`).

* While release builds work fine, debug builds don't quite work.


### References
 * https://hackernoon.com/a-c-hello-world-and-a-glass-of-wine-oh-my-263434c0b8ad
 * https://dekken.github.io/2015/12/29/MSVC2015-on-Debian-with-Wine-and-Maiken.html
 * http://kegel.com/wine/cl-howto.html
 * https://sites.google.com/site/mookmoz2/linux-msvc-cross-compile
