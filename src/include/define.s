BOOT_LOAD equ 0x7c00
BOOT_SIZE equ (1024 * 8)
SECT_SIZE equ (512)
BOOT_SECT equ (BOOT_SIZE / SECT_SIZE)

MEMORY_MAP_LEN equ 24

;           |____________| 
; 0010_0000 |       (2K) | 割り込みディスクリプタテーブル
;           |____________| 
; 0010_0800 |       (2K) | カーネルスタック
;           |____________| 
; 0010_1000 |      (12K) | カーネルプログラム
;           |            | 
;           =            = 
;           |____________| 
; 0010_4000 |      (12K) | タスク用スタック領域
;           |            | 
;           =            = 
;           |____________| 
; 0010_7000 |       (4K) | ページディレクトリエントリ
;           |____________| 
; 0010_8000 |       (4K) | ページテーブルエントリ(1ディレクトリ分 = 4MB) 
;           |____________| 
;           |            | 
;           =            = 

VECT_BASE equ 0x0010_0000                       ; 割り込みベクタテーブル

KERNEL_LOAD equ 0x0010_1000
KERNEL_SIZE equ (1024 * 12)                     ; 12kB
KERNEL_SECT equ (KERNEL_SIZE / SECT_SIZE)

BOOT_END equ (BOOT_LOAD + BOOT_SIZE)

STACK_BASE equ 0x0010_4000
STACK_SIZE equ 1024

CR3_BASE  equ 0x0010_7000                       ; ページディレクトリの先頭アドレス
CR3_PDE_SIZE equ 0x1000
CR3_PTE_SIZE equ 0x1000
CR3_SIZE equ (CR3_PDE_SIZE + CR3_PTE_SIZE)

RING_ITEM_SIZE equ (1 << 4)                     ; リングバッファサイズ
RING_INDEX_MASK equ (RING_ITEM_SIZE - 1)

SP_TASK_00 equ (STACK_BASE + (STACK_SIZE * 1))          ; カーネルタスク用スタックアドレス
SP_TASK_01 equ (STACK_BASE + (STACK_SIZE * 2))          ; タスク1用スタックアドレス
SP_TASK_02 equ (STACK_BASE + (STACK_SIZE * 3))          ; タスク2用スタックアドレス
SP_TASK_03 equ (STACK_BASE + (STACK_SIZE * 4))          ; タスク3用スタックアドレス

SP_TASK_04 equ (STACK_BASE + (STACK_SIZE * 5))          ; タスク4用スタックアドレス
SP_TASK_05 equ (STACK_BASE + (STACK_SIZE * 6))          ; タスク5用スタックアドレス
SP_TASK_06 equ (STACK_BASE + (STACK_SIZE * 7))          ; タスク6用スタックアドレス
SP_TASK_07 equ (STACK_BASE + (STACK_SIZE * 8))          ; タスク7用スタックアドレス

PARAM_TASK_04 equ (CR3_BASE + CR3_SIZE * 0 + CR3_PDE_SIZE)  ; タスク4用描画パラメータ
PARAM_TASK_05 equ (CR3_BASE + CR3_SIZE * 1 + CR3_PDE_SIZE)  ; タスク5用描画パラメータ
PARAM_TASK_06 equ (CR3_BASE + CR3_SIZE * 2 + CR3_PDE_SIZE)  ; タスク6用描画パラメータ
PARAM_TASK_07 equ (CR3_BASE + CR3_SIZE * 3 + CR3_PDE_SIZE)  ; タスク7用描画パラメータ

TASK_PAGE_BASE equ 0x0020_0000                              ; タスク用PDEのベースアドレス

CR3_TASK_05 equ (TASK_PAGE_BASE + CR3_SIZE * 0)             ; タスク5用PDEの先頭アドレス    
CR3_TASK_06 equ (TASK_PAGE_BASE + CR3_SIZE * 1)             ; タスク6用PDEの先頭アドレス
CR3_TASK_07 equ (TASK_PAGE_BASE + CR3_SIZE * 2)             ; タスク7用PDEの先頭アドレス

CR3_TASK_PTE_05 equ (TASK_PAGE_BASE + CR3_SIZE * 0 + CR3_PTE_SIZE)  ; タスク5用PDEの先頭アドレス    
CR3_TASK_PTE_06 equ (TASK_PAGE_BASE + CR3_SIZE * 1 + CR3_PTE_SIZE)  ; タスク6用PDEの先頭アドレス
CR3_TASK_PTE_07 equ (TASK_PAGE_BASE + CR3_SIZE * 2 + CR3_PTE_SIZE)  ; タスク7用PDEの先頭アドレス

; *****************************************************************************
; FAT16定数定義
; *****************************************************************************

FAT_SIZE equ (128 * 1024)                                   ; 1つ当たりのFAT領域のサイズ = 最大クラスタ数(65535) * 2byte
FAT_ROOT_DIR_SIZE equ (512 * 32)                            ; ルートディレクトリサイズ = ルートディレクトリ数(512) * 32byte

FAT1_OFFSET equ (KERNEL_SIZE)                               ; kernelの後続にFAT1領域を配置する
FAT2_OFFSET equ (FAT1_OFFSET + FAT_SIZE)                    ; FAT1領域の後続にFAT2領域を配置する
FAT_ROOT_OFFSET equ (FAT2_OFFSET + FAT_SIZE)                ; FAT2領域の後続にルートディレクトリ領域を配置する
FAT_FILE_OFFSET equ (FAT_ROOT_OFFSET + FAT_ROOT_DIR_SIZE)   ; ルートディレクトリ領域の後続にデータ領域を配置する

FAT_ATTR_VOLUME_ID equ (1 << 3)
FAT_ATTR_ARCHIVE   equ (1 << 5)
