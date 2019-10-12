;********************************************************************************
; int get_drive_param(var drive)
;********************************************************************************
get_drive_param:
;**** スタックフレームの構築 **** 
                            ;    +4| ドライブ構造体へのポインタ
                            ;    +2| IP (caller)
        push bp             ; BP  0| BP (old)
        mov bp, sp

;**** レジスタの保存 **** 
        push bx
        push cx
        push es
        push si
        push di

;**** 処理の開始 ****
        mov si, [bp + 4]            ; ドライブパラメータ 
        xor ax, ax
        mov es, ax
        mov di, ax

        mov ah, 0x08
        mov al, [si + drive.no]     ; ドライブ番号
        int 0x13

        jc .NOT_FOUND

        movzx bx, dh
        inc bx

        mov al, cl                  
        and al, 0x3F                ; セクタ数(下位6Bit)

        shr cx, 6                   ; cx >> 6
        ror cx, 8
        inc cx

        movzx bx, dh
        inc bx

        mov [si + drive.cyln], cx
        mov [si + drive.head], bx
        mov [si + drive.sect], ax

        jmp .FOUND
.NOT_FOUND:
        mov ax, 0
.FOUND:

;**** レジスタの復帰 **** 
        pop di
        pop si
        pop es
        pop cx
        pop bx

;**** スタックフレームの破棄 ****
        mov sp, bp
        pop bp
        ret