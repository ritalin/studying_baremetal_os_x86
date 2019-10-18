;********************************************************************************
; void draw_char(col, row, color, ch)
;********************************************************************************
draw_char:
;**** スタックフレームの構築 **** 
                            ;    +20| 出力するする文字
                            ;    +16| 文字色
                            ;    +12| 行
                            ;     +8| 列
                            ;     +4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp

;**** レジスタの保存 **** 
        push ebx
        push esi
        push edi

;**** 処理の開始 ****
        ; ** コピー元フォントアドレス
        movzx esi, byte [ebp + 20]
        shl esi, 4
        add esi, [FONT]                         ; ESI = フォントアドレス

        ; ** VRAMアドレスの決定
        mov edi, [ebp + 12]
        shl edi, 8
        lea edi, [edi * 4 + edi + 0xA_0000]     ; 行
        add edi, [ebp + 8]                      ; 列の反映

        movzx ebx, word [ebp + 16]

        ; 輝度の出力
        cdecl select_vga_read_plane, 0x03           ; [____ I___]
        cdecl select_vga_write_plane, 0x08          ; [____ I___]
        cdecl copy_vram_font, esi, edi, 0x08, ebx

        ; 赤の出力
        cdecl select_vga_read_plane, 0x02           ; [____ _R__]
        cdecl select_vga_write_plane, 0x04          ; [____ _R__]
        cdecl copy_vram_font, esi, edi, 0x04, ebx

        ; 緑の出力
        cdecl select_vga_read_plane, 0x01           ; [____ __G_]
        cdecl select_vga_write_plane, 0x02          ; [____ __G_]
        cdecl copy_vram_font, esi, edi, 0x02, ebx

        ; 青の出力
        cdecl select_vga_read_plane, 0x00           ; [____ __G_]
        cdecl select_vga_write_plane, 0x01          ; [____ __G_]
        cdecl copy_vram_font, esi, edi, 0x01, ebx

;**** レジスタの復帰 **** 
        pop edi
        pop esi
        pop ebx

;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        ret
