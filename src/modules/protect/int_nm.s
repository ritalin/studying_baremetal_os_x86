;********************************************************************************
; void int_nm()
;********************************************************************************
int_nm:
;**** スタックフレームの構築 **** 
                            ;      0| EIP (caller)
;**** レジスタの保存 **** 
        pusha
        push ds
        push es

;**** 処理の開始 ****
        mov ax, DS_KERNEL
        mov ds, ax
        mov es, ax

        ; ** タスクスイッチフラグをクリアする
        clts

        ; ** 前回FPUを使用したタスク
        mov edi, [.last_tss]
        ; ** 今回FPUを使用するタスク
        str esi
        and esi, ~0x0007             ; 特権レベルをマスク

        cli

.SWITCH_FPU_BEGIN:
        ; ** FPU初回利用かどうか
        cmp     edi, 0                          
        je      .RESTORE_FPU                            
                                                
        cmp esi, edi
        je .SWITCH_FPU_END
.SAVE_FPU:
        ; ** 前回のFPUコンテキストを保存する
        mov ebx, edi
        call get_tss_base
        call save_fpu_context
.RESTORE_FPU:
        ; ** 今回のFPUコンテキストを復帰させる
        mov ebx, esi
        call get_tss_base
        call load_fpu_context
.SWITCH_FPU_END:
    
        sti

        mov [.last_tss], esi

;**** レジスタの復帰 **** 
        pop es
        pop ds
        popa

;**** スタックフレームの破棄 ****
        iret

ALIGN 4, db 0
.last_tss:
        dd 0

;********************************************************************************
; int get_tss_base()
;********************************************************************************
get_tss_base:
        mov eax, [GDT + ebx + 2]        ; TSSのベースアドレス[0..23]を取得する
        shl eax, 8                      ; 取得結果を退避
        mov eax, [GDT + ebx + 7]        ; TSSのベースアドレス[24..31]を取得する
        ror eax, 8                      ; 上位ビットに移動させる
        ret

;********************************************************************************
; void save_fpu_context()
;********************************************************************************
save_fpu_context:
        fnsave [eax + 104]
        mov [eax + 104 + 108], dword 1  ; 保存済みフラグ
        ret

;********************************************************************************
; void load_fpu_context()
;********************************************************************************
load_fpu_context:
        cmp [eax + 104 + 108], dword 0  ; FPUコンテキストが保存されているかどうか
        jne .FP_INIT_END
.FP_INIT_BEGIN:
        fninit                          ; FPUを初期化する
        jmp .END
.FP_INIT_END:
        frstor [eax + 104]              ; FPUコンテキストをロードする
.END:
        ret

