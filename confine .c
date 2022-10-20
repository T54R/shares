#include <sys/types.h>
#include <unistd.h>

int main(void) {
    if (setuid(0)) _exit(__LINE__);
    if (setgid(0)) _exit(__LINE__);

    char * const argv[] = { "/bin/bash", "-c", "id; cat /proc/self/attr/current", NULL };
    execve(*argv, argv, NULL);
    _exit(__LINE__);
}
