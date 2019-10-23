;********************************************************************************
; void call_gate()
;********************************************************************************
call_gate:
;**** スタックフレームの構築 **** 
                            ;    +24| 文字列
                            ;    +20| 表示色
                            ;    +16| 行
                            ;    +12| 列
                            ;     +8| CS (コードセグメント)                            
                            ;     +4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp
;**** レジスタの保存 **** 

;**** 処理の開始 ****
        cdecl draw_str, 50, 0, 0x02, .s0


;**** レジスタの復帰 **** 
        
;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        retf 4 * 4

.s0: db "By Call Gate"