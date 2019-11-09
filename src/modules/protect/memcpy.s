;********************************************************************************
; void memcpy(dest, src, size)
;********************************************************************************
memcpy:
;**** スタックフレームの構築 **** 
                           ;    +16| size
                           ;    +12| src
                           ;     +8| dest
                           ;     +4| EIP (caller)
    push ebp               ; EBP  0| EBP (old)
    mov ebp, esp

;**** レジスタの保存 **** 
    push ecx
    push esi
    push edi

;**** ローカル変数 **** 

;**** 処理の開始 ****
    cld              ; DF = 0
    mov edi, [ebp +  8] ; コピー先
    mov esi, [ebp + 12] ; コピー元
    mov ecx, [ebp + 16] ; サイズ

rep movsb            ; while (*di++ = *si++);

;**** レジスタの復帰 **** 
    pop edi
    pop esi
    pop ecx

;**** スタックフレームの破棄 ****
    mov esp, ebp
    pop ebp
    ret