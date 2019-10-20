;********************************************************************************
; void draw_rotation_bar(col, row)
;********************************************************************************
draw_rotation_bar:
;**** スタックフレームの構築 **** 
                            ;    +12| 表示行
                            ;     +8| 表示列
                            ;     +4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp

;**** レジスタの保存 **** 
        push eax
        push edx
        push edi

;**** 処理の開始 ****
        mov edx, [ebp + 8]
        mov edi, [ebp + 12]

        mov eax, [TIMER_COUNT]
        shr eax, 4
        cmp eax, [.index]
        je .END

        and eax, 0x03
        mov [.index], eax           ; 前回値を保存
        mov al, [.table + eax]

        cdecl draw_char, edx, edi, 0x000F, eax
.END:

;**** レジスタの復帰 **** 
        pop edi
        pop edx
        pop eax

;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        ret

ALIGN 4, db 0
.index: dd 0
.table: db "/|-\"
