%include "include/define.s"
%include "include/macro.s"

        ORG KERNEL_LOAD

LINE_ORIGIN_X equ 8
LINR_ORIGIN_Y equ 16


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

        ; ** 直線を描画する
        cdecl draw_line, LINE_ORIGIN_X+100, LINR_ORIGIN_Y+100, LINE_ORIGIN_X+0, LINR_ORIGIN_Y+0, 0x0F
        cdecl draw_line, LINE_ORIGIN_X+100, LINR_ORIGIN_Y+100, LINE_ORIGIN_X+200, LINR_ORIGIN_Y+0, 0x0F
        cdecl draw_line, LINE_ORIGIN_X+100, LINR_ORIGIN_Y+100, LINE_ORIGIN_X+200, LINR_ORIGIN_Y+200, 0x0F
        cdecl draw_line, LINE_ORIGIN_X+100, LINR_ORIGIN_Y+100, LINE_ORIGIN_X+0, LINR_ORIGIN_Y+200, 0x0F

        cdecl draw_line, LINE_ORIGIN_X+100, LINR_ORIGIN_Y+100, LINE_ORIGIN_X+50, LINR_ORIGIN_Y+0, 0x02
        cdecl draw_line, LINE_ORIGIN_X+100, LINR_ORIGIN_Y+100, LINE_ORIGIN_X+150, LINR_ORIGIN_Y+0, 0x03
        cdecl draw_line, LINE_ORIGIN_X+100, LINR_ORIGIN_Y+100, LINE_ORIGIN_X+150, LINR_ORIGIN_Y+200, 0x04
        cdecl draw_line, LINE_ORIGIN_X+100, LINR_ORIGIN_Y+100, LINE_ORIGIN_X+50, LINR_ORIGIN_Y+200, 0x05

        cdecl draw_line, LINE_ORIGIN_X+100, LINR_ORIGIN_Y+100, LINE_ORIGIN_X+0, LINR_ORIGIN_Y+50, 0x02
        cdecl draw_line, LINE_ORIGIN_X+100, LINR_ORIGIN_Y+100, LINE_ORIGIN_X+200, LINR_ORIGIN_Y+50, 0x03
        cdecl draw_line, LINE_ORIGIN_X+100, LINR_ORIGIN_Y+100, LINE_ORIGIN_X+200, LINR_ORIGIN_Y+150, 0x04
        cdecl draw_line, LINE_ORIGIN_X+100, LINR_ORIGIN_Y+100, LINE_ORIGIN_X+0, LINR_ORIGIN_Y+150, 0x05

        cdecl draw_line, LINE_ORIGIN_X+100, LINR_ORIGIN_Y+100, LINE_ORIGIN_X+100, LINR_ORIGIN_Y+0, 0x0F
        cdecl draw_line, LINE_ORIGIN_X+100, LINR_ORIGIN_Y+100, LINE_ORIGIN_X+200, LINR_ORIGIN_Y+100, 0x0F
        cdecl draw_line, LINE_ORIGIN_X+100, LINR_ORIGIN_Y+100, LINE_ORIGIN_X+100, LINR_ORIGIN_Y+200, 0x0F
        cdecl draw_line, LINE_ORIGIN_X+100, LINR_ORIGIN_Y+100, LINE_ORIGIN_X+0, LINR_ORIGIN_Y+100, 0x0F
        
        ; 矩形を描画する
        cdecl draw_rect, 100, 200, 100, 100, 0x03
        cdecl draw_rect, 150, 150, 250, 100, 0x05
        cdecl draw_rect, 300, 100, 50, 300, 0x06

.UPDATE_TIME:
        ; ** 時刻の表示
        cdecl get_rtc_time, RTC_TIME
        cdecl draw_time, 72, 0, 0x0700, dword [RTC_TIME]

        jmp .UPDATE_TIME

.s0:    db " Hello, Kernel ! ", 0

ALIGN 4, db 0
FONT:   dd 0                                    ; フォントアドレス保持先   
RTC_TIME:
        dd 0                                    ; 時刻の保存先

%include "modules/protect/vga.s"
%include "modules/protect/draw_char.s"
%include "modules/protect/draw_font.s"
%include "modules/protect/draw_str.s"
%include "modules/protect/draw_color_bar.s"
%include "modules/protect/draw_pixel.s"
%include "modules/protect/draw_line.s"
%include "modules/protect/draw_rect.s"
%include "modules/protect/itoa.s"
%include "modules/protect/rtc.s"
%include "modules/protect/draw_time.s"

;********************************************************************************
; パディング(8kB)
;********************************************************************************
        times KERNEL_SIZE - ($-$$) db 0x00


