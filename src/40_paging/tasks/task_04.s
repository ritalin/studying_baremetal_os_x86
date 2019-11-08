;********************************************************************************
; void task_04()
;********************************************************************************
task_04:
;**** スタックフレームの構築 **** 
        mov ebp, esp        ; EBP  0| EBP (old)
        push dword 0        ;     -4| 原点(x)   
        push dword 0        ;     -8| 原点(y)     
        push dword 0        ;    -12| 座標(x)
        push dword 0        ;    -16| 座標(y)   
        push dword 60        ;    -20| 角度    
;**** レジスタの保存 **** 

;**** 処理の開始 ****
        mov esi, ROSE_PARAM

        ; ** タイトル表示 **
        mov eax, [esi + rose.x0] 
        mov ebx, [esi + rose.y0]

        shr eax, 3                          ; x0 = x0 / 8
        shr ebx, 4                          ; y0 = y0 / 16
        dec ebx                             ; --y0

        mov ecx, [esi + rose.color_font]
        lea edx, [esi + rose.title]

        cdecl draw_str, eax, ebx, ecx, edx

        ; ** 原点座標の計算 **
        mov eax, [esi + rose.x0]            ; 左上(x)
        mov ebx, [esi + rose.width]         ; 枠の幅
        shr ebx, 1                          ; ebx /= 2
        add ebx, eax                
        mov [ebp - 4], ebx                  ; 原点(x)を保存

        mov eax, [esi + rose.y0]            ; 左上(y)
        mov ebx, [esi + rose.height]        ; 枠の高さ
        shr ebx, 1                          ; ebx /= 2
        add ebx, eax
        mov [ebp - 8], ebx                  ; 原点(y)を保存

        ; ** 座標軸を描画する **

        mov eax, [esi + rose.x0]            ; x0
        mov ebx, [ebp - 8]                  ; 原点(y)
        mov ecx, [esi + rose.width]         ; 枠の幅
        add ecx, eax                        ; x1

        cdecl draw_line, eax, ebx, ecx, ebx, dword [esi + rose.color_axis_x]

        mov eax, [esi + rose.y0]            ; y0
        mov ebx, [ebp - 4]                  ; 原点(x)
        mov ecx, [esi + rose.height]        ; 枠の高さ
        add ecx, eax                        ; y1

        cdecl draw_line, ebx, eax, ebx, ecx, dword [esi + rose.color_axis_y]

        ; ** 外枠を描画する **

        mov eax, [esi + rose.x0]            ; x0
        mov ebx, [esi + rose.y0]            ; y0
        mov ecx, [esi + rose.width]         ; 枠の幅
        mov edx, [esi + rose.height]        ; 枠の高さ

        cdecl draw_rect, eax, ebx, ecx, edx, dword [esi + rose.color_frame]

        ; ** 振幅をx軸の約95%に調整する

        mov eax, [esi + rose.width]         ; 枠の幅
        shr eax, 1                          ; eax /= 2
        mov ebx, eax
        shr ebx, 4                          ; ebx /= 16
        sub eax, ebx                        ; 15/16 = 0.9375

;        cdecl itoa, eax, .a1, 8, 10, 0x0011
;        cdecl draw_str, 2, 5, 0x0003, .a0

        ; ** バラ曲線を初期化する

        cdecl prepare_fpu_rose, eax, dword [esi + rose.n], dword [esi + rose.d]

;        cdecl itoa, dword [ebp - 4], .ox1, 8, 10, 0x0011
;        cdecl draw_str, 2, 3, 0x0003, .ox0
;        cdecl itoa, dword [ebp - 8], .oy1, 8, 10, 0x0011
;        cdecl draw_str, 2, 4, 0x0003, .oy0
;
;        cdecl itoa, dword [ebp - 12], .sx1, 8, 10, 0x0011
;        cdecl draw_str, 2, 6, 0x0003, .sx0
;        cdecl itoa, dword [ebp - 16], .sy1, 8, 10, 0x0011
;        cdecl draw_str, 2, 7, 0x0003, .sy0
;        cdecl itoa, dword [ebp - 20], .th1, 8, 10, 0x0011
;        cdecl draw_str, 2, 8, 0x0003, .th0
;        cdecl wait_tick, 10

.LOOP_FPU:
        ; ** 座標を計算する **

        lea ebx, [ebp - 12]                 ; 座標(x)のポインタ
        lea ecx, [ebp - 16]                 ; 座標(y)のポインタ
        mov eax, [ebp - 20]                 ; 角度

        cdecl update_fpu_rose, ebx, ecx, eax

        ; ** 角度を更新する **
        mov edx, 0
        inc eax
        mov ebx, 360 * 100                  ; ebx = 36000
        div ebx                             ; edx:eax % ebx
        mov [ebp - 20], edx

        ; ** 座標の点に描画 **

        mov ecx, [ebp - 12]
        add ecx, [ebp - 4]                  ; 座標(x)
        mov edx, [ebp - 16]
        add edx, [ebp - 8]                  ; 座標(y)

;        cdecl itoa, ecx, .sx1, 8, 10, 0x0011 
;        cdecl draw_str, 2, 6, 0x0003, .sx0
;        cdecl itoa, edx, .sy1, 8, 10, 0x0011 
;        cdecl draw_str, 2, 7, 0x0003, .sy0
;        cdecl itoa, dword [ebp - 20], .th1, 8, 10, 0x0011 
;        cdecl draw_str, 2, 8, 0x0003, .th0
;        cdecl wait_tick, 10

        mov ebx, [esi + rose.color_curve_f] ; カーブ表示色

        int 0x82

        cdecl wait_tick, 1

        mov ebx, [esi + rose.color_curve_b] ; カーブ表示色

        int 0x82

        jmp .LOOP_FPU

;**** レジスタの復帰 ****

;**** スタックフレームの破棄 ****

.sx0:   db " P(x):"
.sx1:   db "        ", 0
.sy0:   db " P(y):"
.sy1:   db "        ", 0

.ox0:   db " O(x):"
.ox1:   db "        ", 0
.oy0:   db " O(y):"
.oy1:   db "        ", 0

.th0:   db "Theta:"
.th1:   db "        ", 0

.a0:    db "    A:"
.a1:    db "        ", 0

ALIGN 4, db 0
ROSE_PARAM:
    istruc rose 
        at rose.x0,             dd 16           ; 左上(x)
        at rose.y0,             dd 32           ; 左上(y)
        at rose.width,          dd 400          ; 枠の幅
        at rose.height,         dd 400          ; 枠の高さ
        at rose.n,              dd 2            
        at rose.d,              dd 1
        at rose.color_font,     dd 0x030F       ; 文字色    
        at rose.color_axis_x,   dd 0x0007       ; X軸の表示色
        at rose.color_axis_y,   dd 0x0007       ; Y軸の表示色
        at rose.color_frame,    dd 0x000F       ; 枠線の色
        at rose.color_curve_f,  dd 0x000F       ; カーブ表示色
        at rose.color_curve_b,  dd 0x0003       ; カーブ消去色
        at rose.title,          db "Task-4", 0  ; キャプション
    iend

;********************************************************************************
; void prepare_fpu_rose(A, n, d)
;********************************************************************************
prepare_fpu_rose:
;**** スタックフレームの構築 **** 
                            ;    +16| d  
                            ;    +12| n
                            ;     +8| A (振幅)
                            ;     +4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp        ; ------+--------------
        push dword 180      ;     -4| 

;**** レジスタの保存 **** 
         
;**** 処理の開始 ****

                                    ; ------------+---------+---------|---------|---------|---------|
                                    ;         ST0 |      ST1|      ST2|      ST3|      ST4|      ST5|
                                    ; ------------+---------+---------|---------|---------|---------|
        fldpi                       ;          pi |*********|*********|*********|*********|*********|
        fidiv dword [ebp - 4]       ;      pi/180 |*********|*********|*********|*********|*********|
        fild dword [ebp + 12]       ;           n |  pi/180 |*********|*********|*********|*********|
        fidiv dword [ebp + 16]      ;         n/d |  pi/180 |*********|*********|*********|*********|
        fild dword [ebp + 8]        ;           A |     n/d |  pi/180 |*********|*********|*********|
                                    ; ------------+---------+---------|---------|---------|---------|       
                                    ;           A |       k |       r |         |         |         |
                                    ; ------------+---------+---------|---------|---------|---------|

;**** レジスタの復帰 ****
        
;**** スタックフレームの破棄 ****
        add esp, 4
        mov esp, ebp
        pop ebp
        ret

;********************************************************************************
; void update_fpu_rose(&px, &py, t)
;********************************************************************************
update_fpu_rose:
;**** スタックフレームの構築 **** 
                            ;    +16| t  
                            ;    +12| &py
                            ;     +8| &px
                            ;     +4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp        ; ------+--------------

;**** レジスタの保存 **** 
        push eax
        push ebx
         
;**** 処理の開始 ****
        mov eax, [ebp + 8]
        mov ebx, [ebp + 12]

                                    ; --------------+---------+---------|---------|---------|---------|
                                    ;           ST0 |      ST1|      ST2|      ST3|      ST4|      ST5|
                                    ; --------------+---------+---------|---------|---------|---------|
        fild dword [ebp + 16]       ;             t |       A |       k |       r |*********|*********|
        fmul st0, st3               ;           t*r |       A |       k |       r |*********|*********|
        fld st0                     ;           t*r |     t*r |       A |       k |       r |*********|
                                    ; --------------+---------+---------|---------|---------|---------|       
                                    ;            th |      th |       A |       k |       r |         |       
                                    ; --------------+---------+---------|---------|---------|---------|
        fsincos                     ;       cos(th) | sin(th) |      th |       A |       k |       r |
        fxch st2                    ;            th | sin(th) | cos(th) |       A |       k |       r | 
        fmul st0, st4               ;          k*th | sin(th) | cos(th) |       A |       k |       r |
        fsin                        ;     sin(k*th) | sin(th) | cos(th) |       A |       k |       r |
        fmul st0, st3               ; Z=A*sin(k*th) | sin(th) | cos(th) |       A |       k |       r |
                                    ; --------------+---------+---------|---------|---------|---------|
        fxch st2                    ;       cos(th) | sin(th) |       Z |       A |       k |       r |
        fmul st0, st2               ;             x | sin(th) |       Z |       A |       k |       r |
        fistp dword [eax]           ;       sin(th) |       Z |       A |       k |       r |*********|
                                    ; --------------+---------+---------|---------|---------|---------|
        fmulp st1, st0              ;             y |       A |       k |       r |*********|*********|
        fchs                        ;            -y |       A |       k |       r |*********|*********|
        fistp dword [ebx]           ;             A |       k |       r |*********|*********|*********|
                                    ; --------------+---------+---------|---------|---------|---------|

;**** レジスタの復帰 ****
        pop ebx
        pop eax
        
;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        ret

