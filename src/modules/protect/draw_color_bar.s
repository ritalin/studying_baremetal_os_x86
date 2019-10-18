;********************************************************************************
; void draw_color_bar(col, row)
;********************************************************************************
draw_color_bar:
;**** スタックフレームの構築 **** 
                            ;    +12| 行
                            ;     +8| 列
                            ;     +4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp

;**** レジスタの保存 **** 
        push ebx
        push ecx
        push edx
        push esi
        push edi

;**** 処理の開始 ****
        mov esi, [ebp + 8]              ; 列
        mov edi, [ebp + 12]             ; 行

        mov ecx, 2

        mov eax, ecx
        add eax, esi

        mov ebx, ecx
        add ebx, edi

        mov edx, ecx
        shl edx, 1                      ; 一つのカラーバーが2Byteで構成されているため
        mov edx, [.color_table + edx]   ; 色を選択

        cdecl draw_str, eax, ebx, edx, .format

        inc ecx
.END:

;**** レジスタの復帰 **** 
        pop edi
        pop esi
        pop edx
        pop ecx
        pop ebx

;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        ret

.format:
        db '        ', 0        ; 8文字分のスペース
.color_table:    
        dw 0x0000, 0x0800
        dw 0x0100, 0x0900
        dw 0x0200, 0x0A00
