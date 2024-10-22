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

%macro set_vect 2-*.nolist
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

%if 3 == %0
    mov [edi + 4], %3
%endif

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

%macro set_desc 2-*.nolist
;********************************************************************************
; GDTにデスクリプタのアドレスを割り当てるためのマクロ
;********************************************************************************
    push eax
    push edi

    mov edi, %1
    mov eax, %2

%if 3 == %0 
    mov [edi + 0], %3   ; 第3引数が指定されていればリミットとして割り当てる
%endif
    
    mov [edi + 2], ax   ; ベースアドレスの0-15 bit
    shr eax, 16
    mov [edi + 4], al   ; ベースアドレスの16-23 bit
    mov [edi + 7], ah   ; ベースアドレスの24-31 bit

    pop edi
    pop eax
%endmacro

%macro set_call_gate_desc 2-*.nolist
;********************************************************************************
; GDTにコールゲートのアドレスを割り当てるためのマクロ
;********************************************************************************
    push eax
    push edi

    mov edi, %1
    mov eax, %2

    mov [edi + 0], ax
    shr eax, 16
    mov [edi + 6], ax

    pop edi
    pop eax
%endmacro

;********************************************************************************
; リングバッファ定義
;********************************************************************************
struc ring_buff
    .rp     resd 1                  ; 読み込み位置
    .wp     resd 1                  ; 書き込み位置
    .item   resb RING_ITEM_SIZE     ; バッファ本体
endstruc

;********************************************************************************
; バラ曲線パラメータ定義
;********************************************************************************
struc rose 
    .x0             resd 1          ; 左上(x)
    .y0             resd 1          ; 左上(y)
    .width          resd 1          ; 枠の幅
    .height         resd 1          ; 枠の高さ

    .n              resd 1            
    .d              resd 1

    .color_font     resd 1          ; 文字色    
    .color_axis_x   resd 1          ; X軸の表示色
    .color_axis_y   resd 1          ; Y軸の表示色
    .color_frame    resd 1          ; 枠線の色
    .color_curve_f  resd 1          ; カーブ表示色
    .color_curve_b  resd 1          ; カーブ消去色

    .title          resb 16         ; キャプション
endstruc


