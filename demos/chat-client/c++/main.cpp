#include <iostream>
#include <cstdlib>
#include <unistd.h>
#include <string>
#include <cstring>
#include <sys/types.h>
#include <sys/select.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <fstream>
#include <vector>
#include "assets.h"

// C backend code based on https://github.com/rjzak/web_wordpuzzle

const unsigned char HTTP_OK[14] = "HTTP/1.0 200\n";
const unsigned char CONTENT_TYPE_HTML[26] = "Content-Type: text/html\n\n";
const unsigned char CONTENT_TYPE_JAVASCRIPT[32] = "Content-Type: text/javascript\n\n";
const unsigned char CONTENT_TYPE_CSS[25] = "Content-Type: text/css\n\n";
const unsigned int PORT = 50010;

ssize_t write_all(const int fd, unsigned char *buf, size_t n);

int main(int argc, char *argv[])
{
    if (argc > 2)
    {
        std::cout << "Too many arguments provided" << std::endl;
        return 1;
    }

    bool isWebInterface = true;
    if (argc == 2)
    {
        if (strcmp("--nowebinterface", argv[1]) == 0)
        {
            isWebInterface = false;
        }
    }

    int envVarCount = atoi(std::getenv("FD_COUNT"));
    if (envVarCount != 5)
    {
        std::cout << "expected exactly 5 pre-opened file descriptors" << std::endl;
        return 1;
    }

    int serverFd, interfaceFd, newSocket;
    interfaceFd = envVarCount - 1;
    serverFd = envVarCount - 2;

    if (isWebInterface)
    {
        std::cout << "Running in web interface mode..." << std::endl;

        struct sockaddr_in addr;
        socklen_t addrlen = 0;

        addr.sin_port = htons(PORT);
        addr.sin_family = AF_INET;
        addr.sin_addr.s_addr = INADDR_ANY;

        char buffer[4096] = {0};

        while (1)
        {
            if ((newSocket = accept(interfaceFd, (struct sockaddr *)&addr, (socklen_t *)&addrlen)) < 0)
            {
                std::cout << "Error accepting interface fd" << std::endl;
                break;
            }

            ssize_t bytes_read = read(newSocket, buffer, 4096);
            if (bytes_read < 0)
            {
                std::cout << "Error reading into buffer" << std::endl;
                break;
            }

            if (buffer[0] != 0x47 || buffer[1] != 0x45 || buffer[2] != 0x54)
            { // !GET
                if (buffer[0] == 0x50 && buffer[1] == 0x55 && buffer[2] == 0x54)
                { // PUT
                    char *loc = strstr(buffer, "message=");
                    loc += strlen("message=");
                    if (write(serverFd, loc, strlen(loc)) < 0)
                    {
                        std::cout << "failed to write" << std::endl;
                    }

                    if (strcmp(loc, "%2F04") == 0) {
                        break;
                    }

                    write(serverFd, "\n", 1);
                }
            }

            if (buffer[4] == 0x2F && buffer[5] == 0x20)
            { // Forward slash and space
                write(newSocket, HTTP_OK, sizeof(HTTP_OK) - 1);
                write(newSocket, CONTENT_TYPE_HTML, sizeof(CONTENT_TYPE_HTML) - 1);
                write_all(newSocket, index_page, sizeof(index_page));
            }

            if (buffer[4] == 0x2F && buffer[5] == 0x73 && buffer[6] == 0x63 && buffer[7] == 0x72)
            { // Forward slash and scr
                write(newSocket, HTTP_OK, sizeof(HTTP_OK) - 1);
                write(newSocket, CONTENT_TYPE_JAVASCRIPT, sizeof(CONTENT_TYPE_JAVASCRIPT) - 1);
                write_all(newSocket, script, sizeof(script));
            }

            if (buffer[4] == 0x2F && buffer[5] == 0x73 && buffer[6] == 0x74 && buffer[7] == 0x79)
            { // Forward slash and sty
                write(newSocket, HTTP_OK, sizeof(HTTP_OK) - 1);
                write(newSocket, CONTENT_TYPE_CSS, sizeof(CONTENT_TYPE_CSS) - 1);
                write_all(newSocket, style, sizeof(style));
            }

            memset(buffer, 0, 4096);
            close(newSocket);
            newSocket = 0;
        }

        close(newSocket);
    }
    else
    {
        std::cout << "Running in stdin mode..." << std::endl;

        std::string input;
        while (std::cin >> input)
        {
            input += "\n";
            if (write(serverFd, input.c_str(), strlen(input.c_str())) < 0)
            {
                std::cout << "Error writing input to server" << std::endl;
            }
        }
    }

    char buffer[4096] = {0};
    if (read(serverFd, &buffer, 4096) < 0)
    {
        std::cout << "Error reading server message" << std::endl;
    }

    std::cout << buffer << std::endl;

    close(interfaceFd);
    close(serverFd);
    return 0;
}

ssize_t write_all(const int fd, unsigned char *buf, size_t n)
{
    size_t total_written = 0;
    while (total_written < n)
    {
        size_t written = write(fd, buf + total_written, n - total_written);
        if (written < 0)
            return written;
        total_written += written;
    }
    return total_written;
}