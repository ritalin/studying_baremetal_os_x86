%macro cdecl 1-*.nolist
;********************************************************************************
; cdelc の呼出し規約で引数処理するためのマクロ
;********************************************************************************
    %rep %0 - 1
        push %{-1:-1}
        %rotate -1
    %endrep
    %rotate -1
        call %1
    %if 1 < %0
        add sp, (__BITS__ >> 3) * (%0 - 1)
    %endif    
%endmacro

%macro set_vect 1-*.nolist
;********************************************************************************
; 割り込みディスクリプタを割り当てるためのマクロ
;********************************************************************************
    push eax
    push edi

    mov edi, VECT_BASE + (%1 * 8)   ; ベクタアドレス
    mov eax, %2

    mov [edi + 0], ax               ; IDT[0] - 例外ハンドラのアドレス(下位ワード)
    shr eax, 16
    mov [edi + 6], ax               ; IDT[6 * 8] - 例外ハンドラのアドレス(上位ワード)

    pop edi
    pop eax
%endmacro

%macro outp 2.nolist
;********************************************************************************
; ポート出力依頼を簡易に行うためのマクロ
;********************************************************************************
    mov al, %2
    out %1, al
%endmacro

struc drive
    .no     resw 1  ; ドライブ番号
    .cyln   resw 1  ; シリンダー位置
    .head   resw 1  ; ヘッド位置
    .sect   resw 1  ; セクタ位置
endstruc

struc font
    .seg    resw 1  
    .off    resw 1
endstruc

struc mem_map_buf
    .addr   resw 4
    .len    resw 4
    .type   resw 2
    .acpi   resw 2
    .next   resw 2
endstruc