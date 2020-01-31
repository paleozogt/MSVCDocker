#include <iostream>
#include <string>

int main() {
    std::string plat= "unknown";
    #if defined(_WIN32)
        plat= "win";
    #elif defined(__APPLE__)
        plat= "mac";
    #elif defined(__unix__)
        plat= "unix";
    #endif

    std::string arch= "unknown";
    #if defined(__i386__) || defined(_M_IX86)
        arch="x86";
    #elif defined(__x86_64__) || defined(_M_X64)
        arch="x86_64";
    #elif defined(__arm__) || defined(_M_ARM)
        arch="arm";
    #elif defined(__aarch64__) || defined(_M_ARM64)
        arch="arm64";
    #elif defined(__PPC64__)
        arch="ppc64";
    #endif

    std::string compiler= "unknown";
    int compilerVer= 0;
    #if defined(__GNUC__)
        compiler= "gnu";
        compilerVer= __GNUC__;
    #elif defined(__clang__)
        compiler= "clang";
        compilerVer= __clang_major__;
    #elif defined(_MSC_VER)
        compiler= "msvc";
        compilerVer= _MSC_VER;
    #endif

    std::cout << "hello world from "
              << plat << " " << arch << " "
              << compiler << " v" << compilerVer << std::endl;

    return 0;
}