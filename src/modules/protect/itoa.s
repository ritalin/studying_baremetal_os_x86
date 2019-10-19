;********************************************************************************
; void itoa(num, buf, size, radix, flag)
;********************************************************************************
itoa:
;**** スタックフレームの構築 **** 
                                        ;    +24| パディング方法(0: ' 'で埋める, 1: '0'で埋める), 数値型(0: unsigned, 1: signed)
                                        ;    +20| 基数(2, 8, 10, 16)
                                        ;    +16| 保存先バッファサイズ
                                        ;    +12| 保存先バッファ
                                        ;     +8| 文字列にする数値
                                        ;     +4| IP (caller)
        push ebp                        ; EBP  0| BP (old)
        mov ebp, esp

;**** レジスタの保存 **** 
        push eax
        push ebx
        push ecx
        push edx
        push esi
        push edi

;**** 処理の開始 ****
        mov eax, [ebp + 8]              ; 数値
        mov esi, [ebp + 12]             ; バッファ先頭
        mov ecx, [ebp + 16]             ; バッファサイズ

        mov edi, esi       
        add edi, ecx       
        dec edi                         ; バッファ最後尾
    
        ; ** 数値の符号判定 **
.SIGN_TEST:
        mov ebx, [ebp + 20]
        cmp ebx, 10
        jne .SIGN_TEST_END
        mov ebx, [ebp + 24]
        test ebx, 0b0001
        je .SIGN_TEST_END                ; unsigned
        cmp eax, 0
        jge .SIGN_TEST_POSITIVE
        neg eax
        mov [esi], byte '-'
        jmp .SIGN_TEST_OFFSET
.SIGN_TEST_POSITIVE:
        mov [esi], byte '+'
.SIGN_TEST_OFFSET:
        dec ecx
.SIGN_TEST_END:

        ; ** 基数変換 **
.TO_ASCII:
        mov ebx, [ebp + 20]   ; 基数
        cmp eax, 0
        jne .TO_ASCII_BEGIN
        mov esi, 0
        jmp .TO_ASCII_LOOP
.TO_ASCII_BEGIN:
        mov edx, 0
        div ebx                         ; EDX = EDX:EAX % EBX
                                        ;  EAX = EDX:EAX / EBX
        mov esi, edx
        .TO_ASCII_LOOP:
        mov dl, byte [.ascii + esi]     ; DL = .ascii[ESI]
        mov [edi], dl
        dec edi
        cmp eax, 0
        loopnz .TO_ASCII_BEGIN       
.TO_ASCII_END:

        ; ** パディング **
.PADDING:
        cmp ecx, 0
        je .PADDING_END

        mov al, ' '
        cmp [ebp + 24], word 0b0010
        jne .PADDING_BEGIN
        mov al, '0'
.PADDING_BEGIN:        
        std                     ; DF = 1
rep     stosb                   ; while (--CX) { *DI-- = AL }
.PADDING_END:

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

.ascii:
    db "0123456789ABCDEF"