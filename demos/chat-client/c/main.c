#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#ifndef __wasi__
#include <arpa/inet.h>
#include <sys/socket.h>
#endif

int main(int argc, char const *argv[]) {
#ifdef __wasi__
  int fd_count = atoi(getenv("FD_COUNT"));
  if (fd_count != 4) {
    fprintf(stderr, "unexpected amount of file descriptors received:%d\n",
            fd_count);
    return -1;
  }

  char *stream_str = getenv("FD_NAMES");
  char *sep_at;
  for (int i = 0; i < 3; i++) {
    sep_at = strchr(stream_str, ':');
    stream_str = sep_at + 1;
  }
  if (stream_str == NULL) {
    fprintf(stderr, "failed to parse FD_NAMES\n");
    return -1;
  } else if (strcmp(stream_str, "server") != 0) {
    fprintf(stderr, "unknown socket name `%s`\n", stream_str);
    return -1;
  }
  int stream = 3;
#else
  int sock = socket(AF_INET, SOCK_STREAM, 0);
  struct sockaddr_in serv_addr;
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_port = htons(50000);

  if (inet_pton(AF_INET, "127.0.0.1", &serv_addr.sin_addr) <= 0) {
    fprintf(stderr, "invalid address/address not supported\n");
    return -1;
  }

  int stream = connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr));
  if (stream < 0) {
    fprintf(stderr, "connection failed\n");
    return -1;
  }
#endif
  // TODO: Send and receive multiple messages concurrently once async reads from
  // stdin are possible
  while (1) {
    char line[1024];
    char c = '\0';
    int numBytes = 0;
    while (c != '\n') {
      c = getc(stdin);
      line[numBytes] = c;
      numBytes++;
      if (ferror(stdin)) {
        fprintf(stderr, "failed to read line from STDIN\n");
        return -1;
      }
    }
    line[numBytes] = '\0';
    printf("\nyou entered: %s\n", line);
    int ret = write(stream, line, numBytes);
    if (ret <= 0) {
      fprintf(stderr, "failed to send line\n");
      return -1;
    }
  }
  close(stream);
}
