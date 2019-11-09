%define USE_SYSTEM_CALL
%define USE_TEST_AND_SET

%include "include/define.s"
%include "include/macro.s"

        ORG KERNEL_LOAD

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

        ; ** GDTのTSSのアドレスを設定する
        set_desc GDT.tss_00, TSS_00
        set_desc GDT.tss_01, TSS_01
        set_desc GDT.tss_02, TSS_02
        set_desc GDT.tss_03, TSS_03
        set_desc GDT.tss_04, TSS_04

        ; ** GDTにコールゲートアドレスを設定する **
        set_call_gate_desc GDT.call_gate, call_gate

        ; ** GDTにLDTのアドレスを設定する **
        set_desc GDT.ldt, LDT, word LDT_LIMIT   ; LDTの上限数は64k (LDTRが16bitのため)

        ; ** GDTRをリロードする **
        lgdt [GDTR]

        ; ** カーネルタスクに載せる **
        mov esp, SP_TASK_00
        mov ax, SS_TASK_00
        ltr ax

        ; ** IDTRを初期化する **
        cdecl init_int
        ; ** PICを初期化する **
        cdecl init_pic
        ; ** ページテーブルを初期化する ** 
        cdecl init_page_table

        cdecl enable_rtc_int, 0x10              ; 更新サイクル終了割り込み(UIE)を許可する
        cdecl enable_int_timer0

        set_vect 0x00, int_zero_div
        set_vect 0x07, int_nm                           ; デバイス使用不可の割り込みを登録
        set_vect 0x0E, int_pf                           ; ページフォルト割り込みを登録
        set_vect 0x20, int_timer
        set_vect 0x21, int_keyboard
        set_vect 0x28, int_rtc
        set_vect 0x81, trap_gate_81, word 0xEF00        ; トラップゲート(81)を登録する
        set_vect 0x82, trap_gate_82, word 0xEF00        ; トラップゲート(82)を登録する

        ; ** IMR(割り込みマスクレジスタ)の設定
        outp 0x21, 0b_1111_1000                 ; スレーブPICを有効にする
        outp 0xA1, 0b_1111_1110                 ; RTCの割り込みを有効にする

        ; ** ページテーブルを登録する **
        mov eax, CR3_BASE
        mov cr3, eax
        ; ** ページングを有効化する **
        mov eax, cr0
        or eax, (1 << 31)                       ; CR0 |= PG
        mov cr0, eax
        jmp $ + 2                               ; 実行パイプラインの破棄

        sti

        ; ** フォントをを印字
        cdecl draw_font, 63, 13

        ; ** 文字列を印字する
        cdecl draw_str, 25, 14, 0x010F, .s0

        ; ** カラーバーを出力する
        cdecl draw_color_bar, 63, 4

.EVENT_LOOP:
.KEY_BUFF_BEGIN:
        ; ** キー入力を一つ消費する
        cdecl read_ring_buff, KEY_BUFF, .key
        cmp eax, 0
        je .KEY_BUF_END

        ; ** キー履歴を表示する
        cdecl draw_key, 2, 29, KEY_BUFF        
.KEY_BUF_END:
        
        ; ** 回転バーを表示する
        cdecl draw_rotation_bar, 0, 29

        hlt
        jmp .EVENT_LOOP

.s0:    db " Hello, Kernel! ", 0
.key:   dd 0                                    ; 取得したキーの保存先

ALIGN 4, db 0
FONT:   dd 0                                    ; フォントアドレス保持先   
RTC_TIME:
        dd 0                                    ; 時刻の保存先

;********************************************************************************
; タスク
;********************************************************************************
%include "descriptor.s"
%include "tasks/task_helper.s"
%include "tasks/task_01.s"
%include "tasks/task_02.s"
%include "tasks/task_03.s"
%include "tasks/task_04.s"

;********************************************************************************
; 割り込み
;********************************************************************************
%include "modules/int_timer.s"
%include "modules/int_pf.s"
%include "modules/paging.s"

;********************************************************************************
; モジュール
;********************************************************************************
%include "modules/protect/vga.s"
%include "modules/protect/draw_char.s"
%include "modules/protect/draw_font.s"
%include "modules/protect/draw_str.s"

%include "modules/protect/draw_pixel.s"
%include "modules/protect/draw_line.s"
%include "modules/protect/draw_rect.s"

%include "modules/protect/draw_color_bar.s"
%include "modules/protect/draw_time.s"
%include "modules/protect/itoa.s"
%include "modules/protect/rtc.s"
%include "modules/protect/int_rtc.s"
%include "modules/protect/pic.s"
%include "modules/protect/interrupt.s"
%include "modules/protect/ring_buff.s"
%include "modules/protect/int_keyboard.s"
%include "modules/protect/draw_rotation_bar.s"
%include "modules/protect/test_and_set.s"

%include "modules/protect/call_gate.s"
%include "modules/protect/trap_gate.s"

%include "modules/protect/int_nm.s"
%include "modules/protect/wait_tick.s"

%include "modules/protect/memcpy.s"

;********************************************************************************
; パディング(8kB)
;********************************************************************************
        times KERNEL_SIZE - ($-$$) db 0x00


