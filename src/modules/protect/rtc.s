;********************************************************************************
; int get_rtc_time(out time)
;********************************************************************************
get_rtc_time:
;**** スタックフレームの構築 **** 
                            ;     +8| 取得した時刻の展開先
                            ;     +4| EIP (caller)
        push ebp            ; EBP  0| EBP (old)
        mov ebp, esp

;**** レジスタの保存 **** 
        push ebx

;**** 処理の開始 ****
        mov al, 0x0A
        out 0x70, al        ; RTCのレジスタAへのアクセスを指示
        in al, 0x71
        test al, 0x80       ; RTCが更新中かどうか
        je .RTC_TIME_BEGIN
        mov eax, 1
        jmp .END
.RTC_TIME_BEGIN:
        mov al, 0x04
        out 0x70, al        ; RTC RAMの読み取り先を指示 (Hour)
        in al, 0x71         ; 時刻パートを読み込む

        shl eax, 8          ; AHに読み込んだ時刻パートを退避

        mov al, 0x02
        out 0x70, al            ; RTC RAMの読み取り先を指示 (Min)
        in al, 0x71             ; 時刻パートを読み込む

        shl eax, 8          ; AHに読み込んだ時刻パートをさらに退避

        mov al, 0x00
        out 0x70, al            ; RTC RAMの読み取り先を指示 (Sec)
        in al, 0x71             ; 時刻パートを読み込む
       
        and eax, 0x00_FF_FF_FF   ; 下位3Byteをマスク

        mov ebx, [ebp + 8]
        mov [ebx], eax

        mov eax, 0
.END

;**** レジスタの復帰 **** 
        pop edx

;**** スタックフレームの破棄 ****
        mov esp, ebp
        pop ebp
        ret