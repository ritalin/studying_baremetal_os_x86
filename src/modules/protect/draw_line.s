;********************************************************************************
; void draw_line(x0, y0, x1, y1, color)
;********************************************************************************
draw_line:
;**** スタックフレームの構築 **** 
                                    ;    +24| 前景色 
                                    ;    +20| 終点Y
                                    ;    +16| 終点X
                                    ;    +12| 始点Y
                                    ;     +8| 始点X
                                    ;     +4| EIP (caller)
        push ebp                    ; EBP  0| EBP (old)
        mov ebp, esp                ; ------+--------------
        push dword 0                ;     -4| 現在のX座標
        push dword 0                ;     -8| X軸方向の長さ
        push dword 0                ;    -12| X軸の描画方向(+1: 正, -1: 負)      
        push dword 0                ;    -16| 現在のY座標
        push dword 0                ;    -20| Y軸方向の長さ
        push dword 0                ;    -24| Y軸の描画方向(+1: 正, -1: 負)      

;**** レジスタの保存 **** 
        push ebx
        push ecx
        push edx
        push esi
        push edi

;**** 処理の開始 ****
        ; ** X軸の進行方向の決定
.DIR_X_BEGIN:
        mov eax, [ebp + 8]          ; x0
        mov ebx, [ebp + 16]         ; x1
        sub ebx, eax                ; x方向の長さ
        jge .GE_X1
        neg ebx                     ; x軸方向の長さの絶対値を取る
        mov esi, -1                 ; x0 > x1の場合
        jmp .DIR_X_END
.GE_X1:
        mov esi, 1                  ; x0 <= x1 の場合
.DIR_X_END:
        
        ; ** Y軸の進行方向の決定
.DIR_Y_BEGIN:
        mov ecx, [ebp + 12]         ; y0
        mov edx, [ebp + 20]         ; y1
        sub edx, ecx                ; y軸方向の長さ
        jge .GE_Y1
        neg edx                     ; y軸方向の長さの絶対値を取る
        mov edi, -1                 ; y0 > y1の場合
        jmp .DIR_Y_END
.GE_Y1:
        mov edi, 1                  ; y0 <= y1の場合
.DIR_Y_END:

        cdecl itoa, esi, .s0a, 2, 10, 0b0011
        cdecl itoa, ebx, .s0c, 3, 10, 0b0010
        cdecl draw_char, 25, 16, 0x0F, 'X'
        cdecl draw_str, 25, 17, 0x0F, .s0

        cdecl itoa, edi, .s0a, 2, 10, 0b0011
        cdecl itoa, edx, .s0c, 3, 10, 0b0010
        cdecl draw_char, 25, 18, 0x0F, 'Y'
        cdecl draw_str, 25, 19, 0x0F, .s0
        
        ; ** 初期位置をローカル変数に保存
        mov [ebp - 4], eax
        mov [ebp - 8], ebx
        mov [ebp - 12], esi
        mov [ebp - 16], ecx
        mov [ebp - 20], edx
        mov [ebp - 24], edi 

;**** レジスタの復帰 **** 
        pop edi
        pop esi
        pop edx
        pop ecx
        pop ebx

;**** スタックフレームの破棄 ****
        ; ** ローカル変数の破棄
        add esp, 24

        mov esp, ebp
        pop ebp
        ret

.s0:    db "Dir="
.s0a:   db "  ", " "
.s0b:   db "Len="
.s0c    db "   ", 0
