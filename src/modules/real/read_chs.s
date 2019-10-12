;********************************************************************************
; int read_chs(drive, sect, out dest)
;********************************************************************************
read_chs:
;**** スタックフレームの構築 **** 
                            ;    +8| 展開先アドレス
                            ;    +6| 読み込むセクタ数
                            ;    +4| ドライブ構造体へのポインタ                                                        
                            ;    +2| IP (caller)
        push bp             ; BP  0| BP (old)
        mov bp, sp
        push 3              ;    -2| リトライ回数
        push 0              ;    -4| 読み込んだセクタ数

;**** レジスタの保存 **** 
        push bx
        push cx
        push dx
        push es
        push si 

;**** 処理の開始 ****
        mov si, [bp + 4]

        ; ** シリンダ / セクタ位置の指定 **
        mov ch, [si + drive.cyln + 0]
        mov cl, [si + drive.cyln + 1]   
        shl cx, 6                       ; シリンダ位置は最上位2ビットにまたがる
        or cl, [si + drive.sect]        ; |= セクタ番号

        ; ** セクタを読み込む
        mov dh, [si + drive.head]       ; ヘッド位置
        mov dl, [si + drive.no]         ; ドライブ番号
        mov ax, 0x0000
        mov es, ax                      ; 展開先セグメント
        mov bx, [bp + 8]                ; 展開先アドレス
.RETRY:
        mov ah, 0x02
        mov al, [bp + 6]                ; 読み込むセクタ数
        int 0x13
        jnc .FOUND
        mov al, 0                      
        jmp .END                        ; 見つからなかった
.FOUND:       
        cmp al, 0
        jne .END                        ; 取得成功

        mov ax, 0                       ; 戻り値 = 0をセット
        dec word [bp - 2]               ; リトライ
        jnz .RETRY                      ; while (--retry) {
.END:
        mov ah, 0                       ; ステータス情報を破棄する

;**** レジスタの復帰 **** 
        pop si
        pop es
        pop dx
        pop cx
        pop bx

;**** スタックフレームの破棄 ****
        mov sp, bp
        pop bp
        ret