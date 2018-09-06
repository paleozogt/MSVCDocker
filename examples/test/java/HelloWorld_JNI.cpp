#include <jni.h>

extern "C" {
    JNIEXPORT jstring JNICALL Java_HelloWorld_helloWorld(JNIEnv *env, jobject) {
        return env->NewStringUTF("Hello World from JNI!");
    }
}
