ASM = nasm

SRC_DIR = src
OUT_DIR = _build

PROGRAM = $(OUT_DIR)/boot.img
PROGRAM_LIST = $(patsubst %.img,%.list,$(PROGRAM))

.PHONY: all
all: ;

.PHONY: run
run: src_00
	qemu-system-i386 $(PROGRAM)

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