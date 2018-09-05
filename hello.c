//#include <unistd.h>
#include <sys/syscall.h>

#ifndef DOCKER_IMAGE
	#define DOCKER_IMAGE "hello-world"
#endif

#ifndef DOCKER_GREETING
	#define DOCKER_GREETING "Hello from Docker!"
#endif

#ifndef DOCKER_ARCH
	#define DOCKER_ARCH "amd64"
#endif

const char message[] =
	"\n"
	DOCKER_GREETING "\n"
	"This message shows that your installation appears to be working correctly.\n"
	"\n"
	"To generate this message, Docker took the following steps:\n"
	" 1. The Docker client contacted the Docker daemon.\n"
	" 2. The Docker daemon pulled the \"" DOCKER_IMAGE "\" image from the Docker Hub.\n"
	"    (" DOCKER_ARCH ")\n"
	" 3. The Docker daemon created a new container from that image which runs the\n"
	"    executable that produces the output you are currently reading.\n"
	" 4. The Docker daemon streamed that output to the Docker client, which sent it\n"
	"    to your terminal.\n"
	"\n"
	"To try something more ambitious, you can run an Ubuntu container with:\n"
	" $ docker run -it ubuntu bash\n"
	"\n"
	"Share images, automate workflows, and more with a free Docker ID:\n"
	" https://hub.docker.com/\n"
	"\n"
	"For more examples and ideas, visit:\n"
	" https://docs.docker.com/get-started/\n"
	"\n";

void _start() {
	//write(1, message, sizeof(message) - 1);
	syscall(SYS_write, 1, message, sizeof(message) - 1);

	//_exit(0);
	syscall(SYS_exit, 0);
}
