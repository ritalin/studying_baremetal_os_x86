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
        ; ** 1セクタ( = 16エントリ)を読み込む **
        cdecl read_lba, BOOT, bx, 1, .FAT_ENTRY
        cmp ax, 0
        je .DIR_NOT_FOUND

        ; ** ディレクトリエントリからファイル名を検索 **
        cdecl find_fat_file, .FAT_ENTRY
        cmp ax, 0
        je .READ_FILE_END

.READ_FILE_BEGIN:
        ; ** ファイル内容を読み込む **
        cdecl memcpy16, SEARCH_RESULT, .s4, .s5 - .s4  
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
                            ; R(ax)| 合致するファイルエントリのインデックス
                            ;    +4| ファイルエントリ配列へのポインタ
                            ;    +2| IP (caller)
        push bp             ; BP  0| BP (old)
        mov bp, sp

;**** レジスタの保存 **** 

;**** 処理の開始 ****
        mov ax, 0

;**** レジスタの復帰 **** 

;**** スタックフレームの破棄 ****
        mov sp, bp
        pop bp
        ret


