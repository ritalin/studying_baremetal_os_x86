;********************************************************************************
; void init_page_table()
;********************************************************************************
init_page_table:
;**** スタックフレームの構築 **** 
                            ;      0| EIP (caller)
;**** レジスタの保存 **** 
        pusha

;**** 処理の開始 ****
        ; ** 4MB分のページテーブルを構成する **
        cdecl set_4m_page, CR3_BASE

        ; ** 0x109*4kB = ROSE_PARAMを配置する予定のページエントリを無効にする **
        mov [CR3_BASE + CR3_PDE_SIZE + 0x109 * 4], dword 0  ; 0x0010_9000

;**** レジスタの復帰 **** 
        popa

;**** スタックフレームの破棄 ****
        ret

;********************************************************************************
; void set_4m_page(base)
;********************************************************************************
set_4m_page:
;**** スタックフレームの構築 **** 
                            ;     +8| ページテーブルベースアドレス
                            ;     +4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp

;**** レジスタの保存 **** 
        pusha

;**** 処理の開始 ****
        ; ** ページディレクトリを作成する **
        ; ** 1ページディレクトリで、1024 * 4MB = 4GB( = 32bitの全メモリ空間)の領域が管理可能
        cld                     ; DFクリア
        mov edi, [ebp + 8]
        mov eax, 0x0000_0000
        mov ecx, 1024           ; ディレクトリエントリ数
    rep stosd                   ; while (ecx--) *edi++ = eax

        ; ** 先頭のページディレクトリエントリを作成する **
        mov eax, edi                ; ページディレクトリ直後のアドレスを取得
        and eax, ~0x0000_0FFF       ; 物理アドレスの指定(上位20bit)
        or eax, 0b0111              ; RWの許可
        mov [edi - (1024 * 4)], eax ; 先頭のエントリを割り当てる

        ; ** ページテーブルを作成する **
        ; ** 1ページテーブルで、1024*4kB = 4MBの領域が管理可能 **
        mov eax, 0x0000_0007        ; 物理アドレスとRWの許可
        mov ecx, 1024               ; ページエントリ数
.LOOP:
        stosd                       ; *edi++ = eax
        add eax, 0x0000_1000
        loop .LOOP

;**** レジスタの復帰 **** 
        popa

;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        ret
