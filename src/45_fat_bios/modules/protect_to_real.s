;********************************************************************************
; void to_real_mode()
;********************************************************************************
[BITS 32]
to_real_mode:
;**** スタックフレームの構築 **** 
                            ;     +4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp

;**** レジスタの保存 **** 
        pusha

;**** 処理の開始 ****
        cli

        ; ** 現在の設定値を保存する **
        mov eax, cr0
        mov [.cr0_saved], eax
        mov [.esp_saved], esp
        sidt [.idtr_saved]
        lidt [.idtr_real]

        ; ** 16Bitプロテクトモードへ移行する **
        jmp 0x0018:.bit_16                  ; descripter.sで設定したリアルモード用コードセグメントセレクタ

[BITS 16]
.bit_16:
        mov ax, 0x0020                      ; descripter.sで設定したリアルモード用データセグメントセレクタ
        mov ds, ax
        mov es, ax
        mov ss, ax

        ; ** リアルモードへ移行する **
        mov eax, cr0
        and eax, ~((1 << 0x1F) | (1))         ; eax &= ~(PG | PE)
        mov cr0, eax
        jmp $ + 2                           ; 先読みをクリア

        ; ** リアルモードセグメントを設定する **
        jmp 0:.real                         ; CS = 0x0000に変更
.real:
        xor ax, ax
        mov ds, ax                          ; DS = 0x0000
        mov es, ax                          ; ES = 0x0000
        mov ss, ax                          ; SS = 0x0000
        mov esp, dword 0x7C00               ; 上位16Bitは0埋め

        ; ** ファイルを読み込む **
        cdecl read_sample_file

        ; ** 16Bitプロテクトモードへ移行する
        mov eax, cr0
        or eax, 1                                   ; eax |= PE
        mov cr0, eax
        jmp $ + 2                                   ; 先読みをクリア

        ; ** 32Bitプロテクトモードへ移行する
        db 0x66                                     ; 32bitオーバライドプレフィックス
[BITS 32]
        jmp 0x0008:.bit_32                          ; 32ビットカーネル用コードセグメントに変更
.bit_32:
        mov ax, 0x0010                              ; 32ビットカーネル用データセグメント
        mov ds, ax
        mov es, ax
        mov ss, ax

        ; ** レジスタ設定を復帰させる *:
        mov esp, [.esp_saved]
        mov eax, [.cr0_saved]                       ; 保存されたCR0を復帰させることで自動的にPGも復帰
        mov cr0, eax
        lidt [.idtr_saved]

        sti

;**** レジスタの復帰 **** 
        popa

;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        ret

.idtr_real:
        dw 0x3FF    ; 1024byte
        dd 0
.idtr_saved:
        dw 0        ; IDTRのリミット
        dd 0        ; IDTRのベースアドレス
.cr0_saved:
        dd 0
.esp_saved:
        dd 0