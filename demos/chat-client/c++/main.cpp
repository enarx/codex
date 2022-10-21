#include <iostream>
#include <cstdlib>
#include <unistd.h>
#include <string>
#include <cstring>

int main(int argc, char* argv[]) {
    int envVarCount = atoi(std::getenv("FD_COUNT"));
    if (envVarCount != 4) {
        std::cout << "expected exactly 4 pre-opened file descriptors" << std::endl;
        return 1;
    }

    int serverFd = --envVarCount;

    std::string input;
    while (1) {
        while (std::cin >> input) {
            input += "\n";
            std::cout << write(serverFd, input.c_str(), strlen(input.c_str())) << std::endl;
        }
    }

    close(serverFd);
    return 0;
}