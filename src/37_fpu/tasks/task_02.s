;********************************************************************************
; void task_02()
;********************************************************************************
task_02:
;**** スタックフレームの構築 **** 
                            ;      0| EIP (caller)
;**** レジスタの保存 **** 
         
;**** 処理の開始 ****
        ; ** コールゲートを介して文字列を描画する
        cdecl SS_GATE_00:0, 63, 1, 0x07, .s0

                                    ; ------------+---------+---------|---------|---------|---------|
                                    ;         ST0 |      ST1|      ST2|      ST3|      ST4|      ST5|
                                    ; ------------+---------+---------|---------|---------|---------|
        fild dword [.c1000]         ;        1000 |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
        fldpi                       ;          pi |    1000 |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
        fidiv dword [.c180]         ;      pi/180 |    1000 |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
        fldpi                       ;          pi |  pi/180 |    1000 |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
        fadd st0, st0               ;        2*pi |  pi/180 |    1000 |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
        fldz                        ;     theta=0 |    2*pi |  pi/180 |    1000 |xxxxxxxxx|xxxxxxxxx|
                                    ; ------------+---------+---------|---------|---------|---------|
.LOOP_FPU:                          ;           t |    2*pi |       d |    1000 |xxxxxxxxx|xxxxxxxxx|
                                    ; ------------+---------+---------|---------|---------|---------|
        fadd st0, st2               ;      t2=t+d |    2*pi |       d |    1000 |xxxxxxxxx|xxxxxxxxx|
        fprem                       ;  t3=mod(t2) |    2*pi |       d |    1000 |xxxxxxxxx|xxxxxxxxx|
        fld st0                     ;          t3 |      t3 |    2*pi |       d |    1000 |xxxxxxxxx|
        fsin                        ;     sin(t3) |      t3 |    2*pi |       d |    1000 |xxxxxxxxx|
        fmul st0, st4               ; st4*sin(t3) |      t3 |    2*pi |       d |    1000 |xxxxxxxxx|
        fbstp [.bcd]                ;          t3 |    2*pi |       d |    1000 |xxxxxxxxx|xxxxxxxxx|
                                    ; ------------+---------+---------|---------|---------|---------|

        ; ** 計算結果の表示
        mov eax, [.bcd]
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
        bt [.bcd + 9], eax                  ; [.bcd + 9] & 0x80
        jc .SIGN_MINUS
.SIGN_PLUS:
        mov [.s1], byte '+'
        jmp .SIGN_END
.SIGN_MINUS:
        mov [.s1], byte '-'
.SIGN_END:

        cdecl draw_str, 72, 1, 0x07, .s1
.LOOP:
       jmp .LOOP

;**** レジスタの復帰 **** 

;**** スタックフレームの破棄 ****

.s0:    db "Task-2", 0
.s1:    db "-"
.s2:    db " ."
.s3:    db "    ", 0
.c1000: dd 1000
.c180:  dd 180
.bcd:   times 10 db 0x00