;********************************************************************************
; void int_timer()
;********************************************************************************
int_timer:
;**** スタックフレームの構築 **** 
                            ;      0| EIP (caller)
;**** レジスタの保存 **** 
        pushad
        push ds
        push es

;**** 処理の開始 ****
        ; ** データセグメントの設定
        mov ax, 0x0010
        mov ds, ax
        mov es, ax

        inc dword [TIMER_COUNT]

        ; ** 割り込みフラグをクリアする
        outp 0x20, 0x20

        ; ** タスク切り替え
        str ax
.TASK_SWICTH_BEGIN:
        cmp ax, SS_TASK_01
        je .TASK_01

        cmp ax, SS_TASK_02
        je .TASK_02
        cmp ax, SS_TASK_03
        je .TASK_03
        cmp ax, SS_TASK_04
        je .TASK_04
        
.TASK_00:
        jmp SS_TASK_01:0
        jmp .TASK_SWICTH_END
.TASK_01:
        jmp SS_TASK_02:0
        jmp .TASK_SWICTH_END
.TASK_02:
        jmp SS_TASK_03:0
        jmp .TASK_SWICTH_END
.TASK_03:
        jmp SS_TASK_04:0
        jmp .TASK_SWICTH_END
.TASK_04:
        jmp SS_TASK_00:0
.TASK_SWICTH_END:

;**** レジスタの復帰 **** 
        pop es
        pop ds
        popad

;**** スタックフレームの破棄 ****
        iret

;********************************************************************************
; void enable_int_timer0
;********************************************************************************
enable_int_timer0:
;**** スタックフレームの構築 **** 
                            ;     +4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp

;**** レジスタの保存 **** 
        push eax

;**** 処理の開始 ****
        outp 0x43, 0b_00_11_010_0   ; 設定値を送る

        outp 0x40, 0x9C             ; 割り込み発生周波数を書き込む(下位バイト)
        outp 0x40, 0x2E             ; 割り込み発生周波数を書き込む(上位バイト)

;**** レジスタの復帰 **** 
        pop eax

;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        ret

ALIGN 4, db 0
TIMER_COUNT:
        dq 0
