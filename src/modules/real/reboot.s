;********************************************************************************
; void reboot()
;********************************************************************************
reboot:
;**** スタックフレームの構築 **** 
                            ;    +2| IP (caller)
        push bp             ; BP  0| BP (old)
        mov bp, sp

;**** レジスタの保存 **** 
   
;**** 処理の開始 ****
    cdecl puts, .s0

    ; ** キー入力待ち **
.WAIT_SPACE_KEY:
    mov ah, 0x10
    int 0x16                ; キー入力待ち
    cmp al, ' '
    jne .WAIT_SPACE_KEY

    ; ** 再起動 **
    cdecl puts, .s1
    int 0x19

;**** レジスタの復帰 **** 

;**** スタックフレームの破棄 ****
        mov sp, bp
        pop bp
        ret

.s0:    db "Push SPACE Key to reboot ...", 0x0A, 0x0D, 0
.s1:    db 0x0A, 0x0D, 0x0A, 0x0D, 0
