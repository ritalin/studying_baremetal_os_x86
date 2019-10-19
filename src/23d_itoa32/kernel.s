%include "include/define.s"
%include "include/macro.s"

        ORG KERNEL_LOAD

[BITS 32]
;********************************************************************************
; エントリポイント
;********************************************************************************
kernel:
        ; ** フォントアドレスを取得する **
        mov esi, BOOT_LOAD + SECT_SIZE      ; ESI = 0x7c00 + 512
        movzx eax, word [esi + font.seg]    ; フォントセグメント
        movzx ebx, word [esi + font.off]    ; フォントオフセットアドレス
        shl eax, 4                          ; リアルモードセグメントアドレスのため
        add eax, ebx                        ; 実アドレスを計算
        mov [FONT], eax

        ; ** フォントをを印字
        cdecl draw_font, 63, 13

        ; ** 文字列を印字する
        cdecl draw_str, 25, 14, 0x010F, .s0

        ; ** カラーバーを出力する
        cdecl draw_color_bar, 63, 4

        ; ** ドットを描画する
        cdecl draw_pixel,  8,  4, 0x01
        cdecl draw_pixel,  9,  5, 0x01
        cdecl draw_pixel, 10,  6, 0x02
        cdecl draw_pixel, 11,  7, 0x02
        cdecl draw_pixel, 12,  8, 0x03
        cdecl draw_pixel, 13,  9, 0x03
        cdecl draw_pixel, 14, 10, 0x04
        cdecl draw_pixel, 15, 11, 0x04

        cdecl draw_pixel, 15,  4, 0x03
        cdecl draw_pixel, 14,  5, 0x03
        cdecl draw_pixel, 13,  6, 0x02
        cdecl draw_pixel, 12,  7, 0x02
        cdecl draw_pixel, 11,  8, 0x01
        cdecl draw_pixel, 10,  9, 0x01
        cdecl draw_pixel,  9, 10, 0x02
        cdecl draw_pixel,  8, 11, 0x02

        ; ** 数値文字列変換のテスト
        cdecl itoa, 0, .s1, 16, 10, 0b0000       ; #1 ok
        cdecl draw_str, 25, 15, 0x0F, .s1

        cdecl itoa, 8086, .s1, 16, 10, 0b0010    ; #2 ok
        cdecl draw_str, 25, 16, 0x0F, .s1

        cdecl itoa, -1, .s1, 16, 10, 0b0000      ; #3
        cdecl draw_str, 25, 17, 0x0F, .s1

        cdecl itoa, -1, .s1, 16, 10, 0b0001      ; #4 ok
        cdecl draw_str, 25, 18, 0x0F, .s1

        cdecl itoa, -1, .s1, 16, 16, 0b0010      ; #5 ok
        cdecl draw_str, 25, 19, 0x0F, .s1

        cdecl itoa, 12, .s1, 16, 2, 0b0000       ; #6 ok
        cdecl draw_str, 25, 20, 0x0F, .s1

        cdecl itoa, 9, .s1, 16, 8, 0b0000        ; #7 ok
        cdecl draw_str, 25, 21, 0x0F, .s1

        jmp $

.s0:    db " Hello, Kernel ! ", 0
.s1:    db "ZZZZZZZZZZZZZZZZ", 0


ALIGN 4, db 0
FONT:   dd 0                                ; フォントアドレス保持先   

%include "modules/protect/vga.s"
%include "modules/protect/draw_char.s"
%include "modules/protect/draw_font.s"
%include "modules/protect/draw_str.s"
%include "modules/protect/draw_color_bar.s"
%include "modules/protect/draw_pixel.s"
%include "modules/protect/itoa.s"

;********************************************************************************
; パディング(8kB)
;********************************************************************************
        times KERNEL_SIZE - ($-$$) db 0x00


