### Program Name
TARGET=main

### Linker Script
LDFILE = stm32l412kb.ld

### Device
DEVICE = STM32L412xx

### Toolchain directory
TOOLCHAIN_DIR = /opt/arm-none-eabi/10-2020-q4/bin/

CC = ${TOOLCHAIN_DIR}arm-none-eabi-gcc
LD = ${TOOLCHAIN_DIR}arm-none-eabi-gcc
AR = ${TOOLCHAIN_DIR}arm-none-eabi-ar
AS = ${TOOLCHAIN_DIR}arm-none-eabi-as
CP = ${TOOLCHAIN_DIR}arm-none-eabi-objcopy
OD = ${TOOLCHAIN_DIR}arm-none-eabi-objdump
SZ = ${TOOLCHAIN_DIR}arm-none-eabi-size

### Includes
CMSIS_INC_DIR = CMSIS/Include
CMSIS_ST_INC_DIR = CMSIS/Device/ST/STM32L4xx/Include
USER_INC = inc

INC = ${CMSIS_INC_DIR} ${CMSIS_ST_INC_DIR} ${USER_INC}
INC_PARAMS = ${foreach d, ${INC}, -I$d}

### Sources
CMSIS_SYS_SRC = CMSIS/Device/ST/STM32L4xx/Source/Templates/system_stm32l4xx.c
CMSIS_START_SRC = CMSIS/Device/ST/STM32L4xx/Source/Templates/gcc/startup_stm32l412xx.s
USER_SRC = ${wildcard src/*.c }

SRC_C = ${CMSIS_SYS_SRC} ${USER_SRC}
OBJS_C = ${patsubst %.c,%.o,${SRC_C}}
SRC_S = ${CMSIS_START_SRC}
OBJS_S = ${patsubst %.s,%.o,${SRC_S}}
OBJS = ${OBJS_C} ${OBJS_S}

### CFLAGS
# 'Standard Options'
CFLAGS = -Wall -Wextra -Wshadow -Wdouble-promotion -O2 -g ${INC_PARAMS}
# Device Specific
CFLAGS += -D${DEVICE} -mcpu=cortex-m4 -mthumb -T${LDFILE}
# Specs, map
CFLAGS += -specs=nosys.specs -Wl,-Map=${TARGET}.map  --specs=nano.specs
# Remove unused sections
CFLAGS += -Wl,--gc-sections  -ffunction-sections -fdata-sections
# FPU
CFLAGS += -mfpu=fpv4-sp-d16 -mfloat-abi=hard

### Rules
.PHONY: all clean ${TARGET} ${TARGET}.elf ${TARGET}.bin flash size
all: clean ${TARGET} size

debug: CFLAGS += -O0
debug: all

${TARGET}: ${TARGET}.elf

${TARGET}.elf: ${OBJS}
	${CC} ${CFLAGS} -o $@ $^
	${CP} -O binary ${TARGET}.elf ${TARGET}.bin

%.o:%.c
	${CC} ${CFLAGS} -c $^ -o $@

%.o:%.s
	${CC} ${CFLAGS} -c -x assembler-with-cpp $^ -o $@

disass: ${TARGET}.elf
	${OD} -drwCSg ${TARGET}.elf > ${TARGET}.cdasm

size:
	${SZ} ${TARGET}.elf

clean:
	rm -f *.o ${TARGET}.elf ${TARGET}.bin ${TARGET}.map
	-@find . -type f -name '*.o' -delete 2>/dev/null

flash:
	openocd -f board/st_nucleo_l4.cfg -c "program main.elf verify reset exit"
