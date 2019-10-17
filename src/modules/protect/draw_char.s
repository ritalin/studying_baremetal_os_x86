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