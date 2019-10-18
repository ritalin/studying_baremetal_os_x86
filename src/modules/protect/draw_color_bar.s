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

        mov ecx, 0
.LOOP:
        cmp ecx, 16                     ; 最大16本のカラーバーを出力
        je .END

        mov eax, ecx
        and eax, 0x01                   ; 0, 1を繰り返す    
        shl eax, 3                      ; 1本あたり8文字占有するため                 
        add eax, esi

        mov ebx, ecx
        shr ebx, 1                      ; 2回に1回incする
        add ebx, edi

        mov edx, ecx
        shl edx, 1                      ; 一つのカラーバーが2Byteで構成されているため
        mov edx, [.color_table + edx]   ; 色を選択

        cdecl draw_str, eax, ebx, edx, .format

        inc ecx
        jmp .LOOP
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
        dw 0x0300, 0x0B00
        dw 0x0400, 0x0C00
        dw 0x0500, 0x0D00
        dw 0x0600, 0x0E00
        dw 0x0700, 0x0F00
