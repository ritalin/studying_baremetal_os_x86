;********************************************************************************
; void draw_pixel(x, y, color)
;********************************************************************************
draw_pixel:
;**** スタックフレームの構築 **** 
                            ;    +16| 前景色
                            ;    +12| Y座標
                            ;     +8| X座標
                            ;     +4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp

;**** レジスタの保存 **** 
        push ebx
        push ecx
        push edi

;**** 処理の開始 ****
        mov edi, [ebp + 12]                         ; Y座標からVRAMの先頭アドレスを計算する
        shl edi, 4      
        lea edi, [edi * 4 + edi + 0xA_0000]         ; 80Byte * Y座標を移動する

        mov ebx, [ebp + 8]
        mov ecx, ebx                                ; 後でビット位置を割り出すためX座標を退避
        shr ebx, 3                                  ; VGAは8bit単位で管理されるため、8で割る
        add edi, ebx                                ; 座標位置に相当するVRAMアドレス

        and ecx, 0x07                               ; 8で割ったあまりを求める
        mov ebx, 0b_1000_0000
        shr ebx, cl                                 ; ビットマスクを作成する

        ; 輝度の出力
        cdecl select_vga_read_plane, 0x03           ; [____ I___]
        cdecl select_vga_write_plane, 0x08          ; [____ I___]
        cdecl copy_vram_dot, ebx, edi, 0x08, ebx

        ; 赤の出力
        cdecl select_vga_read_plane, 0x02           ; [____ _R__]
        cdecl select_vga_write_plane, 0x04          ; [____ _R__]
        cdecl copy_vram_dot, ebx, edi, 0x04, ebx

        cdecl select_vga_read_plane, 0x01           ; [____ __G_]
        cdecl select_vga_write_plane, 0x02          ; [____ __G_]
        cdecl copy_vram_dot, ebx, edi, 0x02, 0x02

        ; 青の出力
        cdecl select_vga_read_plane, 0x00           ; [____ ___B]
        cdecl select_vga_write_plane, 0x01          ; [____ ___B]
        cdecl copy_vram_dot, ebx, edi, 0x01, ebx

;**** レジスタの復帰 **** 
        pop edi
        pop ecx
        pop ebx

;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        ret