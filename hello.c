#if __linux__

	#include <sys/syscall.h>

	static inline int write(int fd, const void *buf, unsigned int count) {
		return syscall(SYS_write, fd, buf, count);
	}
	static inline void _exit(int status) {
		syscall(SYS_exit, status);
	}

	#ifndef DOCKER_RUN_NAME
		#define DOCKER_RUN_NAME "an Ubuntu container"
	#endif
	#ifndef DOCKER_RUN_CMD
		#define DOCKER_RUN_CMD "ubuntu bash"
	#endif

#else

	#include <unistd.h>

	#ifndef DOCKER_RUN_NAME
		#define DOCKER_RUN_NAME "a Nano Server container"
	#endif
	#ifndef DOCKER_RUN_CMD
		#define DOCKER_RUN_CMD "microsoft/nanoserver powershell"
	#endif

#endif

#ifndef DOCKER_IMAGE
	#define DOCKER_IMAGE "hello-world"
#endif

#ifndef DOCKER_GREETING
	#define DOCKER_GREETING "Hello from Docker!"
#endif

const char message[] =
	"\n"
	DOCKER_GREETING "\n"
	"This message shows that your installation appears to be working correctly.\n"
	"\n"
	"To generate this message, Docker took the following steps:\n"
	" 1. The Docker client contacted the Docker daemon.\n"
	" 2. The Docker daemon pulled the \"" DOCKER_IMAGE "\" image from the Docker Hub.\n"
	" 3. The Docker daemon created a new container from that image which runs the\n"
	"    executable that produces the output you are currently reading.\n"
	" 4. The Docker daemon streamed that output to the Docker client, which sent it\n"
	"    to your terminal.\n"
	"\n"
	"To try something more ambitious, you can run " DOCKER_RUN_NAME " with:\n"
	" $ docker run -it " DOCKER_RUN_CMD "\n"
	"\n"
	"Share images, automate workflows, and more with a free Docker Hub account:\n"
	" https://hub.docker.com\n"
	"\n"
	"For more examples and ideas, visit:\n"
	" https://docs.docker.com/engine/userguide/\n"
	"\n";

void _start() {
	write(1, message, sizeof(message) - 1);
	_exit(0);
}
