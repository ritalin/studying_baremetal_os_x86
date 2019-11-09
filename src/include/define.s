BOOT_LOAD equ 0x7c00
BOOT_SIZE equ (1024 * 8)
SECT_SIZE equ (512)
BOOT_SECT equ (BOOT_SIZE / SECT_SIZE)

MEMORY_MAP_LEN equ 24

KERNEL_LOAD equ 0x0010_1000
KERNEL_SIZE equ (1024 * 8)
KERNEL_SECT equ (KERNEL_SIZE / SECT_SIZE)

BOOT_END equ (BOOT_LOAD + BOOT_SIZE)

VECT_BASE equ 0x0010_0000                       ; 割り込みベクタテーブル

CR3_BASE  equ 0x0010_5000                       ; ページディレクトリの先頭アドレス
CR3_BASE_SIZE equ 0x1000                        ; ページディレクトリのサイズ

RING_ITEM_SIZE equ (1 << 4)                     ; リングバッファサイズ
RING_INDEX_MASK equ (RING_ITEM_SIZE - 1)

STACK_BASE equ 0x0010_3000
STACK_SIZE equ 1024

SP_TASK_00 equ STACK_BASE + (STACK_SIZE * 1)    ; カーネルタスク用スタックアドレス
SP_TASK_01 equ STACK_BASE + (STACK_SIZE * 2)    ; タスク1用スタックアドレス
SP_TASK_02 equ STACK_BASE + (STACK_SIZE * 3)    ; タスク2用スタックアドレス
SP_TASK_03 equ STACK_BASE + (STACK_SIZE * 4)    ; タスク3用スタックアドレス

SP_TASK_04 equ STACK_BASE + (STACK_SIZE * 5)    ; タスク4用スタックアドレス
SP_TASK_05 equ STACK_BASE + (STACK_SIZE * 6)    ; タスク4用スタックアドレス
SP_TASK_06 equ STACK_BASE + (STACK_SIZE * 7)    ; タスク4用スタックアドレス
SP_TASK_07 equ STACK_BASE + (STACK_SIZE * 8)    ; タスク4用スタックアドレス
