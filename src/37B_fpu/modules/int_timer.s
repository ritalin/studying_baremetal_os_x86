;************************************************************************
;	—áŠO:ƒ^ƒCƒ}[
;************************************************************************
int_timer:
		;---------------------------------------
		; yƒŒƒWƒXƒ^‚Ì•Û‘¶z
		;---------------------------------------
		pusha
		push	ds
		push	es

		;---------------------------------------
		; ƒf[ƒ^—pƒZƒOƒƒ“ƒg‚ÌÝ’è
		;---------------------------------------
		mov		ax, 0x0010						; 
		mov		ds, ax							; 
		mov		es, ax							; 

		;---------------------------------------
		; TICK
		;---------------------------------------
		inc		dword [TIMER_COUNT]				; TIMER_COUNT++; // Š„‚èž‚Ý‰ñ”‚ÌXV

		;---------------------------------------
		; Š„‚èž‚Ýƒtƒ‰ƒO‚ðƒNƒŠƒA(EOI)
		;---------------------------------------
		outp	0x20, 0x20						; // ƒ}ƒXƒ^PIC:EOIƒRƒ}ƒ“ƒh

		;---------------------------------------
		; ƒ^ƒXƒN‚ÌØ‚è‘Ö‚¦
		;---------------------------------------
		str		ax								; AX = TR; // Œ»Ý‚Ìƒ^ƒXƒNƒŒƒWƒXƒ^
		cmp		ax, SS_TASK_0					; case (AX)
		je		.11L							; {
		cmp		ax, SS_TASK_1					;   
		je		.12L							;   
												;   default:
		jmp		SS_TASK_0:0						;     // ƒ^ƒXƒN0‚ÉØ‚è‘Ö‚¦
		jmp		.10E							;     break;
												;     
.11L:											;   case SS_TASK_0:
		jmp		SS_TASK_1:0						;     // ƒ^ƒXƒN1‚ÉØ‚è‘Ö‚¦
		jmp		.10E							;     break;
												;     
.12L:											;   case SS_TASK_1:
		jmp		SS_TASK_2:0						;     // ƒ^ƒXƒN2‚ÉØ‚è‘Ö‚¦
		jmp		.10E							;     break;
.10E:											; }

		;---------------------------------------
		; yƒŒƒWƒXƒ^‚Ì•œ‹Az
		;---------------------------------------
		pop		es								; 
		pop		ds								; 
		popa

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
TIMER_COUNT:	dd	0

