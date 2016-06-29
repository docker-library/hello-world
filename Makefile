C_TARGETS := $(addsuffix hello, $(wildcard */))

CC := gcc
CFLAGS := -static -Os -nostartfiles -fno-asynchronous-unwind-tables

.PHONY: all
all: $(C_TARGETS)

$(C_TARGETS): hello.c
	$(CC) $(CFLAGS) -o '$@' -D DOCKER_IMAGE='"$(@D)"' -D DOCKER_GREETING="\"$$(cat '$(@D)/greeting.txt')\"" '$<'
	strip -R .comment -s '$@'

.PHONY: clean
clean:
	-rm -vrf $(C_TARGETS)

.PHONY: test
test: $(C_TARGETS)
	@for b in $^; do \
		( set -x && "./$$b" ); \
		( set -x && "./$$b" | grep -q '"'"$$(dirname "$$b")"'"' ); \
	done
