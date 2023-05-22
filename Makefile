# Author: Jake Goodwin
# Date: 2023
# Description: The makefile for building projects on the LGT8F328P nano3
# compadible platform

PROJECT = demo
TARGET := lgt8f328p_$(PROJECT)
BUILD_DIR := ./build
SRC_DIRS := ./src
LIB_DIRS := ./lib

CC=avr-gcc
CPP= avr-g++
MCU= atmega328p
MCU_DUDE = lgt8f328p

## Options common to compile, link and assembly rules
COMMON = -mmcu=$(MCU)

## Compile options common for all C compilation units.
CFLAGS = $(COMMON)
CFLAGS += -Wall -gdwarf-2 -Os -std=c11 -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums
CFLAGS += -MD -MP -MT $(BUILD_DIR)/$(*F).o -MF $(BUILD_DIR)/$(@F).d 

## Assembly specific flags
ASMFLAGS = $(COMMON)
ASMFLAGS += $(CFLAGS)
ASMFLAGS += -x assembler-with-cpp -Wa,-gdwarf2

## Linker flags
LDFLAGS = $(COMMON)
LDFLAGS +=  -Wl,-Map=$(BUILD_DIR)/lgt8f328p_$(PROJECT).map


## Intel Hex file production flags
HEX_FLASH_FLAGS = -R .eeprom -R .fuse -R .lock -R .signature

HEX_EEPROM_FLAGS = -j .eeprom
HEX_EEPROM_FLAGS += --set-section-flags=.eeprom="alloc,load"
HEX_EEPROM_FLAGS += --change-section-lma .eeprom=0 --no-change-warnings

# Find all the C and C++ files we want to compile
# Note the single quotes around the * expressions. The shell will incorrectly expand these otherwise, but we want to send the * directly to the find command.
SRCS := $(shell find $(SRC_DIRS) -name '*.cpp' -or -name '*.c' -or -name '*.s')

# Prepends BUILD_DIR and appends .o to every src file
# As an example, ./your_dir/hello.cpp turns into ./build/./your_dir/hello.cpp.o
TMP := $(SRCS:$(SRC_DIRS)/%=%)
OBJS := $(TMP:%.c=$(BUILD_DIR)/%.o)
OBJECT_TARGETS := $(TMP:%.c=%.o)
#OBJS := $(patsubst %.o,%.c,$(SRCS))


LINKONLYOBJECTS = 

# String substitution (suffix version without %).
# As an example, ./build/hello.cpp.o turns into ./build/hello.cpp.d
DEPS := $(OBJS:.o=.d)

#INC_DIRS := $(shell find $(SRC_DIRS) -type d)
INC_DIRS := ./include

# Add a prefix to INC_DIRS. So moduleA would become -ImoduleA. GCC understands this -I flag
INC_FLAGS := $(addprefix -I,$(INC_DIRS))


# Programmer stuff
F_CPU= 16000000UL
LOCK = 0x3f
#BAUD=115200UL
#PROGRAMMER_TYPE = usbasp-clone
PROGRAMMER_TYPE = stk500v1
PROGRAMMER_ARGS = -P /dev/ttyACM0 -B 4 -v -Ulock:w:$(LOCK):m
AVRSIZE = avr-size
AVRDUDE = avrdude
#TARGET = $(lastword $(subst /, ,$(CURDIR)))
CPPFLAGS = -DF_CPU=$(F_CPU) -DBAUD=$(BAUD) -I. $(INC_FLAGS)

.PHONY: all disassemble disasm eeprom size clean squeaky_clean flash fuses


# BUILD
all: $(TARGET) lgt8f328p_$(PROJECT).hex lgt8f328p_$(PROJECT).eep lgt8f328p_$(PROJECT).lss size

info:
	@echo SOURCES $(SRCS)
	@echo
	@echo TMP $(TMP)
	@echo
	@echo OBJECTS $(OBJS)
	@echo
	@echo DEPS $(DEPS)
	@echo
	@echo TARGET $(TARGET)
	@echo
	@echo OBJECT_TARGETS $(OBJECT_TARGETS)

# COMPILE
lgt8f328p_acdac.o: $(SRC_DIRS)/lgt8f328p_acdac.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(INC_FLAGS) -c $< -o $(BUILD_DIR)/$@

lgt8f328p_adc.o: $(SRC_DIRS)/lgt8f328p_adc.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(INC_FLAGS) -c $< -o $(BUILD_DIR)/$@

lgt8f328p_e2pctl.o: $(SRC_DIRS)/lgt8f328p_e2pctl.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(INC_FLAGS) -c $< -o $(BUILD_DIR)/$@

lgt8f328p_sleep.o: $(SRC_DIRS)/lgt8f328p_sleep.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(INC_FLAGS) -c $< -o $(BUILD_DIR)/$@

lgt8f328p_misc.o: $(SRC_DIRS)/lgt8f328p_misc.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(INC_FLAGS) -c $< -o $(BUILD_DIR)/$@

lgt8f328p_intr.o: $(SRC_DIRS)/lgt8f328p_intr.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(INC_FLAGS) -c $< -o $(BUILD_DIR)/$@

lgt8f328p_usart.o: $(SRC_DIRS)/lgt8f328p_usart.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(INC_FLAGS) -c $< -o $(BUILD_DIR)/$@

main.o: $(SRC_DIRS)/main.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(INC_FLAGS) -c $< -o $(BUILD_DIR)/$@


#$(OBJS): $(SRCS)
#	$(CC) $(CFLAGS) $(INC_FLAGS) $(LIBS) $(LIBDIR) -c $< -o $@

# LINK
$(TARGET): $(OBJECT_TARGETS)
	 $(CC) $(LDFLAGS) $(OBJS) $(LINKONLYOBJECTS) $(LIBDIRS) $(LIBS) -o $(BUILD_DIR)/$(TARGET)

%.hex: $(TARGET)
	avr-objcopy -O ihex $(HEX_FLASH_FLAGS)  $(BUILD_DIR)/$< $(BUILD_DIR)/$@

%.eep: $(TARGET)
	-avr-objcopy $(HEX_EEPROM_FLAGS) -O ihex $(BUILD_DIR)/$< $(BUILD_DIR)/$@ || exit 0

%.lss: $(TARGET)
	avr-objdump -h -S $(BUILD_DIR)/$< > $(BUILD_DIR)/$@

size: ${TARGET}
	@echo
	@avr-size -C --mcu=${MCU} ${BUILD_DIR}/${TARGET}


##########------------------------------------------------------##########
##########              Programmer-specific details             ##########
##########           Flashing code to AVR using avrdude         ##########
##########------------------------------------------------------##########

flash: $(TARGET).hex 
	$(AVRDUDE) -c $(PROGRAMMER_TYPE) -p $(MCU_DUDE) $(PROGRAMMER_ARGS) -e -U flash:w:$(BUILD_DIR)/$<:i

## An alias
program: flash

flash_eeprom: $(TARGET).eeprom
	$(AVRDUDE) -c $(PROGRAMMER_TYPE) -p $(MCU_DUDE) $(PROGRAMMER_ARGS) -U eeprom:w:$<

avrdude_terminal:
	$(AVRDUDE) -c $(PROGRAMMER_TYPE) -p $(MCU_DUDE) $(PROGRAMMER_ARGS) -nt


## If you've got multiple programmers that you use, 
## you can define them here so that it's easy to switch.
## To invoke, use something like `make flash_arduinoISP`
flash_lgt8f328p: PROGRAMMER_TYPE = stk500v1 
flash_lgt8f328p: PROGRAMMER_ARGS = -P /dev/ttyACM0
flash_lgt8f328p: flash

##########------------------------------------------------------##########
##########       Fuse settings and suitable defaults            ##########
##########------------------------------------------------------##########

# These are for the lgt8f328p 32pin controllers
LFUSE = 0xff
HFUSE = 0xff
EFUSE = 0xff

## Generic 
FUSE_STRING = -U lfuse:w:$(LFUSE):m -U hfuse:w:$(HFUSE):m -U efuse:w:$(EFUSE):m 

fuses: 
	$(AVRDUDE) -c $(PROGRAMMER_TYPE) -p $(MCU_DUDE) \
	           $(PROGRAMMER_ARGS) $(FUSE_STRING)
show_fuses:
	$(AVRDUDE) -c $(PROGRAMMER_TYPE) -p $(MCU_DUDE) $(PROGRAMMER_ARGS) -nv	

## Called with no extra definitions, sets to defaults
set_default_fuses:  FUSE_STRING = -U lfuse:w:$(LFUSE):m -U hfuse:w:$(HFUSE):m -U efuse:w:$(EFUSE):m 
set_default_fuses:  fuses

## Set the fuse byte for full-speed mode
## Note: can also be set in firmware for modern chips
set_fast_fuse: LFUSE = 0xE2
set_fast_fuse: FUSE_STRING = -U lfuse:w:$(LFUSE):m 
set_fast_fuse: fuses

## Set the EESAVE fuse byte to preserve EEPROM across flashes
set_eeprom_save_fuse: HFUSE = 0xD7
set_eeprom_save_fuse: FUSE_STRING = -U hfuse:w:$(HFUSE):m
set_eeprom_save_fuse: fuses

## Clear the EESAVE fuse byte
clear_eeprom_save_fuse: FUSE_STRING = -U hfuse:w:$(HFUSE):m
clear_eeprom_save_fuse: fuses

.PHONY: clean
clean:
	rm -r $(BUILD_DIR)/*

# Include the .d makefiles. The - at the front suppresses the errors of missing
# Makefiles. Initially, all the .d files will be missing, and we don't want those
# errors to show up.
-include $(DEPS)
