;********************************************************************************
; void wait_tick(tick)
;********************************************************************************
wait_tick:
;**** スタックフレームの構築 **** 
                            ;     +8| 割り込み待ち回数
                            ;     +4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp

;**** レジスタの保存 **** 
        push eax
        push ecx

;**** 処理の開始 ****
        mov ecx, [ebp + 8]
.LOOP:
        mov eax, [TIMER_COUNT]
.WAIT_CHANGE:
        cmp [TIMER_COUNT], eax
        je .WAIT_CHANGE             ; 値が変わるまで待つ
        loop .LOOP
.LOOP_END:

;**** レジスタの復帰 **** 
        pop ecx
        pop eax

;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        ret