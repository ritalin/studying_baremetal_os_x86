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

;********************************************************************************
; void copy_vram_font(font, vram, plane, color)
;********************************************************************************
copy_vram_font:
;**** スタックフレームの構築 **** 
                            ;    +20 文字色
                            ;    +16 書き込み先プレーン
                            ;    +12 VRAMアドレス
                            ;     +8 フォントアドレス
                            ;     +4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp

;**** レジスタの保存 **** 
        push eax
        push ebx
        push ecx
        push edx
        push esi
        push edi

;**** 処理の開始 ****
        mov esi, [ebp + 8]              ; フォント
        mov edi, [ebp + 12]             ; 出力先VRAMアドレス
        movzx eax, byte [ebp + 16]      ; プレーン
        movzx ebx, word [ebp + 20]      ; 文字色(上位：背景色 下位：前景色)

        test bh, al                     ; 背景色 & プレーン
        setz dh                         ; DH = ZF ? 0x01 : 0x00
        dec dh                          ; DH-- => 0x00 or 0xFF

        test bl, al                     ; 前景色 & プレーン
        setz dl                         ; DL = ZF ? 0x01 : 0x00
        dec dl                          ; DL-- => 0x00 or 0xFF

        ; ** 1ラインずつフォントの切り出し
        cld                             ; DF = 0
        mov ecx, 16
.LOOP:
        lodsb                           ; AL= *ESI++
        mov ah, al
        not ah

        ; ** 前景色と背景色を合成する
        and al, dl                      ; 前景色    

        test ebx, 0x0010                ; 透過色の判定
        jz .COLOR_COPY
.COLOR_TRANSP:
        and ah, [edi]                   ; 透過合成
        jmp .COLOR_END
.COLOR_COPY:  
        and ah, dh                      ; 背景色
.COLOR_END:  
        or al, ah                       ; 色の合成 

        mov [edi], al
        add edi, 80
        loop .LOOP
.END:

;**** レジスタの復帰 **** 
        pop edi
        pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax

;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        ret