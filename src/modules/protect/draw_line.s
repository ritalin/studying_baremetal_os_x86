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
        push eax
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

        cdecl itoa, esi, .s0b, 2, 10, 0b0011
        cdecl itoa, ebx, .s0d, 3, 10, 0b0010
        cdecl draw_char, 25, 16, 0x0F, 'X'
        cdecl draw_str, 25, 17, 0x0F, .s0

        cdecl itoa, edi, .s0b, 2, 10, 0b0011
        cdecl itoa, edx, .s0d, 3, 10, 0b0010
        cdecl draw_char, 25, 18, 0x0F, 'Y'
        cdecl draw_str, 25, 19, 0x0F, .s0
        
        ; ** 初期位置をローカル変数に保存
        mov [ebp - 4], eax
        mov [ebp - 8], ebx
        mov [ebp - 12], esi
        mov [ebp - 16], ecx
        mov [ebp - 20], edx
        mov [ebp - 24], edi 

        ; ** 基準軸・相対軸を決定する
.AXIS_BEGIN:
        cmp ebx, edx                ;
        jg .AXIS_X                  ; X方向長さ > Y方向長さ
        lea esi, [ebp - 16]         ; 基準軸: Y軸
        lea edi, [ebp - 4]          ; 相対軸: X軸

        mov [.s1b], byte 'Y'
        mov [.s1d], byte 'X'
        cdecl draw_str, 25, 20, 0x0F, .s1

        jmp .AXIS_END
.AXIS_X:
        lea esi, [ebp - 4]          ; 基準軸: X軸
        lea edi, [ebp - 16]         ; 相対軸: Y軸
        
        mov [.s1b], byte 'X'
        mov [.s1d], byte 'Y'
        cdecl draw_str, 25, 20, 0x0F, .s1
.AXIS_END:

        cdecl itoa, dword [esi], .s2b, 3, 10, 0b0000
        cdecl itoa, dword [edi], .s2d, 3, 10, 0b0000
        cdecl draw_str, 25, 21, 0x0F, .s2

;**** レジスタの復帰 **** 
        pop edi
        pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax

;**** スタックフレームの破棄 ****
        ; ** ローカル変数の破棄
        add esp, 24

        mov esp, ebp
        pop ebp
        ret

.s0:    
.s0a:   db "Dir="
.s0b:   db "  ", " "
.s0c:   db "Len="
.s0d    db "   ", 0

.s1: 
.s1a:   db "Abs="
.s1b:   db " ", " "
.s1c:   db "Rel="
.s1d:   db " ", 0 

.s2:
.s2a:   db "ESI="
.s2b:   db "   ", " "
.s2c:   db "EDI="
.s2d:   db "   ", 0
