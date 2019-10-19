;********************************************************************************
; void draw_time(col, row, color, time)
;********************************************************************************
draw_time:
;**** スタックフレームの構築 **** 
                            ;    +20| 時刻
                            ;    +16| 前景色
                            ;    +12| 表示行
                            ;     +8| 表示列
                            ;     +4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp

;**** レジスタの保存 **** 
        push eax
        
;**** 処理の開始 ****
        cdecl draw_str, dword [ebp + 8], dword [ebp + 12], dword [ebp + 16], .time

;**** レジスタの復帰 **** 
        pop eax

;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        ret

.time:
.hour:  db "hh", ":"  
.min:   db "mm", ":"
.sec:   db "ss", 0