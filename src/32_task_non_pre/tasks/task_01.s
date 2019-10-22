;********************************************************************************
; void task_01()
;********************************************************************************
task_01:
;**** スタックフレームの構築 **** 
                            ;      0| EIP (caller)
;**** レジスタの保存 **** 
    
;**** 処理の開始 ****

.LOOP:
        cdecl draw_str, 63, 0, 0x07, .s0

        ; ** 時刻を表示する
        mov eax, [RTC_TIME]
        cdecl draw_time, 72, 0, 0x0700, eax

        jmp SS_TASK_00:0
        hlt
        jmp .LOOP

;**** レジスタの復帰 **** 

;**** スタックフレームの破棄 ****

.s0:    db "Task-1", 0