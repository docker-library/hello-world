TARGET_EXT :=
DIR_TARGETS := $(wildcard */)
LINUX_TARGETS := $(addsuffix hello, $(DIR_TARGETS))
WINDOWS_TARGETS := $(addsuffix nanoserver/hello.exe, $(DIR_TARGETS))
C_TARGETS := $(LINUX_TARGETS) $(WINDOWS_TARGETS)

SHELL := /bin/bash

LINUX_CC := gcc
WINDOWS_CC := x86_64-w64-mingw32-gcc
HAVE_WINDOWS_CC := $(shell command -v $(WINDOWS_CC))

CFLAGS := -static -Os -nostartfiles -fno-asynchronous-unwind-tables

.PHONY: all
all: $(LINUX_TARGETS) $(if $(HAVE_WINDOWS_CC), $(WINDOWS_TARGETS))

#C_TARGET_IMAGE = $(@D)
C_TARGET_IMAGE = $(firstword $(subst /, , $@))
C_TARGET_CC = $(if $(filter $@, $(WINDOWS_TARGETS)), $(WINDOWS_CC), $(LINUX_CC))
$(C_TARGETS): hello.c
	@mkdir -p '$(@D)'
	$(C_TARGET_CC) $(CFLAGS) -o '$@' -D DOCKER_IMAGE='"$(C_TARGET_IMAGE)"' -D DOCKER_GREETING="\"$$(cat '$(C_TARGET_IMAGE)/greeting.txt')\"" '$<'
	strip -R .comment -s '$@'

.PHONY: clean
clean:
	-rm -vrf $(C_TARGETS)

.PHONY: test
test: $(LINUX_TARGETS)
	@for b in $^; do \
		( set -x && "./$$b" ); \
		( set -x && "./$$b" | grep -q '"'"$$(dirname "$$b")"'"' ); \
	done
