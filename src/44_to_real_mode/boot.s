;********************************************************************************
; ブートローダ
;********************************************************************************
%include "include/define.s"

ORG BOOT_LOAD

entry:
;********************************************************************************
; BPB
;********************************************************************************
        jmp ipl                             ; 0x00 ( 3) | ブートコードへのジャンプ命令
        times 3 - ($-$$) db 0x90 ; nop      
        db  "OEM-NAME"                      ; 0x03 ( 8) | OEM名
                                            ; ----------+----------------------------
        dw 512                              ; 0x0B ( 2) | 1セクタのバイト数
        db 1                                ; 0x0D ( 1) | 1クラスタのセクタ数
        dw 40                               ; 0x0E ( 2) | 予約セクタ数 / boot(4kB)+kernel(12kB) 
        db 2                                ; 0x10 ( 1) | FAT数
        dw 512                              ; 0x11 ( 2) | ルートエントリ数 (推奨値)
        dw 0xFF0                            ; 0x13 ( 2) | 総セクタ数16
        db 0xF8                             ; 0x15 ( 2) | メディアタイプ (HDD)
        dw 256                              ; 0x17 ( 2) | FATのセクタ数
        dw 0x10                             ; 0x19 ( 2) | トラックのセクタ数 (src_42の実行時の値)
        dw 1                                ; 0x1A ( 2) | ヘッド数 (src_42の実行時の値)
        dd 0                                ; 0x1C ( 4) | 隠されたセクタ数
                                            ; ----------+----------------------------
        dd 0                                ; 0x20 ( 4) | 総セクタ数32
        db 0x80                             ; 0x24 ( 1) | ドライブ番号(HDD)
        db 0                                ; 0x25 ( 1) | (Reserved)
        db 0x29                             ; 0x26 ( 1) | ブートフラグ
        dd 0xbeef                           ; 0x27 ( 4) | シリアルナンバー (時刻等の任意の値)
        db 'BOOTABLE   '                    ; 0x2B (11) | ボリュームラベル (任意の文字列)
        db 'FAT16   '                       ; 0x36 ( 8) | FATタイプ


%include "include/macro.s"

;********************************************************************************
; Initial Program Loader
;********************************************************************************
ipl:
        cli
        xor ax, ax
        mov ds, ax
        mov es, ax
        mov ss, ax
        mov sp, BOOT_LOAD
        sti

        mov [BOOT + drive.no], dl

        cdecl puts, .s0

        ; ** 第2ステージのロード **
        mov bx, BOOT_SECT-1             ; 読み込むセクタ数
        mov cx, BOOT_LOAD + SECT_SIZE   ; 展開先アドレス
        cdecl read_chs, BOOT, bx, cx

        cmp ax, bx                      ; 指定したセクタ数を読み込んだかどうか
        jz .LOAD_2ND_STAGE_SUCCESS   

        cdecl puts, .err0
        cdecl reboot            ; 再起動
.LOAD_2ND_STAGE_SUCCESS:
        jmp stage2

.s0:    db "Booting...", 0x0A, 0x0D, 0   
.err0:  db "ERROR: Sector Read", 0x0A, 0x0D, 0   

ALIGN 2, db 0
BOOT:
        istruc drive      
            at drive.no,   dw 0
            at drive.cyln, dw 0
            at drive.head, dw 0
            at drive.sect, dw 2
        iend

%include "modules/real/puts.s"
%include "modules/real/reboot.s"
%include "modules/real/read_chs.s"

;********************************************************************************
; ブートフラグ
;********************************************************************************
        times 510 - ($-$$) db 0x00
        db 0x55, 0xAA

;********************************************************************************
; フォント情報の格納先
;********************************************************************************
FONT:
        istruc font
            at font.seg, dw 0
            at font.off, dw 0
        iend

%include "modules/real/itoa.s"
%include "modules/real/get_drive_param.s"

;********************************************************************************
; Stage2
;********************************************************************************
stage2:
        cdecl puts, .s0

        ; ** ドライブ情報を取得する
        cdecl get_drive_param, BOOT
        cmp ax, 0
        jne .BOOT_PARAM_FOUND
        cdecl puts, .err0
        cdecl reboot            ; 再起動
.BOOT_PARAM_FOUND:
        
        ; ** ドライブパラメータの表示
        mov ax, [BOOT + drive.no]
        cdecl itoa, ax, .p1, 2, 16, 0b0010
        mov ax, [BOOT + drive.cyln]
        cdecl itoa, ax, .p2, 4, 16, 0b0010
        mov ax, [BOOT + drive.head]
        cdecl itoa, ax, .p3, 3, 10, 0b0010
        mov ax, [BOOT + drive.sect]
        cdecl itoa, ax, .p4, 3, 10, 0b0010        
        cdecl puts, .s1

        jmp stage_3

.s0:    db "2nd Stage...", 0x0A, 0x0D, 0 

.s1:    db "  Drive:0x"
.p1:    db "  , C:0x"
.p2:    db "   , H:"
.p3:    db "   , S:"
.p4:    db "   "
.p5:    db 0x0A, 0x0D, 0

.err0:  db "Cannot get drive parameter.", 0x0A, 0x0D, 0

%include "modules/real/get_font_address.s"

;********************************************************************************
; Stage3
;********************************************************************************
stage_3:
        cdecl puts, .s0

        cdecl get_font_address, FONT

        mov ax, [FONT + font.seg]
        cdecl itoa, ax, .p1, 4, 16, 0b0010
        mov ax, [FONT + font.off]
        cdecl itoa, ax, .p2, 4, 16, 0b0010 
        cdecl puts, .s1
        jmp stage_4

.s0:    db "3rd stage...", 0x0A, 0x0D, 0
.s1:    db "  Font address="
.p1:    db "ZZZZ:"
.p2:    db "ZZZZ"
.p3:    db 0x0A, 0x0D, 0

%include "modules/real/kbc.s"

;********************************************************************************
; Stage4
;********************************************************************************
stage_4:
        cdecl puts, .s0

        ; ** A20ゲートの有効化
        cli                         ; 割り込み禁止
        cdecl write_kbc_cmd, 0xAD   ; キーボード無効化

        cdecl write_kbc_cmd, 0xD0   ; 読み出し依頼
        cdecl read_kbc_data, .key    ; データ読み出し

        mov bl, [.key]
        or bl, 0x02                 ; A20ゲートの有効化

        cdecl write_kbc_cmd, 0xD1   ; 書き込み依頼
        cdecl write_kbc_data, bx    ; データ書き込み

        cdecl write_kbc_cmd, 0xAE   ; キーボード有効化
        cdecl wait_write_kbc
        sti                         ; 割り込み許可

        cdecl puts, .s1     
        jmp stage_5

.s0:    db "4th stage...", 0x0A, 0x0D, 0
.s1:    db "A20 Gate Enabled.", 0x0A, 0x0D, 0
.key:   dw 0

%include "modules/real/read_lba.s"
;********************************************************************************
; Stage5
;********************************************************************************
stage_5:
        cdecl puts, .s0

        ; ** LBA -> CHS変換 **
        cdecl read_lba, BOOT, BOOT_SECT, KERNEL_SECT, BOOT_END

        cmp ax, KERNEL_SECT
        jz .LOAD_SUCCESS
.LOAD_FAILED:
        cdecl puts, .err0
        cdecl reboot
.LOAD_SUCCESS:
        cdecl puts, .s1
        jmp stage_6

.s0:    db "5th stage...", 0x0A, 0x0D, 0
.s1:    db "Success load kernel !", 0x0A, 0x0D, 0
.err0:  db "Failure load kernel...", 0x0A, 0x0D, 0

;********************************************************************************
; Stage6
;********************************************************************************
stage_6:
        cdecl puts, .s0
        cdecl puts, .s1
        
        ; 入力待ち
.LOOP:
        mov ah, 0x00
        int 0x16
        cmp al, ' '
        jnz .LOOP

        cdecl puts, .s2

        mov ax, 0x0012      ; VGA 640 x 480
        int 0x10

        jmp stage_7

.s0:    db "6th stage...", 0x0A, 0x0D, 0x0A, 0x0D, 0
.s1:    db "[Push SPACE Key to protect mode...]", 0x0A, 0x0D, 0
.s2:    db "Configure video mode...", 0x0A, 0x0D, 0
    
;********************************************************************************
; Global Descripter Table
;********************************************************************************
ALIGN 4, db 0
GDT:    dq 00_0_0_0_0_000000_0000h  ; NULL
.cs:    dq 00_C_F_9_A_000000_FFFFh  ; CODE(4GB)
.ds:    dq 00_C_F_9_2_000000_FFFFh  ; DATA(4GB) 
.gdt_end:

GDTR:   dw GDT.gdt_end - GDT     ; ディスクリプタデーブルのリミット
        dd GDT                      ; ディスクリプタテーブルのアドレス
   
;********************************************************************************
; Interrupt Descripter Table (初期値は擬似的に割り込み禁止にする)
;********************************************************************************
IDTR:   dw 0                        ; ディスクリプタデーブルのリミット
        dd 0                        ; ディスクリプタテーブルのアドレス

;********************************************************************************
; Selecter (セグメントディスクリプタからのオフセット)
;********************************************************************************
SEL_CODE equ (GDT.cs - GDT)            ; コード用セレクタ (8Byte)
SEL_DATA equ (GDT.ds - GDT)            ; データ用セレクタ (8Byte)

;********************************************************************************
; Stage7
;********************************************************************************
stage_7:
        cli

        ; ** GDTをロードする **
        lgdt [GDTR]
        lidt [IDTR]
        
        ; ** プロテクトモードへの移行 **
        mov eax, cr0
        or ax, 1
        mov cr0, eax

        jmp $ + 2                       ; 先読みをクリアする
     
[BITS 32]
        db 0x66
        jmp SEL_CODE:CODE_32            ; ** セグメト間ジャンプ

;********************************************************************************
; 32 Bitコードの開始
;********************************************************************************
CODE_32:
        ; ** セレクタを初期化する **
        mov ax, SEL_DATA
        mov ds, ax
        mov es, ax
        mov fs, ax
        mov gs, ax
        mov ss, ax

        ; ** カーネル部をコピーする **
        mov ecx, (KERNEL_SIZE) / 4      ; 4Byte単位でコピー
        mov esi, BOOT_END
        mov edi, KERNEL_LOAD
        cld                             ; DF = 0
    rep movsd                           ; while (--ECX) { *EDI++ = *ESI++; }
        ; ** カーネル処理に移行する
        jmp KERNEL_LOAD

;********************************************************************************
; リアルモードげ移行する
;********************************************************************************
to_real_mode:
;**** スタックフレームの構築 **** 
                            ;     +4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp

;**** レジスタの保存 **** 

;**** 処理の開始 ****

;**** レジスタの復帰 **** 

;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        ret

;********************************************************************************
; リアルモードげ移行関数へのポインタ
;********************************************************************************
        times BOOT_SIZE - ($-$$) -16 db 0x00    ; 終端の16byte前にto_real_modeの参照先を置く
        dd to_real_mode

;********************************************************************************
; パディング(8kB)
;********************************************************************************
        times BOOT_SIZE - ($-$$) db 0x00    

