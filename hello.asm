section     .text
global      _start                              ;must be declared for linker (ld)

_start:                                         ;tell linker entry point

    mov     edx,len                             ;message length
    mov     ecx,msg                             ;message to write
    mov     ebx,1                               ;file descriptor (stdout)
    mov     eax,4                               ;system call number (sys_write)
    int     0x80                                ;call kernel

    mov     eax,1                               ;system call number (sys_exit)
    int     0x80                                ;call kernel

section     .data

msg:
    db 0x0A
    db 'Hello from Docker.', 0x0A
    db 'This message shows that your installation appears to be working correctly.', 0x0A
    db 0x0A
    db 'To generate this message, Docker took the following steps:', 0x0A
    db ' 1. The Docker client contacted the Docker daemon.', 0x0A
    db ' 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.', 0x0A
    db ' 3. The Docker daemon created a new container from that image which runs the', 0x0A
    db '    executable that produces the output you are currently reading.', 0x0A
    db ' 4. The Docker daemon streamed that output to the Docker client, which sent it', 0x0A
    db '    to your terminal.', 0x0A
    db 0x0A
    db 'This is a slightly rewritten version, replacing the 64 bit ELF asm', 0x0A
    db "with 32 bit. My 32 bit Debian didn't run to original so well.", 0x0A
    db 'So frankly, I have no idea if the further tutorial works, but I ', 0x0A
    db 'rather suspect they do not. So.. hit http://docker.com, ', 0x0A
    db 'https://hub.docker.com, https://docs.docker.com/engine/userguide/', 0x0A
    db 0x0A
    db 'Be all open-source-y. Do something useful with this.', 0x0A
    db 0x0A

len: equ	$-msg            ; message length calculation
