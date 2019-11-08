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

        cdecl task_02_prepare
.LOOP_FPU:
        cdecl task_02_calc

                                    ; ------------+---------+---------|---------|---------|---------|
                                    ;         ST0 |      ST1|      ST2|      ST3|      ST4|      ST5|
                                    ; ------------+---------+---------|---------|---------|---------|
        fbstp [.bcd]                ;          t3 |    2*pi |       d |    1000 |xxxxxxxxx|xxxxxxxxx|
                                    ; ------------+---------+---------|---------|---------|---------|

        ; ** 計算結果の表示
        cdecl draw_fpu_bcd, 72, 1, .bcd

        cdecl wait_tick, 20
        jmp .LOOP_FPU

;**** レジスタの復帰 ****

;**** スタックフレームの破棄 ****

.s0:    db "Task-2", 0
.bcd:   times 10 db 0x00
.tmp:   times 10 db 0x00

;********************************************************************************
; void task_02_prepare()
;********************************************************************************
task_02_prepare:
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
; void task_02_calc()
;********************************************************************************
task_02_calc:
;**** スタックフレームの構築 ****
                            ;     +4| EIP (caller)
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
        fsin                        ;     sin(t3) |      t3 |    2*pi |       d |    1000 |xxxxxxxxx|
        fmul st0, st4               ; st4*sin(t3) |      t3 |    2*pi |       d |    1000 |xxxxxxxxx|
                                    ; ------------+---------+---------|---------|---------|---------|
;**** レジスタの復帰 ****

;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        ret
