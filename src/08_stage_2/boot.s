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

        ; ** 第2ステージのロード **
        mov ah, 0x02            ; 読み込み命令
        mov al, 1               ; 読み込みセクタ数
        mov cx, 0x0002          ; シリンダ / セクタ位置
        mov dh, 0x00            ; ヘッド位置
        mov dl, [BOOT.DRIVE]    ; ドライブ番号
        mov bx, BOOT_LOAD + 512 ; 展開先アドレス
        int 0x13
        jnc .LOAD_2ND_STAGE_SUCCESS
        cdecl puts, .err0
        cdecl reboot            ; 再起動
.LOAD_2ND_STAGE_SUCCESS:
        jmp $

.s0:    db "Booting...", 0x0A, 0x0D, 0   
.err0:  db "ERROR: Sector Read", 0x0A, 0x0D, 0   

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

