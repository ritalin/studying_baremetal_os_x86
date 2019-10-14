ASM := nasm
VM := qemu-system-i386

SRC_DIR := src
OUT_DIR := _build

ASM_SEARCH_PATH := $(SRC_DIR)

PROGRAM := $(OUT_DIR)/boot.img
PROGRAM_LIST := $(patsubst %.img,%.list,$(PROGRAM))

.PHONY: all
all: ;

.PHONY: run
run: src_16
	$(VM) -monitor stdio $(PROGRAM)

.PHONY: src_16
src_15: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/16_load_kernel

.PHONY: src_14
src_13: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/14_a20

.PHONY: src_12
src_12:
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/12_get_mem_info

.PHONY: src_11
src_11:
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/11_font_address


.PHONY: src_10
src_10:
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/10_drive_param


.PHONY: src_08
src_08:
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/08_stage_2

.PHONY: src_07
src_07:
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/07_reboot

.PHONY: src_06
src_06:
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/06_func_itoa

.PHONY: src_05
src_05:
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/05_func_puts

.PHONY: src_03
src_03:
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/03_boot_putc

.PHONY: src_02
src_02:
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/02_save_data

.PHONY: src_01
src_01:
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/01_bpb

.PHONY: src_00
src_00:
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/00_boot_only

$(PROGRAM): $(foreach f,$(notdir $(patsubst %.s,%.bin, $(wildcard $(PROJECT)/*.s))),$(OUT_DIR)/$(f))
	cat $^ > $(PROGRAM)

$(OUT_DIR)/%.bin: $(PROJECT)/%.s
	$(ASM) $< -I$(ASM_SEARCH_PATH) \
	    -o $@ \
	    -l $(patsubst %.bin,%.list,$@)

.PHONY: clean
clean:
	@if [ ! -d $(OUT_DIR) ]; then \
		echo " creting $(OUT_DIR) directory...";  \
		mkdir $(OUT_DIR); \
	fi
	rm $(OUT_DIR)/*