/* hello.c

build with:

 gcc -nostartfiles -fno-asynchronous-unwind-tables -Os -static -o hello hello.c
 strip -R .comment -s hello

*/

#include <unistd.h>

const char message[] = "\n"
"Hello from Docker.\n"
"This message shows that your installation appears to be working correctly.\n"
"\n"
"To generate this message, Docker took the following steps:\n"
" 1. The Docker client contacted the Docker daemon.\n"
" 2. The Docker daemon pulled the \"hello-world\" image from the Docker Hub.\n"
" 3. The Docker daemon created a new container from that image which runs the\n"
"    executable that produces the output you are currently reading.\n"
" 4. The Docker daemon streamed that output to the Docker client, which sent it\n"
"    to your terminal.\n"
"\n"
"To try something more ambitious, you can run an Ubuntu container with:\n"
" $ docker run -it ubuntu bash\n"
"\n"
"Share images, automate workflows, and more with a free Docker Hub account:\n"
" https://hub.docker.com\n"
"\n"
"For more examples and ideas, visit:\n"
" https://docs.docker.com/userguide/\n"
"\n";

void _start()
{
	write(1, message, sizeof(message)-1);
	_exit(0);
}

