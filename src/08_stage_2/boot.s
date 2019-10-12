;********************************************************************************
; ブートローダ
;********************************************************************************
BOOT_LOAD equ 0x7c00
BOOT_SIZE equ (1024 * 8)
SECT_SIZE equ (512)
BOOT_SECT equ (BOOT_SIZE / SECT_SIZE)

ORG BOOT_LOAD

entry:
        jmp ipl

;********************************************************************************
; BPB
;********************************************************************************
        times 90 - ($-$$) db 0x90 ; nop

%include "include/macro.s"

;********************************************************************************
; Initial Program Loader
;********************************************************************************
ipl:
        cli
        xor ax, ax
        mov ds, ax
        mov es, ax
        mov ss, ax
        mov sp, BOOT_LOAD
        sti

        mov [BOOT + drive.no], dl

        cdecl puts, .s0

        ; ** 第2ステージのロード **
        mov bx, BOOT_SECT-1             ; 読み込むセクタ数
        mov cx, BOOT_LOAD + SECT_SIZE   ; 展開先アドレス
        cdecl read_chs, BOOT, bx, cx

        cmp ax, bx                      ; 指定したセクタ数を読み込んだかどうか
        jz .LOAD_2ND_STAGE_SUCCESS   

        cdecl puts, .err0
        cdecl reboot            ; 再起動
.LOAD_2ND_STAGE_SUCCESS:
        jmp stage2

.s0:    db "Booting...", 0x0A, 0x0D, 0   
.err0:  db "ERROR: Sector Read", 0x0A, 0x0D, 0   

ALIGN 2, db 0
BOOT:
        istruc drive      
            at drive.no,   dw 0
            at drive.cyln, dw 0
            at drive.head, dw 0
            at drive.sect, dw 2
        iend

%include "modules/real/puts.s"
%include "modules/real/reboot.s"
%include "modules/real/read_chs.s"

;********************************************************************************
; ブートフラグ
;********************************************************************************
        times 510 - ($-$$) db 0x00
        db 0x55, 0xAA

;********************************************************************************
; Stage2
;********************************************************************************
stage2:
        cdecl puts, .s0

        jmp $

.s0:    db "2nd Stage...", 0x0A, 0x0D, 0 

;********************************************************************************
; パディング(8kB)
;********************************************************************************
        times BOOT_SIZE - ($-$$) db 0x00


