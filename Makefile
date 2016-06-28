IMAGES := \
	hello-world \
	hola-mundo \
	hello-seattle

ASM_TARGETS := $(addsuffix /hello, $(IMAGES))

.PHONY: all
all: $(ASM_TARGETS)

$(ASM_TARGETS): hello.asm
	mkdir -p '$(dir $@)'
	nasm -o '$@' -DDOCKER_IMAGE="'$$(dirname '$@')'" '$<'
	chmod +x '$@'

.PHONY: clean
clean:
	-rm -vrf $(addsuffix /, $(IMAGES))

.PHONY: test
test: $(ASM_TARGETS)
	@for b in $^; do \
		( set -x && "./$$b" ); \
		( set -x && "./$$b" | grep -q '"'"$$(dirname "$$b")"'"' ); \
	done
