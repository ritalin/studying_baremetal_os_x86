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

        cdecl SS_GATE_00:1, 53, 0, 0x07, .s0

;**** レジスタの復帰 **** 
        pop es
        pop ds
        popa

;**** スタックフレームの破棄 ****
        iret

ALIGN 4, db 0
.last_tss:
        dd 0
.s0:    db "FPU INT", 0

get_tss_base:


save_fpu_context:


load_fpu_context:
