;********************************************************************************
; 何もしないブートプログラム
;********************************************************************************
BOOT_LOAD equ 0x7c00
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

        mov [BOOT.DRIVE], dl

        cdecl puts, .s0
        cdecl reboot            ; 戻ってこない
        cdecl puts, .s1

        jmp $

.s0:    db "Booting...", 0x0A, 0x0D, 0   
.s1:    db "(STOPPED)", 0x0A, 0x0D, 0      
ALIGN 2, db 0
BOOT:
.DRIVE:
        dw 0

%include "modules/real/puts.s"
%include "modules/real/reboot.s"

;********************************************************************************
; ブートフラグ
;********************************************************************************
        times 510 - ($-$$) db 0x00
        db 0x55, 0xAA

