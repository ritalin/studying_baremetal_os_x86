;********************************************************************************
; void task_04()
;********************************************************************************
task_04:
;**** スタックフレームの構築 **** 
        mov ebp, esp        ; EBP  0| EBP (old)
        push dword 0        ;     -4| 原点(x)   
        push dword 0        ;     -8| 原点(y)            
;**** レジスタの保存 **** 

;**** 処理の開始 ****
        mov esi, ROSE_PARAM

        ; ** タイトル表示 **
        mov eax, [esi + rose.x0] 
        mov ebx, [esi + rose.y0]

        shr eax, 3                      ; x0 = x0 / 8
        shr ebx, 4                      ; y0 = y0 / 16
        dec ebx                         ; --y0

        mov ecx, [esi + rose.color_font]
        lea edx, [esi + rose.title]

        cdecl draw_str, eax, ebx, ecx, edx

        ; ** 原点座標の計算 **
        mov eax, [esi + rose.x0]        ; 左上(x)
        mov ebx, [esi + rose.width]     ; 枠の幅
        shr ebx, 1                      ; ebx /= 2
        add ebx, eax                
        mov [ebp - 4], ebx              ; 原点(x)を保存

        mov eax, [esi + rose.y0]        ; 左上(y)
        mov ebx, [esi + rose.height]    ; 枠の高さ
        shr ebx, 1                      ; ebx /= 2
        add ebx, eax
        mov [ebp - 8], ebx              ; 原点(y)を保存

        ; ** 座標軸を描画する **

        mov eax, [esi + rose.x0]        ; x0
        mov ebx, [ebp - 8]              ; 原点(y)
        mov ecx, [esi + rose.width]     ; 枠の幅
        add ecx, eax                    ; x1

        cdecl draw_line, eax, ebx, ecx, ebx, dword [esi + rose.color_axis_x]

        mov eax, [esi + rose.y0]        ; y0
        mov ebx, [ebp - 4]              ; 原点(x)
        mov ecx, [esi + rose.height]    ; 枠の高さ
        add ecx, eax                    ; y1

        cdecl draw_line, ebx, eax, ebx, ecx, dword [esi + rose.color_axis_y]

        ; ** 外枠を描画する **

        mov eax, [esi + rose.x0]        ; x0
        mov ebx, [esi + rose.y0]        ; y0
        mov ecx, [esi + rose.width]     ; 枠の幅
        mov edx, [esi + rose.height]    ; 枠の高さ

        cdecl draw_rect, eax, ebx, ecx, edx, dword [esi + rose.color_frame]

.LOOP_FPU:
        jmp .LOOP_FPU

;**** レジスタの復帰 ****

;**** スタックフレームの破棄 ****

ALIGN 4, db 0
ROSE_PARAM:
    istruc rose 
        at rose.x0,             dd 16           ; 左上(x)
        at rose.y0,             dd 32           ; 左上(y)
        at rose.width,          dd 400          ; 枠の幅
        at rose.height,         dd 400          ; 枠の高さ
        at rose.color_font,     dd 0x030F       ; 文字色    
        at rose.color_axis_x,   dd 0x0007       ; X軸の表示色
        at rose.color_axis_y,   dd 0x0007       ; Y軸の表示色
        at rose.color_frame,    dd 0x000F       ; 枠線の色
        at rose.title,          db "Task-4", 0  ; キャプション
    iend

;********************************************************************************
; void prepare_fpu_rose(A, n, d)
;********************************************************************************
prepare_fpu_rose:
;**** スタックフレームの構築 **** 
                            ;    +16| d  
                            ;    +12| n
                            ;     +8| A
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
        fmul st0, st1               ;             y |       Z |       A |       k |       r |*********|
        fchs                        ;            -y |       Z |       A |       k |       r |*********|
        fistp dword [ebx]           ;             Z |       A |       k |       r |*********|*********|
                                    ; --------------+---------+---------|---------|---------|---------|

;**** レジスタの復帰 ****
        pop ebx
        pop eax
        
;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        ret

