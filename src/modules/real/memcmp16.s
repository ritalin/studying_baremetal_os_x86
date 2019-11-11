;********************************************************************************
; void memcmp(p1, p2, size)
;********************************************************************************
memcmp:
;**** スタックフレームの構築 **** 
                        ;    +12| size   
                        ;     +8| p2
                        ;     +4| p1
                        ;     +2| IP (caller)
        push bp             ; BP   0| BP (old)
        mov bp, sp

;**** レジスタの保存 **** 
        push bx
        push cx
        push dx
        push si
        push di
    
;**** ローカル変数 **** 

;**** 処理の開始 ****
        cld              ; DF = 0
        mov si, [bp + 4] ; p1
        mov di, [bp + 6] ; p2
        mov cx, [bp + 8] ; size

repe    cmpsb            ; if (ZF == 0) { ret = 0 } else { ret = -1 }
        jnz .10F
        mov ax, 0
        jmp .10E
.10F:
        mov ax, -1
.10E:

;**** レジスタの復帰 **** 
        pop di
        pop si
        pop dx
        pop cx
        pop bx

;**** スタックフレームの破棄 ****
        mov sp, bp
        pop bp
        ret