;********************************************************************************
; void puts(s)
;********************************************************************************
puts:
;**** スタックフレームの構築 **** 
                            ;    +4| s (文字列の先頭アドレス)
                            ;    +2| IP (caller)
        push bp             ; BP  0| BP (old)
        mov bp, sp

;**** レジスタの保存 **** 
        push ax
        push bx
        push si

;**** 処理の開始 ****
        mov si, [bp + 4]
        mov ah, 0x0E        ; テレタイプ一文字出力
        mov bx, 0x0000
        cld                 ; DF = 0
.10L:
        lodsb              ; Al = *SI++
        cmp al, 0                     
        je .10E
        int 0x10
        jmp .10L
.10E:

;**** レジスタの復帰 **** 
        pop si
        pop bx
        pop ax

;**** スタックフレームの破棄 ****
        mov sp, bp
        pop bp
        ret