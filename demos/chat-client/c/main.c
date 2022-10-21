#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
 
int main(int argc, char const* argv[]) {
    int fd_count = atoi(getenv("FD_COUNT"));
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
 
    char line[1024];
 
    // TODO: Send and receive multiple messages concurrently once async reads from stdin are possible
    int lineRead, lineSent, numBytes;
    int stream = 3;
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