;********************************************************************************
; Task State Segments
;********************************************************************************
TSS_00:                                 ; カーネル用タスク
.link:      dd 0
.esp0:      dd SP_TASK_00 - 512         ; カーネルなのでリング0
.ss0:       dd DS_KERNEL
.esp1:      dd 0
.ss1:       dd 0
.esp2:      dd 0
.ss2:       dd 0
.cr3:       dd 0
.eip:       dd 0
.eflags:    dd 0
.eax:       dd 0
.ecx:       dd 0
.edx:       dd 0
.ebx:       dd 0
.esp:       dd 0
.ebp:       dd 0
.esi:       dd 0
.edi:       dd 0
.es:        dd 0
.cs:        dd 0
.ss:        dd 0
.ds:        dd 0
.fs:        dd 0
.gs:        dd 0
.ldt:       dd 0
.io:        dd 0
.fp_save:   times 108 + 4 dd 0          ; FPUコンテキスト保存領域

TSS_01:                                 ; テストタスク
.link:      dd 0
.esp0:      dd SP_TASK_01 - 512         ; リング0
.ss0:       dd DS_KERNEL
.esp1:      dd 0
.ss1:       dd 0
.esp2:      dd 0
.ss2:       dd 0
.cr3:       dd 0
.eip:       dd task_01                  ; "tasks/task_01.s"
.eflags:    dd 0x_02_02
.eax:       dd 0
.ecx:       dd 0
.edx:       dd 0
.ebx:       dd 0
.esp:       dd SP_TASK_01
.ebp:       dd 0
.esi:       dd 0
.edi:       dd 0
.es:        dd DS_TASK_01
.cs:        dd CS_TASK_01
.ss:        dd DS_TASK_01
.ds:        dd DS_TASK_01
.fs:        dd DS_TASK_01
.gs:        dd DS_TASK_01
.ldt:       dd SS_LDT
.io:        dd 0
.fp_save:   times 108 + 4 dd 0          ; FPUコンテキスト保存領域


TSS_02:                                 ; テストタスク2
.link:      dd 0
.esp0:      dd SP_TASK_02 - 512         ; リング0
.ss0:       dd DS_KERNEL
.esp1:      dd 0
.ss1:       dd 0
.esp2:      dd 0
.ss2:       dd 0
.cr3:       dd 0
.eip:       dd task_02                  ; "tasks/task_01.s"
.eflags:    dd 0x_02_02
.eax:       dd 0
.ecx:       dd 0
.edx:       dd 0
.ebx:       dd 0
.esp:       dd SP_TASK_02
.ebp:       dd 0
.esi:       dd 0
.edi:       dd 0
.es:        dd DS_TASK_02
.cs:        dd CS_TASK_02
.ss:        dd DS_TASK_02
.ds:        dd DS_TASK_02
.fs:        dd DS_TASK_02
.gs:        dd DS_TASK_02
.ldt:       dd SS_LDT
.io:        dd 0
.fp_save:   times 108 + 4 dd 0          ; FPUコンテキスト保存領域

TSS_03:                                 ; テストタスク3
.link:      dd 0
.esp0:      dd SP_TASK_03 - 512         ; リング0
.ss0:       dd DS_KERNEL
.esp1:      dd 0
.ss1:       dd 0
.esp2:      dd 0
.ss2:       dd 0
.cr3:       dd 0
.eip:       dd task_03                  ; "tasks/task_01.s"
.eflags:    dd 0x_02_02
.eax:       dd 0
.ecx:       dd 0
.edx:       dd 0
.ebx:       dd 0
.esp:       dd SP_TASK_03
.ebp:       dd 0
.esi:       dd 0
.edi:       dd 0
.es:        dd DS_TASK_03
.cs:        dd CS_TASK_03
.ss:        dd DS_TASK_03
.ds:        dd DS_TASK_03
.fs:        dd DS_TASK_03
.gs:        dd DS_TASK_03
.ldt:       dd SS_LDT
.io:        dd 0
.fp_save:   times 108 + 4 dd 0          ; FPUコンテキスト保存領域

;********************************************************************************
; グローバルデスクリプタ
;********************************************************************************
GDT:        dq 00_0_0_0_0_00_0000_00_00h    ; NULL
.cs_kernel: dq 00_C_F_9_A_00_0000_FF_FFh    ; CODE(4GB)
.ds_kernel: dq 00_C_F_9_2_00_0000_FF_FFh    ; DATA(4GB) 
.ldt:       dq 00_0_0_8_2_00_0000_00_00h    ; 
.tss_00:    dq 00_0_0_8_9_00_0000_00_67h    ; カーネルタスク用(リミットはTSSの最小サイズ)
.tss_01:    dq 00_0_0_8_9_00_0000_00_67h    ; タスク1(リミットはTSSの最小サイズ)
.tss_02:    dq 00_0_0_8_9_00_0000_00_67h    ; タスク2(リミットはTSSの最小サイズ)
.tss_03:    dq 00_0_0_8_9_00_0000_00_67h    ; タスク3(リミットはTSSの最小サイズ)
.call_gate: dq 00_0_0_E_C_04_0008_00_00h    ; コールゲート(draw_str, 引数=4, DPL=3, SEL=8)
.gdt_end:

GDTR:       dw GDT.gdt_end - GDT        ; ディスクリプタデーブルのリミット
            dd GDT                      ; ディスクリプタテーブルのアドレス

DS_KERNEL   equ GDT.ds_kernel - GDT     ; カーネルデータセグメントのオフセット
SS_LDT      equ GDT.ldt - GDT           ; LDTデスクリプタのオフセット
SS_TASK_00  equ GDT.tss_00 - GDT        ; カーネルタスクのオフセット
SS_TASK_01  equ GDT.tss_01 - GDT        ; タスク1のオフセット
SS_TASK_02  equ GDT.tss_02 - GDT        ; タスク2のオフセット
SS_GATE_00  equ GDT.call_gate - GDT     ; コールゲートへのオフセット

;********************************************************************************
; ローカルデスクリプタ
;********************************************************************************
LDT:        dq 00_0_0_0_0_000000_0000h  ; NULL
.cs_taks_00:dq 00_C_F_9_A_000000_FFFFh  ; カーネルタスク用のため領域はGDTと共有
.ds_taks_00:dq 00_C_F_9_2_000000_FFFFh  ; カーネルタスク用のため領域はGDTと共有
.cs_taks_01:dq 00_C_F_F_A_000000_FFFFh  ; タスク1用(CODE)
.ds_taks_01:dq 00_C_F_F_2_000000_FFFFh  ; タスク1用(DATA)
.cs_taks_02:dq 00_C_F_F_A_000000_FFFFh  ; タスク2用(CODE)
.ds_taks_02:dq 00_C_F_F_2_000000_FFFFh  ; タスク2用(DATA)
.cs_taks_03:dq 00_C_F_F_A_000000_FFFFh  ; タスク2用(CODE)
.ds_taks_03:dq 00_C_F_F_2_000000_FFFFh  ; タスク2用(DATA)
.ldt_end:

LDT_LIMIT   equ LDT.ldt_end - LDT
CS_TASK_01  equ (LDT.cs_taks_01 - LDT) | 4 | 3
DS_TASK_01  equ (LDT.ds_taks_01 - LDT) | 4 | 3
CS_TASK_02  equ (LDT.cs_taks_02 - LDT) | 4 | 3
DS_TASK_02  equ (LDT.ds_taks_02 - LDT) | 4 | 3
CS_TASK_03  equ (LDT.cs_taks_02 - LDT) | 4 | 3
DS_TASK_03  equ (LDT.ds_taks_02 - LDT) | 4 | 3
