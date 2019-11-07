;********************************************************************************
; void task_03()
;********************************************************************************
task_03:
;**** スタックフレームの構築 **** 
                            ;      0| EIP (caller)
;**** レジスタの保存 **** 
         
;**** 処理の開始 ****
        ; ** コールゲートを介して文字列を描画する
        cdecl SS_GATE_00:0, 63, 2, 0x07, .s0

        cdecl task_03_prepare
.LOOP_FPU:
        cdecl task_03_calc

                                    ; ------------+---------+---------|---------|---------|---------|
                                    ;         ST0 |      ST1|      ST2|      ST3|      ST4|      ST5|
                                    ; ------------+---------+---------|---------|---------|---------|
        fbstp [.bcd]                ;          t3 |    2*pi |       d |    1000 |xxxxxxxxx|xxxxxxxxx|
                                    ; ------------+---------+---------|---------|---------|---------|

        ; ** 計算結果の表示
        cdecl task_03_draw_bcd, .bcd

        cdecl wait_tick, 20
        jmp .LOOP_FPU

;**** レジスタの復帰 ****

;**** スタックフレームの破棄 ****

.s0:    db "Task-3", 0
.bcd:   times 10 db 0x00
.tmp:   times 10 db 0x00

;********************************************************************************
; void task_03_prepare()
;********************************************************************************
task_03_prepare:
;**** スタックフレームの構築 ****
                            ;     +4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp
;**** レジスタの保存 ****

;**** 処理の開始 ****
                                    ; ------------+---------+---------|---------|---------|---------|
                                    ;         ST0 |      ST1|      ST2|      ST3|      ST4|      ST5|
                                    ; ------------+---------+---------|---------|---------|---------|
        fild dword [.c1000]         ;        1000 |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
        fldpi                       ;          pi |    1000 |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
        fidiv dword [.c180]         ;      pi/180 |    1000 |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
        fldpi                       ;          pi |  pi/180 |    1000 |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
        fadd st0, st0               ;        2*pi |  pi/180 |    1000 |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
        fldz                        ;         t=0 |    2*pi |  pi/180 |    1000 |xxxxxxxxx|xxxxxxxxx|
                                    ; ------------+---------+---------|---------|---------|---------|
;**** レジスタの復帰 ****

;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        ret

.c1000: dd 1000
.c180:  dd 180

;********************************************************************************
; void task_03_calc()
;********************************************************************************
task_03_calc:
;**** スタックフレームの構築 ****
                            ;      0| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp
;**** レジスタの保存 ****
;**** 処理の開始 ****
                                    ; ------------+---------+---------|---------|---------|---------|
                                    ;         ST0 |      ST1|      ST2|      ST3|      ST4|      ST5|
                                    ; ------------+---------+---------|---------|---------|---------|
                                    ;           t |    2*pi |       d |    1000 |xxxxxxxxx|xxxxxxxxx|
                                    ; ------------+---------+---------|---------|---------|---------|
        fadd st0, st2               ;      t2=t+d |    2*pi |       d |    1000 |xxxxxxxxx|xxxxxxxxx|
        fprem                       ;  t3=mod(t2) |    2*pi |       d |    1000 |xxxxxxxxx|xxxxxxxxx|
        fld st0                     ;          t3 |      t3 |    2*pi |       d |    1000 |xxxxxxxxx|
        fcos                        ;     cos(t3) |      t3 |    2*pi |       d |    1000 |xxxxxxxxx|
        fmul st0, st4               ; st4*cos(t3) |      t3 |    2*pi |       d |    1000 |xxxxxxxxx|
                                    ; ------------+---------+---------|---------|---------|---------|
;**** レジスタの復帰 ****

;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        ret

;********************************************************************************
; void task_03_draw_bcd(bcd)
;********************************************************************************
task_03_draw_bcd:
                            ;     +8| bcdの先頭アドレス
                            ;     +4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp
;**** レジスタの保存 ****
        push eax
        push ebx
        push edx

;**** 処理の開始 ****
        mov edx, [ebp + 8]
        mov eax, [edx]
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
        bt [edx + 9], eax                  ; [bcd + 9] & 0x80
        jc .SIGN_MINUS
.SIGN_PLUS:
        mov [.s1], byte '+'
        jmp .SIGN_END
.SIGN_MINUS:
        mov [.s1], byte '-'
.SIGN_END:

        cdecl draw_str, 72, 2, 0x07, .s1

;**** レジスタの復帰 **** 
        pop edx
        pop ebx
        pop eax

;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        ret

.s1:    db "-"
.s2:    db " ."
.s3:    db "    ", 0
