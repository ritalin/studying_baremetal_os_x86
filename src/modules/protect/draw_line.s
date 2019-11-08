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
        push dword 0                ;     -4| 基準軸の積算値
        push dword 0                ;     -8| 現在のX座標
        push dword 0                ;    -12| X軸方向の長さ
        push dword 0                ;    -16| X軸の描画方向(+1: 正, -1: 負)      
        push dword 0                ;    -20| 現在のY座標
        push dword 0                ;    -24| Y軸方向の長さ
        push dword 0                ;    -28| Y軸の描画方向(+1: 正, -1: 負)      

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

        ; ** 初期位置をローカル変数に保存
        mov [ebp -  8], eax         ; X
        mov [ebp - 12], ebx
        mov [ebp - 16], esi
        mov [ebp - 20], ecx         ; Y
        mov [ebp - 24], edx
        mov [ebp - 28], edi 

        ; ** 基準軸・相対軸を決定する
.AXIS_BEGIN:
        cmp ebx, edx                ;
        jg .AXIS_X                  ; X方向長さ > Y方向長さ
        lea esi, [ebp - 20]         ; 基準軸: Y軸
        lea edi, [ebp - 8]          ; 相対軸: X軸

        jmp .AXIS_END
.AXIS_X:
        lea esi, [ebp - 8]          ; 基準軸: X軸
        lea edi, [ebp - 20]         ; 相対軸: Y軸
.AXIS_END:

        ; 基準軸の繰り返し回数
        mov ecx, [esi - 4]          ; 基準軸のローカル変数の一つ下に長さのローカル変数
        cmp ecx, 0
        jnz .LINE_BEGIN
        mov ecx, 1                  ; 少なくとも1ドットは打つ
.LINE_BEGIN:
        cmp ecx, 0
        je .LINE_END

%ifdef USE_SYSTEM_CALL
        mov eax, ecx
        
        mov ebx, dword [ebp + 24]
        mov ecx, dword [ebp - 8]
        mov edx, dword [ebp - 20]
        int 0x82                    ; トラップゲートを介して1px描画する

        mov ecx, eax
%else
        cdecl draw_pixel, dword [ebp - 8], dword [ebp - 20], dword [ebp + 24]
%endif

        mov eax, [esi - 8]          ; 基準軸の更新サイズ
        add [esi - 0], eax          ; 基準軸の位置を更新

.SUM_REL_BEGIN:
        mov eax, [ebp - 4]          ; 相対軸の積算値(sum)
        add eax, [edi - 4]          ; 相対軸の積算値を更新(sum += 相対軸の長さ)

        mov ebx, [esi - 4]          ; 基準軸の長さ
        cmp eax, ebx
        jl .SUM_REL_END             ; 相対軸 < 基準軸
        sub eax, ebx                ; 超過分を計算

        mov ebx, [edi - 8]
        add [edi - 0], ebx          ; 相対軸方向に1ドット更新
.SUM_REL_END:
        mov [ebp - 4], eax          ; 相対軸の積算値に超過分を保存

        loop .LINE_BEGIN
.LINE_END:

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
