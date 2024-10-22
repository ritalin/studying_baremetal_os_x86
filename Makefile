ASM := nasm
VM := qemu-system-i386

SRC_DIR := src
OUT_DIR := _build

SRC := boot.s kernel.s

ASM_SEARCH_PATH := $(SRC_DIR)

PROGRAM := $(OUT_DIR)/boot.img
PROGRAM_LIST := $(patsubst %.img,%.list,$(PROGRAM))

.PHONY: all
all: ;

.PHONY: run
run: src_45
	$(VM) -monitor stdio -m size=256 -drive file=$(PROGRAM),format=raw -boot order=c -rtc base=localtime

.PHONY: src_45
src_45:
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/45_fat_bios

.PHONY: src_44
src_44:
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/44_to_real_mode

.PHONY: src_43
src_43:
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/43_fat

.PHONY: src_42
src_42:
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/42_rose_multi

.PHONY: src_41
src_41:
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/41_page_fault

.PHONY: src_40
src_40:
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/40_paging

.PHONY: src_39
src_39:
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/39_rose

.PHONY: src_38
src_38: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/38_fpu_multi

.PHONY: src_37
src_37: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/37_fpu

.PHONY: src_35
src_35: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/35_trap_gate

.PHONY: src_34
src_34: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/34_call_gate

.PHONY: src_33
src_33: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/33_pre_emptive

.PHONY: src_32
src_32: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/32_task_non_pre

.PHONY: src_31
src_31: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/31_multi_task

.PHONY: src_30
src_30: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/30_int_timer

.PHONY: src_29
src_29: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/29_int_keyboard

.PHONY: src_28
src_28: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/28_int_rtc

.PHONY: src_27
src_27: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/27_int_div_zero

.PHONY: src_26
src_26: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/26_int_default

.PHONY: src_25
src_25: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/25_draw_time

.PHONY: src_24
src_24: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/24_draw_rect

.PHONY: src_23
src_23: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/23_draw_line

.PHONY: src_23D
src_23D: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/23d_itoa32

.PHONY: src_22
src_22: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/22_draw_pixel

.PHONY: src_21
src_21: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/21_draw_color_bar

.PHONY: src_20
src_20: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/20_draw_str

.PHONY: src_19
src_19: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/19_draw_font

.PHONY: src_18
src_18: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/18_draw_char

.PHONY: src_17
src_17: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/17_draw_plane

.PHONY: src_16
src_16: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/16_protect_mode

.PHONY: src_15
src_15: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/15_load_kernel

.PHONY: src_14
src_14: 
	$(MAKE) -B $(PROGRAM) PROJECT=$(SRC_DIR)/14_a20 SRC=boot.s

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

$(PROGRAM): $(foreach f,$(patsubst %.s,%.bin, $(SRC)),$(OUT_DIR)/$(f)) 
	cat $^ > $(PROGRAM)

$(OUT_DIR)/%.bin: $(PROJECT)/%.s
	$(ASM) $< -I$(ASM_SEARCH_PATH) \
	    -o $@ \
	    -l $(patsubst %.bin,%.list,$@) -I $(PROJECT)

.PHONY: clean
clean:
	@if [ ! -d $(OUT_DIR) ]; then \
		echo " creting $(OUT_DIR) directory...";  \
		mkdir $(OUT_DIR); \
	fi
	rm $(OUT_DIR)/*