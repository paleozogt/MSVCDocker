# MSVCDocker example

Here we show an example of how you might build Docker images on top of the MSVCDocker base images.

Suppose you're doing Java JNI or Python extension modules.  How could you test that code?

After you've built your base image, `msvc15`, you can build an image that has Windows Java and Python:

```
make windev15
```

Then you can use a Windows JVM:

```
✗ docker run --rm -t -i windev:15 java -version
java version "1.8.0_181"
Java(TM) SE Runtime Environment (build 1.8.0_181-b13)
Java HotSpot(TM) 64-Bit Server VM (build 25.181-b13, mixed mode)
```

Or a Windows Python:

```
➜  examples git:(master) ✗ docker run --rm -t -i windev:15 python --version
Python 2.7.12
```
