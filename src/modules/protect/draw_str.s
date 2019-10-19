;********************************************************************************
; void draw_str(col, row, color, str)
;********************************************************************************
draw_str:
;**** スタックフレームの構築 **** 
                            ;    +20| 文字列へのポインタ
                            ;    +16| 前景色
                            ;    +12| 行
                            ;     +8| 列
                            ;     +4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp

;**** レジスタの保存 **** 
        push eax
        push ebx
        push ecx
        push edx
        push esi

;**** 処理の開始 ****
        mov ecx, [ebp + 8]              ; 列
        mov edx, [ebp + 12]             ; 行
        movzx ebx, word [ebp + 16]      ; 表示色
        mov esi, [ebp + 20]             ; 文字列

        cld                             ; DF = 0
.LOOP:
        lodsb                           ; AL = *ESI++
        cmp al, 0
        je .END

        cdecl draw_char, ecx, edx, ebx, eax

        inc ecx
        cmp ecx, 80
        jl .BLOCK_END
        mov ecx, 0

        inc edx
        cmp edx, 30
        jl .BLOCK_END
        mov edx, 0
.BLOCK_END:
        jmp .LOOP
.END:

;**** レジスタの復帰 **** 
        pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax

;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        ret