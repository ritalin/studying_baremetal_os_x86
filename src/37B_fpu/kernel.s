;************************************************************************
;
;	�J�[�l����
;
;************************************************************************

%define	USE_SYSTEM_CALL
%define	USE_TEST_AND_SET

;************************************************************************
;	�}�N��
;************************************************************************
%include	"../include/define.s"
%include	"../include/macro.s"

		ORG		KERNEL_LOAD						; �J�[�l���̃��[�h�A�h���X

[BITS 32]
;************************************************************************
;	�G���g���|�C���g
;************************************************************************
kernel:
		;---------------------------------------
		; �t�H���g�A�h���X���擾
		;---------------------------------------
		mov		esi, BOOT_LOAD + SECT_SIZE		; ESI   = 0x7C00 + 512
		movzx	eax, word [esi + 0]				; EAX   = [ESI + 0] // �Z�O�����g
		movzx	ebx, word [esi + 2]				; EBX   = [ESI + 2] // �I�t�Z�b�g
		shl		eax, 4							; EAX <<= 4;
		add		eax, ebx						; EAX  += EBX;
		mov		[FONT], eax						; FONT_ADR[0] = EAX;

		;---------------------------------------
		; TSS�f�B�X�N���v�^�̐ݒ�
		;---------------------------------------
		set_desc	GDT.tss_0, TSS_0			; // �^�X�N0�pTSS�̐ݒ�
		set_desc	GDT.tss_1, TSS_1			; // �^�X�N1�pTSS�̐ݒ�
		set_desc	GDT.tss_2, TSS_2			; // �^�X�N2�pTSS�̐ݒ�

		;---------------------------------------
		; �R�[���Q�[�g�̐ݒ�
		;---------------------------------------
		set_call_gate_desc	GDT.call_gate, call_gate	; // �R�[���Q�[�g�̐ݒ�

		;---------------------------------------
		; LDT�̐ݒ�
		;---------------------------------------
		set_desc	GDT.ldt, LDT, word LDT_LIMIT

		;---------------------------------------
		; GDT�����[�h�i�Đݒ�j
		;---------------------------------------
		lgdt	[GDTR]							; // �O���[�o���f�B�X�N���v�^�e�[�u�������[�h

		;---------------------------------------
		; �X�^�b�N�̐ݒ�
		;---------------------------------------
		mov		esp, SP_TASK_00					; // �^�X�N0�p�̃X�^�b�N��ݒ�

		;---------------------------------------
		; �^�X�N���W�X�^�̏�����
		;---------------------------------------
		mov		ax, SS_TASK_0
		ltr		ax								; // �^�X�N���W�X�^�̐ݒ�

		;---------------------------------------
		; ������
		;---------------------------------------
		cdecl	init_int						; // ���荞�݃x�N�^�̏�����
		cdecl	init_pic						; // ���荞�݃R���g���[���̏�����

		set_vect	0x00, int_zero_div			; // ���荞�ݏ����̓o�^�F0���Z
		set_vect	0x07, int_nm				; // ���荞�ݏ����̓o�^�F�f�o�C�X�g�p�s��
		set_vect	0x20, int_timer				; // ���荞�ݏ����̓o�^�F�^�C�}�[
		set_vect	0x21, int_keyboard			; // ���荞�ݏ����̓o�^�FKBC
		set_vect	0x28, int_rtc				; // ���荞�ݏ����̓o�^�FRTC
		set_vect	0x81, trap_gate_81, word 0xEF00	; // �g���b�v�Q�[�g�̓o�^�F1�����o��
		set_vect	0x82, trap_gate_82, word 0xEF00	; // �g���b�v�Q�[�g�̓o�^�F�_�̕`��

		;---------------------------------------
		; �f�o�C�X�̊��荞�݋���
		;---------------------------------------
		cdecl	enable_rtc_int, 0x10				; rtc_int_en(UIE); // �X�V�T�C�N���I�����荞�݋���
		cdecl	enable_int_timer0					; // �^�C�}�[�i�J�E���^0�j���荞�݋���

		;---------------------------------------
		; IMR(���荞�݃}�X�N���W�X�^)�̐ݒ�
		;---------------------------------------
		outp	0x21, 0b_1111_1000				; // ���荞�ݗL���F�X���[�uPIC/KBC/�^�C�}�[
		outp	0xA1, 0b_1111_1110				; // ���荞�ݗL���FRTC

		;---------------------------------------
		; CPU�̊��荞�݋���
		;---------------------------------------
		sti										; // ���荞�݋���

		;---------------------------------------
		; �t�H���g�̈ꗗ�\��
		;---------------------------------------
		cdecl	draw_font, 63, 13				; // �t�H���g�̈ꗗ�\��
		cdecl	draw_color_bar, 63, 4			; // �J���[�o�[�̕\��

		;---------------------------------------
		; ������̕\��
		;---------------------------------------
		cdecl	draw_str, 25, 14, 0x010F, .s0	; draw_str();

.10L:											; while (;;)
												; {
		;---------------------------------------
		; ��]����_��\��
		;---------------------------------------
		cdecl	draw_rotation_bar				;   // ��]����_��\��

		;---------------------------------------
		; �L�[�R�[�h�̎擾
		;---------------------------------------
		cdecl	read_ring_buff, KEY_BUFF, .int_key	;   EAX = ring_rd(buff, &int_key);
		cmp		eax, 0							;   if (EAX == 0)
		je		.10E							;   {
												;   
		;---------------------------------------
		; �L�[�R�[�h�̕\��
		;---------------------------------------
		cdecl	draw_key, 2, 29, KEY_BUFF		;     ring_show(key_buff); // �S�v�f��\��
.10E:											;   }
		jmp		.10L							; }

.s0:	db	" HELLO, kernel! ", 0

ALIGN 4, db 0
.int_key:	dd	0

ALIGN 4, db 0
FONT:	dd	0
RTC_TIME:	dd	0

;************************************************************************
;	�^�X�N
;************************************************************************
%include	"descriptor.s"
%include	"modules/int_timer.s"
%include	"tasks/task_1.s"
%include	"tasks/task_2.s"

;************************************************************************
;	���W���[��
;************************************************************************
%include	"../modules/protect/vga.s"
%include	"../modules/protect/draw_char.s"
%include	"../modules/protect/draw_font.s"
%include	"../modules/protect/draw_str.s"
%include	"../modules/protect/draw_color_bar.s"
%include	"../modules/protect/draw_pixel.s"
%include	"../modules/protect/draw_line.s"
%include	"../modules/protect/draw_rect.s"
%include	"../modules/protect/itoa.s"
%include	"../modules/protect/rtc.s"
%include	"../modules/protect/draw_time.s"
%include	"../modules/protect/interrupt.s"
%include	"../modules/protect/pic.s"
%include	"../modules/protect/int_rtc.s"
%include	"../modules/protect/int_keyboard.s"
%include	"../modules/protect/ring_buff.s"
%include	"../modules/protect/draw_rotation_bar.s"
%include	"../modules/protect/call_gate.s"
%include	"../modules/protect/trap_gate.s"
%include	"../modules/protect/test_and_set.s"
%include	"../modules/protect/int_nm.s"

;************************************************************************
;	�p�f�B���O
;************************************************************************
		times KERNEL_SIZE - ($ - $$) db 0x00	; �p�f�B���O

