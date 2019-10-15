;********************************************************************************
; int lba_to_chs(drive, out chs, lba)
;********************************************************************************
lba_to_chs:
;**** スタックフレームの構築 **** 
                            ;    +8| LBA
                            ;    +6| CHS分解結果の展開先アドレス
                            ;    +4| ドライブ情報へのポインタ
                            ;    +2| IP (caller)
        push bp             ; BP  0| BP (old)
        mov bp, sp

;**** レジスタの保存 **** 
        push bx
        push dx
        push si
        push di

;**** 処理の開始 ****
        mov si, [bp + 4]
        mov di, [bp + 6]

        mov al, [si + drive.head]   ; 最大ヘッド数
        mul byte [si + drive.sect]  ; 最大ヘッド数 * 最大セクタ数
        mov bx, ax

        mov dx, 0                   ; LBA (上位2 Byte)
        mov ax, [bp + 8]            ; LBA (下位2 Byte)
        div bx
        mov [di + drive.cyln], ax   ; シリンダ番号 = DX:AX / BX

        mov ax, dx
        div byte [si + drive.sect]
        movzx dx, ah
        inc dx                      
        mov [di + drive.sect], dx   ; セクタ番号 = 8DX:AX % BX) % 最大セクタ数 + 1 

        mov ah, 0x00
        mov [di + drive.head], ax   ; ヘッド位置 = 8DX:AX % BX) / 最大セクタ数      
        
        ; ** 戻り値 **
        xor ax, ax

;**** レジスタの復帰 **** 
        pop di
        pop si
        pop dx
        pop bx

;**** スタックフレームの破棄 ****
        mov sp, bp
        pop bp
        ret