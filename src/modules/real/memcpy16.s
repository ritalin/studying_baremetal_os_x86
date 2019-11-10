;********************************************************************************
; void memcpy16(dest, src, size)
;********************************************************************************
memcpy16:
;**** スタックフレームの構築 **** 
                           ;    +8| size
                           ;    +6| src
                           ;    +4| dest
                           ;    +2| IP (caller)
    push bp                ; BP  0| BP (old)
    mov bp, sp

;**** レジスタの保存 **** 
    push cx
    push si
    push di
    push bx

;**** 処理の開始 ****
    cld              ; DF = 0
    mov di, [bp + 4] ; コピー先
    mov si, [bp + 6] ; コピー元
    mov cx, [bp + 8] ; サイズ

rep movsb            ; while (*di++ = *si++);

;**** レジスタの復帰 **** 
    pop di
    pop si
    pop cx

;**** スタックフレームの破棄 ****
    mov sp, bp
    pop bp
    ret