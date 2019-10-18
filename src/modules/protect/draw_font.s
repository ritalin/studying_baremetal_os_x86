;********************************************************************************
; void draw_font(col, row)
;********************************************************************************
draw_font:
;**** スタックフレームの構築 **** 
                            ;    +12| 行                          
                            ;     +8| 列
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
        mov esi, [ebp + 8]      ; 列
        mov edi, [ebp + 12]     ; 行

        mov ecx, 0
.LOOP:
        cmp ecx, 256
        jae .END

        mov eax, ecx
        and eax, 0x0F           ; 
        add eax, esi

        mov ebx, ecx
        shr ebx, 4
        add ebx, edi

        cdecl draw_char, eax, ebx, 0x07, ecx

        inc ecx
        jmp .LOOP
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