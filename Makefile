TARGET_ARCH := amd64
C_TARGETS := $(addsuffix hello, $(wildcard $(TARGET_ARCH)/*/))

CC := gcc
CFLAGS := -static -Os -nostartfiles -fno-asynchronous-unwind-tables
STRIP := strip

.PHONY: all
all: $(C_TARGETS)

$(C_TARGETS): hello.c
	$(CC) $(CFLAGS) -o '$@' -D DOCKER_IMAGE='"$(notdir $(@D))"' -D DOCKER_GREETING="\"$$(cat 'greetings/$(notdir $(@D)).txt')\"" -D DOCKER_ARCH='"$(TARGET_ARCH)"' '$<'
	$(STRIP) -R .comment -s '$@'
	@if [ '$(TARGET_ARCH)' = 'amd64' ]; then \
		for winVariant in \
			nanoserver-sac2016 \
			nanoserver-1709 \
			nanoserver-1803 \
			nanoserver-1809 \
		; do \
			mkdir -p "$(@D)/$$winVariant"; \
			'$@' | sed \
				-e 's/[(]$(TARGET_ARCH)[)]/(windows-$(TARGET_ARCH), '"$$winVariant"')/g' \
				-e 's/an Ubuntu container/a Windows Server container/g' \
				-e 's!ubuntu bash!mcr.microsoft.com/windows/servercore powershell!g' \
				-e 's![$$] docker!PS C:\\> docker!g' \
				> "$(@D)/$$winVariant/hello.txt"; \
		done; \
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
