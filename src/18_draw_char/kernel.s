%include "include/define.s"
%include "include/macro.s"

        ORG KERNEL_LOAD

[BITS 32]
;********************************************************************************
; エントリポイント
;********************************************************************************
kernel:
        ; ** フォントアドレスを取得する **
        mov esi, BOOT_LOAD + SECT_SIZE      ; ESI = 0x7c00 + 512
        movzx eax, word [esi + font.seg]    ; フォントセグメント
        movzx ebx, word [esi + font.off]    ; フォントオフセットアドレス
        shl eax, 4                          ; リアルモードセグメントアドレスのため
        add eax, ebx                        ; 実アドレスを計算
        mov [FONT], eax

        ; ** 8Bitの横線を描画
        mov ah, 0x07                        ; 書き込みプレーンを指示 (_____RGB)
        mov al, 0x02                        ; 書き込みプレーンのマスク
        mov dx, 0x03C4                      ; シーケンサ制御ポート

        out dx, ax                          ; ポート出力
        mov [0x000A_0000 + 0], byte 0xFF

        mov ah, 0x04                        ; 書き込みプレーンを指示 (_____R__)
        out dx, ax                          ; ポート出力
        mov [0x000A_0000 + 480 + 1], byte 0xFF

        mov ah, 0x02                        ; 書き込みプレーンを指示 (______G_)
        out dx, ax                          ; ポート出力
        mov [0x000A_0000 + 480 + 2], byte 0xFF

        mov ah, 0x01                        ; 書き込みプレーンを指示 (_______B)
        out dx, ax                          ; ポート出力
        mov [0x000A_0000 + 480 + 3], byte 0xFF
        
        ; ** 画面を横切る横線を描画
        mov     ah, 0x02                        ; AH = 書き込みプレーンを指定(Bit:----__G_)        
        out     dx, ax                          ; // ポート出力        
        lea     edi, [0x000A_0000 + 960]        ; EDI = VRAMアドレス;        
        mov     ecx, 80                         ; ECX = 繰り返し回数;        
        mov     al, 0xFF                        ; AL  = ビットパターン;        
    rep stosb                                   ; *EDI++ = AL;

        ; ** 8ドットの矩形を描画
        mov edi, 1
        shl edi, 8
        lea edi, [edi * 4 + edi + 0xA_0000]     ; 10Bitシフト + 8Bitシフト = フォント1行分のオフセット
        mov [edi + 80 * 0], word 0xFF
        mov [edi + 80 * 1], word 0xFF
        mov [edi + 80 * 2], word 0xFF
        mov [edi + 80 * 3], word 0xFF
        mov [edi + 80 * 4], word 0xFF
        mov [edi + 80 * 5], word 0xFF
        mov [edi + 80 * 6], word 0xFF
        mov [edi + 80 * 7], word 0xFF

        ; ** 文字を印字
        mov esi, 'A'
        shl esi, 4          ; 1文字が16Byteのため、メモリ上の文字のオフセットを計算
        add esi, [FONT]

        mov edi, 2
        shl edi, 8
        lea edi, [edi * 4 + edi + 0xA_0000]
        mov ecx, 16         ; 1文字の高さ
.CHAR_LOOP:
        movsb
        add edi, 80-1
        loop .CHAR_LOOP

        jmp $

ALIGN 4, db 0
FONT:   dd 0                                ; フォントアドレス保持先   

;********************************************************************************
; パディング(8kB)
;********************************************************************************
        times KERNEL_SIZE - ($-$$) db 0x00


