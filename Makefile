TARGET_ARCH := amd64
C_TARGETS := $(addsuffix hello, $(wildcard $(TARGET_ARCH)/*/))

export CFLAGS := -Os -fdata-sections -ffunction-sections -s
STRIP := $(CROSS_COMPILE)strip

.PHONY: all
all: $(C_TARGETS)

MUSL_SRC := /usr/local/src/musl
MUSL_DIR := $(CURDIR)/musl/$(TARGET_ARCH)
MUSL_PREFIX := $(MUSL_DIR)/prefix
MUSL_GCC := $(MUSL_PREFIX)/bin/musl-gcc

$(MUSL_GCC):
	mkdir -p '$(MUSL_DIR)'
	cd '$(MUSL_DIR)' && '$(MUSL_SRC)/configure' --disable-shared --prefix='$(MUSL_PREFIX)' > /dev/null
	$(MAKE) -C '$(MUSL_DIR)' -j '$(shell nproc)' install > /dev/null

$(C_TARGETS): hello.c $(MUSL_GCC)
	$(MUSL_GCC) $(CFLAGS) -Wl,--gc-sections -static \
		-o '$@' \
		-D DOCKER_IMAGE='"$(notdir $(@D))"' \
		-D DOCKER_GREETING="\"$$(cat 'greetings/$(notdir $(@D)).txt')\"" \
		-D DOCKER_ARCH='"$(TARGET_ARCH)"' \
		'$<'
	$(STRIP) --strip-all --remove-section=.comment '$@'
	@if [ '$(TARGET_ARCH)' = 'amd64' ]; then \
		for winVariant in \
			nanoserver-1809 \
		; do \
			mkdir -p "$(@D)/$$winVariant"; \
			'$@' | sed \
				-e 's/[(]$(TARGET_ARCH)[)]/(windows-$(TARGET_ARCH), '"$$winVariant"')/g' \
				-e 's/an Ubuntu container/a Windows Server container/g' \
				-e 's!ubuntu bash!mcr.microsoft.com/windows/servercore:ltsc2019 powershell!g' \
				-e 's![$$] docker!PS C:\\> docker!g' \
				> "$(@D)/$$winVariant/hello.txt"; \
		done; \
	fi

.PHONY: clean
clean:
	-rm -vrf $(C_TARGETS) $(MUSL_DIR)

.PHONY: test
test: $(C_TARGETS)
	@for b in $^; do \
		( set -x && "./$$b" ); \
		( set -x && "./$$b" | grep -q '"'"$$(basename "$$(dirname "$$b")")"'"' ); \
	done
