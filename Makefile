TARGET_ARCH := amd64
C_TARGETS := $(addsuffix hello, $(wildcard $(TARGET_ARCH)/*/))

CC := gcc
CFLAGS := -static -Os -nostartfiles -fno-asynchronous-unwind-tables
STRIP := strip

.PHONY: all
all: $(C_TARGETS)

$(C_TARGETS): hello.c
	$(CC) $(CFLAGS) -o '$@' -D DOCKER_IMAGE='"$(notdir $(@D))"' -D DOCKER_GREETING="\"$$(cat 'greetings/$(notdir $(@D)).txt')\"" '$<'
	$(STRIP) -R .comment -s '$@'
	@if [ '$(TARGET_ARCH)' = 'amd64' ]; then \
		mkdir -p '$(@D)/nanoserver'; \
		'$@' | sed -e 's/an Ubuntu container/a Nano Server container/g' -e 's!ubuntu bash!microsoft/nanoserver powershell!g' > '$(@D)/nanoserver/hello.txt'; \
	fi

.PHONY: clean
clean:
	-rm -vrf $(C_TARGETS)

.PHONY: test
test: $(C_TARGETS)
	@for b in $^; do \
		( set -x && "./$$b" ); \
		( set -x && "./$$b" | grep -q '"'"$$(basename "$$(dirname "$$b")")"'"' ); \
	done
