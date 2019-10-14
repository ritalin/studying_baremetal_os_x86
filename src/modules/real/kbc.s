;********************************************************************************
; int write_kbc_cmd(cmd)
;********************************************************************************
write_kbc_cmd:
;**** スタックフレームの構築 **** 
                            ;    +4| 送信するコマンド
                            ;    +2| IP (caller)
        push bp             ; BP  0| BP (old)
        mov bp, sp

;**** レジスタの保存 **** 
        push cx

;**** 処理の開始 ****
        mov cx, 1
.RETRY:
        in al, 0x64         ; KBCステータス
        test al, 0x02       ; 書き込み可能かどうか
        jz .SUCCESS
        loop .RETRY         ; while (--CX)
        jmp .END             ; 失敗
.SUCCESS:
        mov al, [bp + 4]
        out 0x64, al
.END:
        mov ax, cx

;**** レジスタの復帰 **** 
        pop cx

;**** スタックフレームの破棄 ****
        mov sp, bp
        pop bp
        ret

;********************************************************************************
; int read_kbc_data(out key)
;********************************************************************************
read_kbc_data:
;**** スタックフレームの構築 **** 
                            ;    +4| 展開先のアドレス
                            ;    +2| IP (caller)
        push bp             ; BP  0| BP (old)
        mov bp, sp

;**** レジスタの保存 **** 
        push cx
        push di

;**** 処理の開始 ****
        mov cx, 1
.RETRY:
        in al, 0x64         ; KBCステータス
        test al, 0x01       ; 読み込み可能かどうか
        jnz .SUCCESS
        loop .RETRY         ; while (--CX)
        jmp .END
.SUCCESS:
        mov ax, 0x00
        in al, 0x60         ; データの取得依頼

        mov di, [bp + 4]
        mov [di + 0], ax
.END:
        mov ax, cx

;**** レジスタの復帰 **** 
        pop di
        pop cx

;**** スタックフレームの破棄 ****
        mov sp, bp
        pop bp
        ret

;********************************************************************************
; int write_kbc_data(data)
;********************************************************************************
write_kbc_data:
;**** スタックフレームの構築 **** 
                            ;    +4| 送信するデータ
                            ;    +2| IP (caller)
        push bp             ; BP  0| BP (old)
        mov bp, sp

;**** レジスタの保存 **** 
        push cx

;**** 処理の開始 ****
        mov cx, 1
.RETRY:
        in al, 0x64         ; KBCステータス
        test al, 0x02       ; 書き込み可能かどうか
        jz .SUCCESS
        loop .RETRY         ; while (--CX)
        jmp .END             ; 失敗
.SUCCESS:
        mov al, [bp + 4]
        out 0x60, al
.END:
        mov ax, cx

;**** レジスタの復帰 **** 
        pop cx

;**** スタックフレームの破棄 ****
        mov sp, bp
        pop bp
        ret

wait_write_kbc:
.RETRY:
        in al, 0x64         ; KBCステータス
        test al, 0x02       ; 書き込み可能かどうか
        jnz .RETRY       ; while (!ZF)
        ret

wait_read_kbc:
.RETRY:
        in al, 0x64         ; KBCステータス
        test al, 0x01       ; 読み込み可能かどうか
        jz .RETRY       ; while (!ZF)
        ret


