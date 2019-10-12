;********************************************************************************
; void itoa(num, buf, size, radix, flag)
;********************************************************************************
itoa:
;**** スタックフレームの構築 **** 
                            ;   +12| パディング方法(0: ' 'で埋める, 1: '0'で埋める), 数値型(0: signed, 1: unsigned)
                            ;   +10| 基数(2, 8, 10, 16)
                            ;    +8| 保存先バッファサイズ
                            ;    +6| 保存先バッファ
                            ;    +4| 文字列にする数値
                            ;    +2| IP (caller)
        push bp             ; BP  0| BP (old)
        mov bp, sp

;**** レジスタの保存 **** 
        push ax
        push bx
        push cx
        push dx
        push si
        push di

;**** 処理の開始 ****
        mov ax, [bp + 4]    ; 数値
        mov si, [bp + 6]    ; バッファ先頭
        mov cx, [bp + 8]    ; バッファサイズ

        mov di, si       
        add di, cx       
        dec di              ; バッファ最後尾

    ; ** パディング **
.PADDING:
        cmp cx, 0
        je .PADDING_END

        mov al, ' '
        cmp [bp + 12], word 0b0010
        jne .PADDING_BEGIN
        mov al, '0'
.PADDING_BEGIN:        
        std                     ; DF = 1
rep     stosb                   ; while (--CX) { *DI = AL }
.PADDING_END:

;**** レジスタの復帰 **** 
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax

;**** スタックフレームの破棄 ****
        mov sp, bp
        pop bp
        ret

.ascii:
    db "01234567890ABCDEF"