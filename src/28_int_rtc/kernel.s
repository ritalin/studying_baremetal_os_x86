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
        mov esi, BOOT_LOAD + SECT_SIZE          ; ESI = 0x7c00 + 512
        movzx eax, word [esi + font.seg]        ; フォントセグメント
        movzx ebx, word [esi + font.off]        ; フォントオフセットアドレス
        shl eax, 4                              ; リアルモードセグメントアドレスのため
        add eax, ebx                            ; 実アドレスを計算
        mov [FONT], eax

        ; ** IDTRを初期化する
        cdecl init_int
        ; ** PICを初期化する
        cdecl init_pic

        cdecl enable_rtc_int, 0x10              ; 更新サイクル終了割り込み(UIE)を許可する

        set_vect 0x00, int_zero_div
        set_vect 0x28, int_rtc
        
        ; ** IMR(割り込みマスクレジスタ)の設定
        outp 0x21, 0b_1111_1011                 ; スレーブPICを有効にする
        outp 0xA1, 0b_1111_1110                 ; RTCの割り込みを有効にする

        sti

        ; ** フォントをを印字
        cdecl draw_font, 63, 13

        ; ** 文字列を印字する
        cdecl draw_str, 25, 14, 0x010F, .s0

        ; ** カラーバーを出力する
        cdecl draw_color_bar, 63, 4

.UPDATE_RTC_TIME:
        ; ** 時刻を表示する
        mov eax, [RTC_TIME]
        cdecl draw_time, 72, 0, 0x0700, eax

        hlt
        jmp .UPDATE_RTC_TIME

.s0:    db " Hello, Kernel! ", 0

ALIGN 4, db 0
FONT:   dd 0                                    ; フォントアドレス保持先   
RTC_TIME:
        dd 0                                    ; 時刻の保存先

%include "modules/protect/vga.s"
%include "modules/protect/draw_char.s"
%include "modules/protect/draw_font.s"
%include "modules/protect/draw_str.s"
%include "modules/protect/draw_color_bar.s"
%include "modules/protect/draw_time.s"
%include "modules/protect/itoa.s"
%include "modules/protect/rtc.s"
%include "modules/protect/int_rtc.s"
%include "modules/protect/pic.s"

%include "modules/interrupt.s"

;********************************************************************************
; パディング(8kB)
;********************************************************************************
        times KERNEL_SIZE - ($-$$) db 0x00


