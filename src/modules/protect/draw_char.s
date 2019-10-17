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
        
        cdecl copy_vram_font, esi, edi, 0x02, ebx

;**** レジスタの復帰 **** 

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
        movzx ebx, word [ebp + 20]      ; 文字色

        ; ** 1ラインずつフォントの切り出し
        cld                             ; DF = 0
        mov ecx, 16
.LOOP:
        lodsb                           ; AL= *ESI++
        mov [edi], al
        add edi, 80
        loop .LOOP
.END

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