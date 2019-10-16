;********************************************************************************
; void select_vga_read_plane(plane)
;********************************************************************************
select_vga_read_plane:
;**** スタックフレームの構築 **** 
                            ;     +8| プレーン番号 (0=R, 1=G, 2=B, 3=I)
                            ;     +4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp

;**** レジスタの保存 **** 
        push eax
        push edx

;**** 処理の開始 ****
        mov ah, [ebp + 8]
        and ah, 0x03        ; 余計なビットをマスクする(下位2Bit)
        mov al, 0x04        ; 読み込みマップレジスタ
        mov dx, 0x03CE      ; グラフィックス制御ポート
        out dx, ax

;**** レジスタの復帰 **** 
        pop edx
        pop eax

;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        ret

;********************************************************************************
; void select_vga_write_plane(plane)
;********************************************************************************
select_vga_write_plane:
;**** スタックフレームの構築 **** 
                            ;     +8| プレーンのビットマスク (0b____IRGB)
                            ;     +4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp

;**** レジスタの保存 **** 
        push eax
        push edx

;**** 処理の開始 ****
        mov ah, [ebp + 8]
        and ah, 0x0F        ; 余計なビットをマスクする(下位4Bit)
        mov al, 0x02        ; マップマスクレジスタ
        mov dx, 0x3C4       ; シーケンサ制御ポート
        out dx, ax

;**** レジスタの復帰 **** 
        pop edx
        pop eax

;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        ret
