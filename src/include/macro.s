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

struc drive
    .no     resw 1  ; ドライブ番号
    .cyln   resw 1  ; シリンダー位置
    .head   resw 1  ; ヘッド位置
    .sect   resw 1  ; セクタ位置
endstruc
