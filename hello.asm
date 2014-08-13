; this is especially thanks to:
; http://blog.markloiseau.com/2012/05/tiny-64-bit-elf-executables/

BITS 64
	org	0x00400000	; Program load offset

; 64-bit ELF header
ehdr:
	;  1), 0 (ABI ver.)
	db 0x7F, "ELF", 2, 1, 1, 0       ; e_ident
	times 8 db 0                     ; reserved (zeroes)

	dw 2              ; e_type:	Executable file
	dw 0x3e           ; e_machine:	AMD64
	dd 1              ; e_version:	current version
	dq _start         ; e_entry:	program entry address (0x78)
	dq phdr - $$      ; e_phoff	program header offset (0x40)
	dq 0              ; e_shoff	no section headers
	dd 0              ; e_flags	no flags
	dw ehdrsize       ; e_ehsize:	ELF header size (0x40)
	dw phdrsize       ; e_phentsize:	program header size (0x38)
	dw 1              ; e_phnum:	one program header
	dw 0              ; e_shentsize
	dw 0              ; e_shnum
	dw 0              ; e_shstrndx

ehdrsize equ $ - ehdr

; 64-bit ELF program header
phdr:
	dd 1              ; p_type:	loadable segment
	dd 5              ; p_flags	read and execute
	dq 0              ; p_offset
	dq $$             ; p_vaddr:	start of the current section
	dq $$             ; p_paddr:	"		"
	dq filesize       ; p_filesz
	dq filesize       ; p_memsz
	dq 0x200000       ; p_align:	2^11=200000 = section alignment

; program header size
phdrsize equ $ - phdr

; Hello World!/your program here
_start:

	; sys_write(stdout, message, length)
	mov	rax, 1           ; sys_write
	mov	rdi, 1           ; stdout
	mov	rsi, message     ; message address
	mov	rdx, length      ; message string length
	syscall

	; sys_exit(return_code)
	mov	rax, 60          ; sys_exit
	mov	rdi, 0           ; return 0 (success)
	syscall

	message:
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
		db 'To try something more ambitious, you can run an Ubuntu container with:', 0x0A
		db ' $ docker run -it ubuntu bash', 0x0A
		db 0x0A
		db 'Share images, automate workflows, and more with a free Docker Hub account:', 0x0A
		db ' http://hub.docker.com', 0x0A
		db 0x0A
		db 'For more examples and ideas, visit:', 0x0A
		db ' http://docs.docker.com/userguide/', 0x0A
		db 0x0A
	length: equ	$-message            ; message length calculation

; File size calculation
filesize equ $ - $$
