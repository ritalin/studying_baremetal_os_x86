ROOT_DIR_SECT equ (40 + 256 + 256)

;********************************************************************************
; void read_sample_file()
;********************************************************************************
[BITS 16]
read_sample_file:
;**** スタックフレームの構築 **** 
                            ;    +2| IP (caller)
        push bp             ; BP  0| BP (old)
        mov bp, sp

;**** レジスタの保存 **** 
        push bx
        push cx

;**** 処理の開始 ****
        ; ** ルートディレクトリのセクタを読み込む **
        mov bx, 40 + 256 + 256                      ; boot+kernel(40セクタ), FAT1(256セクタ), FAT2(256セクタ)
        mov cx, (512 * 32) / 512                    ; ルートディレクトリのセクタ数(512エントリ * 32Byte / 512Byte)

.READ_DIR_LOOP:
        ; ** 1セクタ( = 16エントリ = 512Byte)を読み込む **
        cdecl read_lba, BOOT, bx, 1, .FAT_ENTRY
        cmp ax, 0
        je .DIR_NOT_FOUND

        ; ** ディレクトリエントリからファイル名を検索 **
        cdecl find_fat_file, .FAT_ENTRY
        cmp ax, 0
        je .READ_FILE_END

.READ_FILE_BEGIN:
        ; ** ファイル内容を読み込む **
        add ax, ROOT_DIR_SECT + 32 - 2              ; セクタ位置にオフセットを負わせる
        cdecl read_lba, BOOT, ax, 1, SEARCH_RESULT
        jmp .SEARCH_END   

.READ_FILE_END:
        inc bx
        loop .READ_DIR_LOOP

.FILE_NOT_FOUND:
        cdecl memcpy16, SEARCH_RESULT, .s0, .s1 - .s0  
        jmp .SEARCH_END
.DIR_NOT_FOUND:
        cdecl memcpy16, SEARCH_RESULT, .s2, .s3 - .s2  

.SEARCH_END:

;**** レジスタの復帰 **** 
        pop cx
        pop bx

;**** スタックフレームの破棄 ****
        mov sp, bp
        pop bp
        ret

.s0:    db "File not found...               ", 0    ; 最大32文字の文字列バッファ
.s1:
.s2:    db "Directory not found !           ", 0    ; 最大32文字の文字列バッファ
.s3:
.s4:    db "File found !                    ", 0    ; 最大32文字の文字列バッファ
.s5:

.FAT_ENTRY:
        times 512 db 0

;********************************************************************************
; int find_fat_file(buf)
;********************************************************************************
find_fat_file:
;**** スタックフレームの構築 **** 
                            ; R(ax)| 合致するファイルの先頭セクタ
                            ;    +4| ファイルエントリ配列へのポインタ
                            ;    +2| IP (caller)
        push bp             ; BP  0| BP (old)
        mov bp, sp

;**** レジスタの保存 **** 
        push bx
        push cx
        push si

;**** 処理の開始 ****
        ; ** ファイル名を検索する **
        cld                             ; DF = 0
        xor bx, bx                      ; 先頭セクタの初期値
        mov cx, 512 / 32                ; ルートディレクトリエントリ数
        mov si, [bp + 4]

.FIND_FILE_LOOP:
        and [si + 11], byte 0001_1000b   
        jnz .FIND_FILE_NEXT             ; ファイルではない場合はスキップ

        cdecl memcmp, si, .s0, 11       ; ファイル名チェック(11文字)
        cmp ax, 0
        jne .FIND_FILE_NEXT

        mov bx, word [si + 0x1A]        ; ファイルの先頭セクタ
        jmp .FIND_FILE_END

.FIND_FILE_NEXT:
        add si, 32                      ; 次のエントリへ進める
        loop .FIND_FILE_LOOP
.FIND_FILE_END:

        mov ax, bx

;**** レジスタの復帰 **** 
        pop si
        pop cx
        pop bx

;**** スタックフレームの破棄 ****
        mov sp, bp
        pop bp
        ret

.s0:    db "SPECIAL TXT", 0

