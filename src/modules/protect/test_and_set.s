;********************************************************************************
; void test_and_set(var flag)
;********************************************************************************
test_and_set:
;**** スタックフレームの構築 **** 
                            ;     +8| セマフォ実行用のフラグ
                            ;     +4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp

;**** レジスタの保存 **** 
        push eax
        push ebx

;**** 処理の開始 ****
        mov eax, 0
        mov ebx, [ebp + 8]

.CLAIM_LOCK_BEGIN:
lock    bts [ebx], eax
        jnc .CLAIM_LOCK_END     ; フラグを変更できた場合抜ける

.WAIT_LOCK:
        bt [ebx], eax           ; フラグが0になるまで待つ
        jc .WAIT_LOCK

        jmp .CLAIM_LOCK_BEGIN
.CLAIM_LOCK_END:

;**** レジスタの復帰 **** 
        pop ebx
        pop ebx

;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        ret