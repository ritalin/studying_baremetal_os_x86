;********************************************************************************
; void int get_rtc_time(out time)
;********************************************************************************
get_rtc_time:
;**** スタックフレームの構築 **** 
                            ;     +8| 取得した時刻の展開先
                            ;     +4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp

;**** レジスタの保存 **** 
        push edi

;**** 処理の開始 ****
    mov edi, [ebp + 8]
    mov [edi + 0], byte 44
    mov [edi + 1], byte 18
    mov [edi + 2], byte 13

;**** レジスタの復帰 **** 
        pop edi

;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        ret