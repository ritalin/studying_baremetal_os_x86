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
        ; ** 時刻パートの抽出
        mov eax, [ebp + 20]

        movzx ebx, al                           ; 秒
        cdecl itoa, ebx, .sec, 2, 10, 0b0010

        mov bl, ah                              ; 分
        cdecl itoa, ebx, .min, 2, 10, 0b0010

        shr eax, 16                             ; 時
        cdecl itoa, eax, .hour, 2, 10, 0b0010

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