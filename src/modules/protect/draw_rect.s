;********************************************************************************
; void draw_rect(x, y, width, height, color)
;********************************************************************************
draw_rect:
;**** スタックフレームの構築 **** 
                            ;    +24| 前景色 
                            ;    +20| 高さ 
                            ;    +16| 幅 
                            ;    +12| 左上Y座標 
                            ;     +8| 左上X座標
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
        mov eax, [ebp + 8]                          ; 左辺
        mov ecx, eax
        add ecx, [ebp + 16]                         ; 右辺
        mov ebx, [ebp + 12]                         ; 上辺
        mov edx, ebx
        add edx, [ebp + 20]                         ; 底辺

        mov esi, [ebp + 24]                         ; 前景色

        cdecl draw_line, eax, ebx, ecx, ebx, esi    ; 上線
        cdecl draw_line, ecx, ebx, ecx, edx, esi    ; 右線
        cdecl draw_line, eax, edx, ecx, edx, esi    ; 下線
        cdecl draw_line, eax, ebx, eax, edx, esi    ; 左線

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