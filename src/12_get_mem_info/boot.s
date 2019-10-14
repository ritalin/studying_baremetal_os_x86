;********************************************************************************
; ブートローダ
;********************************************************************************
%include "include/define.s"

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
; フォント情報の格納先
;********************************************************************************
FONT:
        istruc font
            at font.seg, dw 0
            at font.off, dw 0
        iend

%include "modules/real/itoa.s"
%include "modules/real/get_drive_param.s"

;********************************************************************************
; Stage2
;********************************************************************************
stage2:
        cdecl puts, .s0

        ; ** ドライブ情報を取得する
        cdecl get_drive_param, BOOT
        cmp ax, 0
        jne .BOOT_PARAM_FOUND
        cdecl puts, .err0
        cdecl reboot            ; 再起動
.BOOT_PARAM_FOUND:
        
        ; ** ドライブパラメータの表示
        mov ax, [BOOT + drive.no]
        cdecl itoa, ax, .p1, 2, 16, 0b0010
        mov ax, [BOOT + drive.cyln]
        cdecl itoa, ax, .p2, 4, 16, 0b0010
        mov ax, [BOOT + drive.head]
        cdecl itoa, ax, .p3, 3, 10, 0b0010
        mov ax, [BOOT + drive.sect]
        cdecl itoa, ax, .p4, 3, 10, 0b0010        
        cdecl puts, .s1

        jmp stage_3

.s0:    db "2nd Stage...", 0x0A, 0x0D, 0 

.s1:    db "  Drive:0x"
.p1:    db "  , C:0x"
.p2:    db "   , H:"
.p3:    db "   , S:"
.p4:    db "   "
.p5:    db 0x0A, 0x0D, 0

.err0:  db "Cannot get drive parameter.", 0x0A, 0x0D, 0

%include "modules/real/get_font_address.s"
%include "modules/real/get_mem_info.s"

;********************************************************************************
; Stage3
;********************************************************************************
stage_3:
        cdecl puts, .s0

        ; ** フォント情報の取得 **
        cdecl get_font_address, FONT

        cdecl itoa, word [FONT + font.seg], .p1, 4, 16, 0b0010 
        cdecl itoa, word [FONT + font.off], .p2, 4, 16, 0b0010 
        cdecl puts, .s1

        ; ** メモリマップの取得 **
        cdecl put_mem_info_header

        mov [.MEMORY_MAP + mem_map_buf.next], dword 0
.MEM_MAP_BEGIN:
        cdecl get_mem_info, .MEMORY_MAP

mov eax, .MEMORY_MAP
        cdecl put_mem_info, .MEMORY_MAP

        mov eax, [.MEMORY_MAP + mem_map_buf.next]
        cmp eax, 0
        jne .MEM_MAP_BEGIN
.MEM_MAP_END:

        cdecl put_mem_info_footer

        jmp $

.MEMORY_MAP:
        istruc mem_map_buf
            at mem_map_buf.addr, dw 0x0000, 0x0000, 0x0000, 0x0000
            at mem_map_buf.len,  dw 0x0000, 0x0000, 0x0000, 0x0000
            at mem_map_buf.type, dw 0x0000, 0x0000
            at mem_map_buf.acpi, dw 0x0000, 0x0000
            at mem_map_buf.next, dw 0x0000, 0x0000
        iend
    
.s0:    db "3rd stage...", 0x0A, 0x0D, 0
.s1:    db "  Font address="
.p1:    db "ZZZZ:"
.p2:    db "ZZZZ"
.p3:    db 0x0A, 0x0D, 0

.t1:    db "     -"
.t2:    db "     ", 0x0A, 0x0D, 0

;********************************************************************************
; パディング(8kB)
;********************************************************************************
        times BOOT_SIZE - ($-$$) db 0x00


