hello: hello.asm
	nasm -o $@ $<
	chmod +x hello

.PHONY: clean
clean:
	-rm -vf hello

.PHONY: test
test: hello
	./hello
