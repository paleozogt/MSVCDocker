[![Build Status](https://dev.azure.com/paleozogt/MSVCDocker/_apis/build/status/paleozogt.MSVCDocker?branchName=master)](https://dev.azure.com/paleozogt/MSVCDocker/_build/latest?definitionId=3&branchName=master)

# Microsoft Visual C via Wine in Docker

CI with [MSVC](https://visualstudio.microsoft.com/vs/community/) is unnecessarily difficult. Can't we just use [Docker](https://www.docker.com/get-started)?

It turns out we can-- by running MSVC in [Wine](https://www.winehq.org/).  Lots of folks have tried to do this over the years [[1](README.md#references)], but the setup is involved and fiddly.  But scripting complicated setups is what Docker was made for!

The big blocker to getting MSVC in Wine is that even though the software itself works under Wine, the installers *don't*.  We dodge that problem by using [Vagrant](https://www.vagrantup.com/downloads.html) to drive the MSVC installer in a real Windows OS within [VirtualBox](https://www.virtualbox.org/wiki/Downloads), export a snapshot of the installation, and then [Docker](https://www.docker.com/get-started) copies the snapshot into Wine.

## Requirements

 * [Docker](https://www.docker.com/get-started)
    * If on Linux, allow Docker to be used [without sudo](https://docs.docker.com/engine/installation/linux/linux-postinstall/)
 * [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
 * [Vagrant](https://www.vagrantup.com/downloads.html)
    * [Vagrant Reload Plugin](https://github.com/aidanns/vagrant-reload)

## Building an Image

To create an `msvc:15` Docker image:

```
make clean
make msvc15
```

MSVC 9, 10, 11, 12, 14, 15, and 16 are supported.

Note: The snapshot step can take quite some time, as the MSVC installers are notoriously gigantic and slow.

## Usage

Let's simplify our Docker command:
```
function vcwine() { docker run -v$HOME:/host/$HOME -w/host/$PWD -u 1000:$(id -g) -eMSVCARCH=$MSVCARCH --rm -t -i msvc:15 "$@"; }
```

The Docker images are setup to run (nearly) everything through Wine.  So for example, we can do DOS things like `dir`:

```
✗ vcwine cmd /c dir
Volume in drive Z has no label.
Volume Serial Number is 0000-0000

Directory of Z:\host\Users\paleozogt\Development\test\MSVCDocker

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

### MSVC's cl

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


✗ vcwine helloworld.exe
hello world from win x86_64 msvc v1915
```

Even though its 2018, maybe we want to build for 32-bit:
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


✗ vcwine helloworld.exe
hello world from win x86 msvc v1915
```

### LLVM's clang-cl

[Clang](https://clang.llvm.org/) can cross-compile MSVC-compatible binaries with [clang-cl](http://blog.llvm.org/2018/03/clang-is-now-used-to-build-chrome-for.html).
A linux version is included (ie, it doesn't use Wine), but it still needs the MSVC installation for headers/libs, and Wine is still useful for running
the resulting binary.

Compiling a Hello World:
```
✗ vcwine clang-cl test/helloworld.cpp 


✗ vcwine helloworld.exe
hello world from win x86_64 clang v7
```

Even though its 2018, maybe we want to build for 32-bit:
```
✗ MSVCARCH=32 vcwine clang-cl test/helloworld.cpp


✗ vcwine helloworld.exe
hello world from win x86 clang v7
```

## Examples

For more examples, including the use of CMake and high-level language bindings, see the [examples](examples) subfolder.

## Known Issues

* MSBuild doesn't work, so we can't do things like

  ```
  vcwine cmake ../../test -G "Visual Studio 15 2017 Win64"
  vcwine msbuild
  ```

  If you're using CMake, use the "NMake Makefiles", "NMake Makefiles JOM", or "Ninja" generators.

* When using LLVM's clang-cl, paths that begin with `/U` (such as `/Users/`) will cause [strange errors](https://reviews.llvm.org/D29198):

  ```
  clang-7: warning: '/Users/paleozogt/Development/test/MSVCDocker/build/test/CMakeFiles/CMakeTmp/testCCompiler.c' treated as the '/U' option [-Wslash-u-filename]
  clang-7: note: Use '--' to treat subsequent arguments as filenames
  clang-7: error: no input files
  ```

  It appears that `/Users/...` is getting mistaken for a cl flag `/U`.

* The container cannot be run under an arbitrary UID.  It must be run as user `1000`.  For example, lets say your UID is `1001`.  If you try to run the container under that UID you'll see this error:
  ```
  docker run -v $HOME:$HOME -w $PWD --rm -it -u$(id -u) msvc:15 cl test/helloworld.cpp
  wine: /opt/win is not owned by you
  ```

  The reason is a limitation of Wine-- read more about it [here](https://wiki.winehq.org/FAQ#Can_I_install_applications_to_be_shared_by_multiple_users.3F).

  See the above `vcwine` shell function for how the container should be invoked.  

## References
 * https://hackernoon.com/a-c-hello-world-and-a-glass-of-wine-oh-my-263434c0b8ad
 * https://dekken.github.io/2015/12/29/MSVC2015-on-Debian-with-Wine-and-Maiken.html
 * http://kegel.com/wine/cl-howto.html
 * https://sites.google.com/site/mookmoz2/linux-msvc-cross-compile
