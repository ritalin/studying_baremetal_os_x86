;********************************************************************************
; int get_drive_param(drive)
;********************************************************************************
get_drive_param:
;**** スタックフレームの構築 **** 
                            ;    +4| ドライブ構造体へのポインタ
                            ;    +2| IP (caller)
        push bp             ; BP  0| BP (old)
        mov bp, sp

;**** レジスタの保存 **** 

;**** 処理の開始 ****
    mov ax, 1

;**** レジスタの復帰 **** 

;**** スタックフレームの破棄 ****
        mov sp, bp
        pop bp
        ret