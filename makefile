# $(CURDIR) is a GNU make variable containing the path to the current working directory
PROJDIR := $(CURDIR)
SOURCEDIR := $(PROJDIR)/src/c
BUILDDIR := $(PROJDIR)/_build

# Name of the final binary file
TARGET = kernel.iso

# Name the compiler
CC = gcc
AS = nasm
LD = ld

ASMFLAGS=-g -f elf
CFLAGS=-fno-stack-protector -nostdlib -nodefaultlibs -nostartfiles -nolibc -static -m32
LDFLAGS=-m elf_i386

ASM_SOURCES=$(wildcard src/asm/*.asm)
ASM_OBJECTS=$(notdir $(patsubst %.asm, %.o, $(ASM_SOURCES)))

C_SOURCES=$(wildcard src/c/*.c)
C_OBJECTS=$(notdir $(patsubst %.c, %.o, $(C_SOURCES)))

clean:
	rm -rf _build

$(ASM_OBJECTS): $(ASM_SOURCES)
	echo "Asembling $< ..."
	$(AS) $(ASMFLAGS) $< -o $(BUILDDIR)/$@


$(C_OBJECTS): $(C_SOURCES)
	echo "Compiling $< ..."
	$(CC) $(CFLAGS) -c $< -o $(BUILDDIR)/$@

dir:
	mkdir -p $(BUILDDIR)

build: dir $(ASM_OBJECTS) $(C_OBJECTS)
	echo "Executing linker (ld)..."
	mkdir -p $(BUILDDIR)/bin
	$(LD) $(LDFLAGS) -T $(CURDIR)/linker.ld -o $(BUILDDIR)/bin/kernel.bin $(BUILDDIR)/*.o

iso: build
	echo "Generating iso file structure..."
	mkdir -p $(BUILDDIR)/ISO/boot/grub
	mkdir -p $(BUILDDIR)/iso

	echo "Copying bin file..."
	cp $(BUILDDIR)/bin/kernel.bin $(BUILDDIR)/ISO/boot
	cp grub.cfg $(BUILDDIR)/ISO/boot/grub

	echo "Generating ISO-File..."
	grub-mkrescue -o $(BUILDDIR)/iso/kernel.iso $(BUILDDIR)/ISO/

run: iso
	vboxmanage startvm "My First Kernel"
