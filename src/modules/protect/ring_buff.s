;********************************************************************************
; int read_ring_buff(buff, out data)
;********************************************************************************
read_ring_buff:
;**** スタックフレームの構築 **** 
                            ;    +12| 読み込んだデータの格納先アドレス
                            ;     +8| リングバッファへのポインタ
                            ;     +4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp

;**** レジスタの保存 **** 

;**** 処理の開始 ****
        mov eax, 1

;**** レジスタの復帰 **** 

;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        ret

;********************************************************************************
; int write_ring_buff(buff, data)
;********************************************************************************
write_ring_buff:
;**** スタックフレームの構築 **** 
                            ;    +12| 書き込むデータ
                            ;     +8| リングバッファへのポインタ
                            ;     +4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp

;**** レジスタの保存 **** 
        push ebx
        push ecx
        push esi

;**** 処理の開始 ****
        mov eax, 0                              ; 戻り値(失敗)
        mov esi, [ebp + 8]
        mov ebx, [esi + ring_buff.wp]
        mov ecx, ebx
        inc ecx                         
        and ecx, RING_INDEX_MASK                ; 次の書き込み位置

        cmp ecx, [esi + ring_buff.rp]
        je .END

        mov al, [ebp + 12]                      ; 書き込むデータ
        mov [esi + ring_buff.item + ebx], al
        mov [esi + ring_buff.wp], ecx           ; 書き込み位置を更新する
        mov eax, 1                              ; 戻り値(成功)
.END

;**** レジスタの復帰 **** 
        pop esi
        pop ecx
        pop ebx
        
;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        ret

;********************************************************************************
; void draw_key(col, row, buff)
;********************************************************************************
draw_key:
;**** スタックフレームの構築 **** 
                            ;    +16| リングバッファへのポインタ
                            ;    +12| 表示行
                            ;     +8| 表示列
                            ;     +4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp

;**** レジスタの保存 **** 
        push eax
        push ebx
        push ecx
        push edx
        push esi
        push edi

;**** 処理の開始 ****
        mov edx, [ebp + 8]
        mov edi, [ebp + 12]

        mov esi, [ebp + 16]
        mov ebx, [esi + ring_buff.rp]
        lea esi, [esi + ring_buff.item]

        mov ecx, RING_ITEM_SIZE
.LOOP:
        and ebx, RING_INDEX_MASK
        mov al, [esi + ebx]
        cmp al, 0
        jz .DRAW_EMPTY_BEGIN
        cdecl itoa, eax, .s0, 2, 16, 0b0000
        cdecl draw_str, edx, edi, 0x02, .s0
        jmp .DRAW_END
.DRAW_EMPTY_BEGIN:
        cdecl draw_str, edx, edi, 0x02, .s1
.DRAW_END:
        add edx, 3
        inc ebx
        loop .LOOP
.END:

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

.s0:    db "__ ", 0
.s1:    db "   ", 0
