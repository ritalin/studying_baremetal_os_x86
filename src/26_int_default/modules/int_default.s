;********************************************************************************
; void int_default()
;********************************************************************************
int_default:
;**** スタックフレームの構築 **** 
                            ;    +12| 呼び出し元から渡されたダミー
                            ;     +8| EFLAGS
                            ;     +4| CS (caller - セグメント間ジャンプとして)
                            ;     +0| EIP (caller)
        pushf               ;     -4| EFLAGSの保存
        push cs             ;     -8| CSの保存
        push int_stop       ;    -12| EIP (スタック表示処理)

        mov eax, .s0
        iret

.s0:    db " <    STOP    > ", 0

;********************************************************************************
; void int_stop()
;********************************************************************************
int_stop:
        ; ** EAXで示される文字列の表示
        cdecl draw_str, 25, 15, 0x060F, eax

        ; ** スタックのデータを文字列に変換する
        mov eax, [esp + 0]
        cdecl itoa, eax, .p1, 8, 16, 0b0010

        mov eax, [esp + 4]
        cdecl itoa, eax, .p2, 8, 16, 0b0010

        mov eax, [esp + 8]
        cdecl itoa, eax, .p3, 8, 16, 0b0010

        mov eax, [esp + 12]
        cdecl itoa, eax, .p4, 8, 16, 0b0010

        ; ** 表示
        cdecl draw_str, 25, 16, 0x0F04, .s1
        cdecl draw_str, 25, 17, 0x0F04, .s2
        cdecl draw_str, 25, 18, 0x0F04, .s3
        cdecl draw_str, 25, 19, 0x0F04, .s4

        jmp $

.s1:    db "ESP+ 0:"
.p1:    db "________", " ", 0
.s2:    db "ESP+ 4:"
.p2:    db "________", " ", 0
.s3:    db "ESP+ 8:"
.p3:    db "________", " ", 0
.s4:    db "ESP+12:"
.p4:    db "________", " ", 0
