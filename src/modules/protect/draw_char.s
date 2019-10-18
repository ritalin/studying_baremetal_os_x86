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

;********************************************************************************
; void copy_vram_font(font, vram, plane, color)
;********************************************************************************
copy_vram_font:
;**** スタックフレームの構築 **** 
                            ;    +20 文字色
                            ;    +16 書き込み先プレーン
                            ;    +12 VRAMアドレス
                            ;     +8 フォントアドレス
                            ;     +4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp

;**** レジスタの保存 **** 
        push eax
        push ebx
        push ecx
        push esi
        push edi

;**** 処理の開始 ****
        mov esi, [ebp + 8]              ; フォント
        mov edi, [ebp + 12]             ; 出力先VRAMアドレス
        movzx eax, byte [ebp + 16]      ; プレーン
        movzx ebx, word [ebp + 20]      ; 文字色(上位：背景色 下位：前景色)

        test bh, al                     ; 背景色 & プレーン
        setz dh                         ; DH = ZF ? 0x01 : 0x00
        dec dh                          ; DH-- => 0x00 or 0xFF

        test bl, al                     ; 前景色 & プレーン
        setz dl                         ; DL = ZF ? 0x01 : 0x00
        dec dl                          ; DL-- => 0x00 or 0xFF

        ; ** 1ラインずつフォントの切り出し
        cld                             ; DF = 0
        mov ecx, 16
.LOOP:
        lodsb                           ; AL= *ESI++
        mov ah, al
        not ah

        ; ** 前景色と背景色を合成する
        and al, dl                      ; 前景色    

        test ebx, 0x0010                ; 透過色の判定
        jz .COLOR_COPY
.COLOR_TRANSP:
        and ah, [edi]                   ; 透過合成
        jmp .COLOR_END
.COLOR_COPY:  
        and ah, dh                      ; 背景色
.COLOR_END:  
        or al, ah                       ; 色の合成 

        mov [edi], al
        add edi, 80
        loop .LOOP
.END:

;**** レジスタの復帰 **** 
        pop edi
        pop esi
        pop ecx
        pop ebx
        pop eax

;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        ret