#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#ifndef __wasi__
#include <sys/socket.h>
#include <arpa/inet.h>
#endif

int main(int argc, char const* argv[]) {
/*    int fd_count = atoi(getenv("FD_COUNT"));
    if (fd_count != 4) {
        fprintf(stderr, "unexpected amount of file descriptors received:%d\n", fd_count);
        return 1;
    }
 
    char *stream_str = getenv("FD_NAMES");
    char *sep_at;
    for (int i = 0; i < 3; i++) {
        sep_at = strchr(stream_str, ':');
        stream_str = sep_at + 1;
    }    
    if (stream_str == NULL) {
        fprintf(stderr, "failed to parse FD_NAMES\n");
    } else if (strcmp(stream_str, "client") != 0) {
        fprintf(stderr, "unknown socket name %s", stream_str);
    }
 */
    char line[1024];
 
    // TODO: Send and receive multiple messages concurrently once async reads from stdin are possible
    int lineRead, lineSent, numBytes;
    int stream = 3;
#ifndef __wasi__
    int client_fd = 0, sock = 0;
    sock = socket(AF_INET, SOCK_STREAM, 0);
    struct sockaddr_in serv_addr;
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(50000);

    if (inet_pton(AF_INET, "127.0.0.1", &serv_addr.sin_addr) <= 0) {
        printf("Invalid address/ Address not supported \n");
        return -1;
    }
 
    if ((client_fd = connect(sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr))) < 0) {
        printf("\nConnection Failed \n");
        return -1;
    }
    stream = client_fd;
#endif
    char c;
    while (1) {
        c = '\0';
        numBytes = 0;
        while(c != '\n') {
            c = getc(stdin);
            line[numBytes] = c;
            numBytes++;
            if (ferror(stdin)) {
                fprintf(stderr, "failed to read line from STDIN\n");
            }
        }
        line[numBytes] = '\0';
        printf("\nyou entered: %s\n", line);
        lineSent = write(stream, line, numBytes);
        if (lineSent <= 0) {
            fprintf(stderr, "failed to send line\n");
        }
    }
    close(stream);
}