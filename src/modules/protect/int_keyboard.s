;********************************************************************************
; void int_keyboard()
;********************************************************************************
int_keyboard:
;**** スタックフレームの構築 **** 
                            ;      0| EIP (caller)
;**** レジスタの保存 **** 
        pusha
        push ds
        push es

;**** 処理の開始 ****
        ; ** データ用セグメントの設定
        mov ax, 0x0010
        mov ds, ax
        mov es, ax

        ; ** KBCからキーコードを取得する
        in al, 0x60

        ; ** 取得したキーコードをバッファリングする
        cdecl write_ring_buff, KEY_BUFF, eax

        ; ** 割り込み終了コマンドを送信する
        outp 0x20, 0x20     ; マスタPIC:EOIコマンド

;**** レジスタの復帰 **** 
        pop es
        pop ds
        popa

;**** スタックフレームの破棄 ****
        iret

ALIGN 4, db 0
KEY_BUFF:
        times ring_buff_size db 0
