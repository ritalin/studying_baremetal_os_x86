;********************************************************************************
; void int_pf()
;********************************************************************************
int_pf:
;**** スタックフレームの構築 **** 
                            ;     -4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp

;**** レジスタの保存 **** 
        pusha
        push ds
        push es

;**** 処理の開始 ****
        
        ; ** 例外発生元アドレスがROSE_PARAMかどうかの判定 **
        mov eax, cr2
        and eax, ~0x0FFF
        cmp eax, 0x0010_7000            
        jne .PAGING_FAILED

        mov [CR3_BASE + CR3_BASE_SIZE + 0x107 * 4], dword 0x0010_7007    ; ページを有効化にする
        cdecl memcpy, 0x0010_7000, ROSE_PARAM, rose_size    ; ローズパラメータをコピーする

;**** レジスタの復帰 **** 
        pop es
        pop ds
        popa

;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp        

        add esp, 4                                          ; エラーコードを破棄する
        iret

;**** タスクの終了 ****
.PAGING_FAILED:
        ; ** スタックを調整する **
        add esp, 4                  ; pop es
        add esp, 4                  ; pop ds
        popa
        pop ebp

        ; ** タスクを終了する **
        pushf               
        push cs             
        push int_stop       
        mov eax, .s0
        iret

.s0:    db " < PAGE FAULT > ", 0