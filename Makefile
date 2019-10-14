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
run: src_13
	$(VM) -monitor stdio $(PROGRAM)

.PHONY: src_15
src_15: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/15_load_kernel

.PHONY: src_13
src_13: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/13_a20
	$(ASM) $(SRC_DIR)/13_a20/boot.s -I$(ASM_SEARCH_PATH) -o $(PROGRAM) -l $(PROGRAM_LIST) 

.PHONY: src_12
src_12:
	$(ASM) $(SRC_DIR)/12_get_mem_info/boot.s -I$(ASM_SEARCH_PATH) -o $(PROGRAM) -l $(PROGRAM_LIST) 

.PHONY: src_11
src_11:
	$(ASM) $(SRC_DIR)/11_font_address/boot.s -I$(ASM_SEARCH_PATH) -o $(PROGRAM) -l $(PROGRAM_LIST) 

.PHONY: src_10
src_10:
	$(ASM) $(SRC_DIR)/10_drive_param/boot.s -I$(ASM_SEARCH_PATH) -o $(PROGRAM) -l $(PROGRAM_LIST) 

.PHONY: src_08
src_08:
	$(ASM) $(SRC_DIR)/08_stage_2/boot.s -I$(ASM_SEARCH_PATH) -o $(PROGRAM) -l $(PROGRAM_LIST) 

.PHONY: src_07
src_07:
	$(ASM) $(SRC_DIR)/07_reboot/boot.s -I$(ASM_SEARCH_PATH) -o $(PROGRAM) -l $(PROGRAM_LIST) 

.PHONY: src_06
src_06:
	$(ASM) $(SRC_DIR)/06_func_itoa/boot.s -I$(ASM_SEARCH_PATH) -o $(PROGRAM) -l $(PROGRAM_LIST) 

.PHONY: src_05
src_05:
	$(ASM) $(SRC_DIR)/05_func_puts/boot.s -I$(ASM_SEARCH_PATH) -o $(PROGRAM) -l $(PROGRAM_LIST) 

.PHONY: src_03
src_03:
	$(ASM) $(SRC_DIR)/03_boot_putc/boot.s -I$(ASM_SEARCH_PATH) -o $(PROGRAM) -l $(PROGRAM_LIST) 

.PHONY: src_02
src_02:
	$(ASM) $(SRC_DIR)/02_save_data/boot.s -o $(PROGRAM) -l $(PROGRAM_LIST) 

.PHONY: src_01
src_01:
	$(ASM) $(SRC_DIR)/01_bpb/boot.s -o $(PROGRAM) -l $(PROGRAM_LIST) 

.PHONY: src_00
src_00:
	$(ASM) $(SRC_DIR)/00_boot_only/boot.s -o $(PROGRAM) -l $(PROGRAM_LIST) 

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