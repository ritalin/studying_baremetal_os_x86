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
        cdecl select_vga_read_plane, 0x01
        cdecl select_vga_write_plane, 0x02

        mov edi, 4                              ; Y座標からVRAMの先頭アドレスを計算する
        shl edi, 4      
        lea edi, [edi * 4 + edi + 0xA_0000]     ; 80Byte * Y座標を移動する

        mov ebx, 8
        mov ecx, ebx                            ; 後でビット位置を割り出すためX座標を退避
        shr ebx, 3                              ; VGAは8bit単位で管理されるため、8で割る
        add edi, ebx                            ; 座標位置に相当するVRAMアドレス

        and ecx, 0x07                           ; 8で割ったあまりを求める
        mov ebx, 0b_1000_0000
        shr ebx, cl                             ; ビットマスクを作成する

        cdecl copy_vram_dot, ebx, edi, 0x02, 0x02

        jmp $

.s0:    db " Hello, Kernel ! ", 0

ALIGN 4, db 0
FONT:   dd 0                                ; フォントアドレス保持先   

%include "modules/protect/vga.s"
%include "modules/protect/draw_char.s"
%include "modules/protect/draw_font.s"
%include "modules/protect/draw_str.s"
%include "modules/protect/draw_color_bar.s"

;********************************************************************************
; パディング(8kB)
;********************************************************************************
        times KERNEL_SIZE - ($-$$) db 0x00


