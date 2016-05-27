hello: hello.asm
	nasm -f elf -o $@.o $<
	ld -e _start $@.o -o hello
	chmod 755 hello

.PHONY: clean
clean:
	-rm -vf hello hello.o

.PHONY: test
test: hello
	./hello
