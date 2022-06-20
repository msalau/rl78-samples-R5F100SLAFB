PROJECT_ELF := $(PROJECT).elf
PROJECT_MOT := $(PROJECT).mot
PROJECT_MAP := $(PROJECT).map
PROJECT_LST := $(PROJECT).lst

TOOL_PREFIX ?= rl78-elf-

LD      := $(TOOL_PREFIX)gcc
CC      := $(TOOL_PREFIX)gcc
AS      := $(TOOL_PREFIX)gcc
OBJCOPY := $(TOOL_PREFIX)objcopy
OBJDUMP := $(TOOL_PREFIX)objdump
SIZE    := $(TOOL_PREFIX)size
LINT    := splint

FLASHER       := rl78flash
FLASHER_PORT  ?= /dev/ttyUSB0
FLASHER_MODE  ?= 1
FLASHER_SPEED ?= 1000000

FLASHER_TERMINAL_SPEED ?= 1000000
ifdef START_TERMINAL
FLASHER_TERMINAL  := -t$(FLASHER_TERMINAL_SPEED)
else
FLASHER_TERMINAL  :=
endif

COMMON_PATH  := ../common
PROJECT_PATH := .

PROJECT_LNK := $(COMMON_PATH)/R5F100xL.ld

INCLUDE := -I$(PROJECT_PATH) -I$(COMMON_PATH)
ASFLAGS := -MMD
CFLAGS  := -std=gnu89 -mcpu=g13 -Wall -Wextra -Wno-main -Os -ggdb -ffunction-sections -fdata-sections -MMD $(INCLUDE)
LDFLAGS := -mcpu=g13 -Wl,--gc-sections -Wl,-Map=$(PROJECT_MAP) -T $(PROJECT_LNK)
LIBS    := -lm

CPATH := `$(CC) -print-file-name=include`

LINTFLAGS := \
	-linelen 10000 \
	+quiet \
	+stats \
	+show-summary \
	$(INCLUDE) \
	+boolint \
	+charint \
	+slashslashcomment \
	+declundef \
	+relax-types \
	+nullptrarith \
	+sizeoftype \
	+looploopbreak \
	+loopswitchbreak \
	+evalorderuncon \
	+bitwisesigned \
	+matchanyintegral \
	-D'__attribute__(a)=' \
	-D'__asm__(a)=' \
	-D'asm(a)=' \
	-D'__far=' \
	$(END)

OBJS := $(SRC_C:.c=.o) \
	$(SRC_S:.S=.o) \
	$(END)

DEPS := $(OBJS:.o=.d)

.PHONY: all rom check flash erase clean reset

all: $(PROJECT_MOT) $(PROJECT_LST)
	$(SIZE) $(PROJECT_ELF)

rom: $(PROJECT_MOT)

check: $(SRC_C)
	CPATH=$(CPATH) $(LINT) $(LINTFLAGS) $^

$(PROJECT_MOT): $(PROJECT_ELF)
	$(OBJCOPY) -O srec $^ $@

$(PROJECT_LST): $(PROJECT_ELF)
	$(OBJDUMP) -DS $^ > $@

$(PROJECT_ELF): $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^ $(LIBS)

flash: $(PROJECT_MOT)
	$(FLASHER) -vvwri -m$(FLASHER_MODE) -b$(FLASHER_SPEED) $(FLASHER_TERMINAL) $(FLASHER_PORT) $^

reset:
	$(FLASHER) -r $(FLASHER_TERMINAL) $(FLASHER_PORT)

erase:
	$(FLASHER) -vveri -m$(FLASHER_MODE) -b$(FLASHER_SPEED) $(FLASHER_PORT)

clean:
	-rm -f $(OBJS) $(DEPS) $(PROJECT_ELF) $(PROJECT_MOT) $(PROJECT_MAP) $(PROJECT_LST)

-include $(DEPS)
