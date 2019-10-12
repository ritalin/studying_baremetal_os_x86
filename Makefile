ASM := nasm
VM := qemu-system-i386

SRC_DIR := src
OUT_DIR := _build

PROGRAM := $(OUT_DIR)/boot.img
PROGRAM_LIST := $(patsubst %.img,%.list,$(PROGRAM))

.PHONY: all
all: ;

.PHONY: run
run: src_02
	$(VM) $(PROGRAM)

.PHONY: src_02
src_02:
	$(ASM) $(SRC_DIR)/02_save_data/boot.s -o $(PROGRAM) -l $(PROGRAM_LIST) 

.PHONY: src_01
src_01:
	$(ASM) $(SRC_DIR)/01_bpb/boot.s -o $(PROGRAM) -l $(PROGRAM_LIST) 

.PHONY: src_00
src_00:
	$(ASM) $(SRC_DIR)/00_boot_only/boot.s -o $(PROGRAM) -l $(PROGRAM_LIST) 

.PHONY: clean
clean:
	@if [ ! -d $(OUT_DIR) ]; then \
		echo " creting $(OUT_DIR) directory...";  \
		mkdir $(OUT_DIR); \
	fi
	rm $(OUT_DIR)/*