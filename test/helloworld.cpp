#include <iostream>
#include <string>

int main() {
    std::string plat;
    #if defined(_WIN32)
        plat= "win";
    #elif defined(__APPLE__)
        plat= "mac";
    #elif defined(__unix__)
        plat= "unix";
    #endif

    std::string arch;
    #if defined(__i386__) || defined(_M_IX86)
        arch="x86";
    #elif defined(__x86_64__) || defined(_M_X64)
        arch="x86_64";
    #elif defined(__arm__) || defined(_M_ARM)
        arch="arm";
    #elif defined(__aarch64__) || defined(_M_ARM64)
        arch="arm64";
    #endif

    std::cout << "hello world from "
              << plat << " " << arch << std::endl;

    return 0;
}