;********************************************************************************
; void get_mem_info(var info_buf)
;********************************************************************************
get_mem_info:
;**** スタックフレームの構築 **** 
                            ;    +4| メモリ情報バッファへのポインタ
                            ;    +2| IP (caller)
        push bp             ; BP  0| BP (old)
        mov bp, sp

;**** レジスタの保存 **** 
        push eax
        push ebx
        push ecx
        push edx
        push si
        push di
        push bp

;**** 処理の開始 ****
        mov di, [bp + 4]
        mov bp, 0
        mov eax, 0x0000_E820
        mov ebx, dword [di + mem_map_buf.next]
        mov ecx, MEMORY_MAP_LEN
        mov edx, 'PAMS'
        int 0x15

        cmp eax, edx
        jne .END 
        jc .END

        mov [di + mem_map_buf.next], dword ebx
.END

;**** レジスタの復帰 **** 
        pop bp
        pop di
        pop si
        pop edx
        pop ecx
        pop ebx
        pop eax

;**** スタックフレームの破棄 ****
        mov sp, bp
        pop bp
        ret

;********************************************************************************
; void put_mem_info_header()
;********************************************************************************
put_mem_info_header:
;**** スタックフレームの構築 **** 
                            ;    +2| IP (caller)
        push bp             ; BP  0| BP (old)
        mov bp, sp

;**** レジスタの保存 **** 
   
;**** 処理の開始 ****
        cdecl puts, .s1
        
;**** レジスタの復帰 **** 

;**** スタックフレームの破棄 ****
        mov sp, bp
        pop bp
        ret

.s1:    db "Base____", "_", "________", " "
.s2:    db "Length__", "_", "________", " "
.s3:    db "Type____", " "
.s4:    db 0x0A, 0x0D, 0

;********************************************************************************
; void put_mem_info(info_buf)
;********************************************************************************
put_mem_info:
;**** スタックフレームの構築 **** 
                            ;    +4| メモリ情報バッファへのポインタ
                            ;    +2| IP (caller)
        push bp             ; BP  0| BP (old)
        mov bp, sp

;**** レジスタの保存 **** 
        push si
   
;**** 処理の開始 ****
        mov si, [bp + 4]

        ; ** 開始アドレス **
        cdecl itoa, word [si + mem_map_buf.addr + 6], .s1 + 0, 4, 16, 0b0010
        cdecl itoa, word [si + mem_map_buf.addr + 4], .s1 + 4, 4, 16, 0b0010
        cdecl itoa, word [si + mem_map_buf.addr + 2], .s2 + 0, 4, 16, 0b0010
        cdecl itoa, word [si + mem_map_buf.addr + 0], .s2 + 4, 4, 16, 0b0010

        ; ** 長さ **
        cdecl itoa, word [si + mem_map_buf.len + 6], .s3 + 0, 4, 16, 0b0010
        cdecl itoa, word [si + mem_map_buf.len + 4], .s3 + 4, 4, 16, 0b0010
        cdecl itoa, word [si + mem_map_buf.len + 2], .s4 + 0, 4, 16, 0b0010
        cdecl itoa, word [si + mem_map_buf.len + 0], .s4 + 4, 4, 16, 0b0010

        ; ** タイプ **
        cdecl itoa, word [si + mem_map_buf.type + 2], .s5 + 0, 4, 16, 0b0010
        cdecl itoa, word [si + mem_map_buf.type + 0], .s5 + 4, 4, 16, 0b0010

        cdecl puts, .s1
        
;**** レジスタの復帰 **** 
        pop si

;**** スタックフレームの破棄 ****
        mov sp, bp
        pop bp
        ret

.s1:    db "ZZZZZZZZ", "_"
.s2:    db "ZZZZZZZZ", " "
.s3:    db "ZZZZZZZZ", "_"
.s4:    db "ZZZZZZZZ", " "
.s5:    db "ZZZZZZZZ", " "
.s6:    db 0x0A, 0x0D, 0

;********************************************************************************
; void put_mem_info_footer()
;********************************************************************************
put_mem_info_footer:
;**** スタックフレームの構築 **** 
                            ;    +2| IP (caller)
        push bp             ; BP  0| BP (old)
        mov bp, sp

;**** レジスタの保存 **** 

;**** 処理の開始 ****
        cdecl puts, .s1
        
;**** レジスタの復帰 **** 

;**** スタックフレームの破棄 ****
        mov sp, bp
        pop bp
        ret

.s1:    db "________", "_", "________", " "
.s2:    db "________", "_", "________", " "
.s3:    db "________", " "
.s4:    db 0x0A, 0x0D, 0
