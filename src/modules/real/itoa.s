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
    
    ; ** 基数変換 **
.TO_ASCII:
        mov bx, [bp + 10]   ; 基数
        cmp ax, 0
        jne .TO_ASCII_BEGIN
        mov si, 0
        jmp .TO_ASCII_LOOP
.TO_ASCII_BEGIN:
        mov dx, 0
        div bx                      ; DX = DX:AX % BX
                                    ; AX = DX:AX / BX
        mov si, dx
        .TO_ASCII_LOOP:
        mov dl, byte [.ascii + si]  ; DL = .ascii[DX]
        mov [di], dl
        dec di
        cmp ax, 0
        loopnz .TO_ASCII_BEGIN       
.TO_ASCII_END:

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
rep     stosb                   ; while (--CX) { *DI-- = AL }
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
    db "0123456789ABCDEF"