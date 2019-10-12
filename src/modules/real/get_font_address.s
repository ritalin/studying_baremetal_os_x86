;********************************************************************************
; void get_font_address(out font)
;********************************************************************************
get_font_address:
;**** スタックフレームの構築 **** 
                            ;    +4| フォントアドレスの展開先
                            ;    +2| IP (caller)
        push bp             ; BP  0| BP (old)
        mov bp, sp

;**** レジスタの保存 **** 
        push ax
        push bx
        push si
        push es
        push bp

;**** 処理の開始 ****
        mov si, [bp + 4]

        ; ** フォントアドレスの取得 **
        mov ax, 0x1130
        mov bh, 0x06
        int 10h             ; ES:BP <= フォントアドレス

        ; ** フォントアドレスの保存 **
        mov [si + 0], es
        mov [si + 2], bp
        
;**** レジスタの復帰 **** 
        pop bp
        pop es
        pop si
        pop bx
        pop ax

;**** スタックフレームの破棄 ****
        mov sp, bp
        pop bp
        ret