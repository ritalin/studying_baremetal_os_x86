;********************************************************************************
; void draw_fpu_bcd(col, row, bcd)
;********************************************************************************
draw_fpu_bcd:
                            ;    +16| bcdの先頭アドレス
                            ;    +12| 行 
                            ;     +8| 列 
                            ;     +4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp
;**** レジスタの保存 ****
        push eax
        push ebx
        push edx
        push esi
        push edi

;**** 処理の開始 ****
        mov esi, [ebp + 8]
        mov edi, [ebp + 12]
        mov edx, [ebp + 16]
        mov eax, [edx]
        mov ebx, eax

        and eax, 0x0F0F
        or eax, 0x3030

        shr ebx, 4
        and ebx, 0x0F0F
        or ebx, 0x3030

        mov [.s2], bh
        mov [.s3 + 0], ah
        mov [.s3 + 1], bl
        mov [.s3 + 2], al

        ; ** 符号の判定
.SIGN_BEGIN:
        mov eax, 7
        bt [edx + 9], eax                  ; [bcd + 9] & 0x80
        jc .SIGN_MINUS
.SIGN_PLUS:
        mov [.s1], byte '+'
        jmp .SIGN_END
.SIGN_MINUS:
        mov [.s1], byte '-'
.SIGN_END:

        cdecl draw_str, esi, edi, 0x07, .s1

;**** レジスタの復帰 **** 
        pop edi
        pop esi
        pop edx
        pop ebx
        pop eax

;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        ret

.s1:    db "-"
.s2:    db " ."
.s3:    db "    ", 0
