;********************************************************************************
; void call_gate()
;********************************************************************************
call_gate:
;**** スタックフレームの構築 **** 
                            ;    +24| 文字列
                            ;    +20| 表示色
                            ;    +16| 行
                            ;    +12| 列
                            ;     +8| CS (コードセグメント)                            
                            ;     +4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp
;**** レジスタの保存 **** 
        pusha
        push ds
        push es

;**** 処理の開始 ****
        ; ** セグメントレジスタの初期化
        mov ax, 0x0010
        mov ds, ax
        mov es, ax

        mov eax, dword [ebp + 12]
        mov ebx, dword [ebp + 16]
        mov ecx, dword [ebp + 20]
        mov edx, dword [ebp + 24]

        cdecl draw_str, eax, ebx, ecx, edx

;**** レジスタの復帰 **** 
        pop es
        pop ds
        popa
        
;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        retf 4 * 4
