# Makefile

# RISCV_GNU_TOOLCHAIN_GIT_REVISION = 8c969a9
RISCV_GNU_TOOLCHAIN_GIT_REVISION = 20f6153
RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX = /opt/riscv
TOOLCHAIN_PREFIX = $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)/bin/riscv32-unknown-elf-

PYTHON = /usr/bin/python3
CC=$(TOOLCHAIN_PREFIX)gcc
RM = rm -rf
MKDIR = mkdir

ARCHITECTURE = rv32i
ABI = ilp32

CFLAGS = -c -Os -march=$(ARCHITECTURE) -mabi=$(ABI) -ffreestanding --std=c99
SFLAGS = -c -Os -march=$(ARCHITECTURE) -mabi=$(ABI) -ffreestanding --std=c99
LDFLAGS = -Wl,-Bstatic,-T,firmware.lds,-Map,firmware.map,--strip-debug -march=$(ARCHITECTURE) -mabi=$(ABI) -nostartfiles

LIBS =

BUILDDIR = build
SOURCEDIR = src
HEADERDIR = src
TOOLS = ../../scripts/python

SOURCES = $(wildcard $(SOURCEDIR)/*.c)
SOURCES_A = $(wildcard $(SOURCEDIR)/*.S)
OBJECTS = $(patsubst $(SOURCEDIR)/%.c, $(BUILDDIR)/%.o, $(SOURCES))
OBJECTS_A = $(patsubst $(SOURCEDIR)/%.S, $(BUILDDIR)/%.o, $(SOURCES_A))

BINARY = firmware.elf


.PHONY: all clean sizes

################################################################################

all: firmware.hex firmware.objdump

################################################################################
%.objdump: %.elf
	$(TOOLCHAIN_PREFIX)objdump -D -M no-aliases $< > $@

%.bin: %.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@

%.hex: %.bin
	$(PYTHON) $(TOOLS)/makehex.py $^ 4096

# LINKING ######################################################################
$(BINARY): $(OBJECTS) $(OBJECTS_A)
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

# COMPILING ####################################################################
$(BUILDDIR)/%.o: $(SOURCEDIR)/%.c
	$(CC) $(CFLAGS) -o $@ $<

$(BUILDDIR)/%.o: $(SOURCEDIR)/%.S
	$(CC) $(SFLAGS) -o $@ $<


################################################################################

sizes: firmware.elf
	$(TOOLCHAIN_PREFIX)size $^

clean:
	$(RM) firmware*.elf firmware*.bin firmware*.hex firmware*.map firmware*.objdump
	$(RM) $(BINARY) $(OBJECTS) $(OBJECTS_A)
	$(RM) -f simulation_output.txt

report: simulation_output.txt
	@$(PYTHON) $(TOOLS)/parse_simulation.py $<
