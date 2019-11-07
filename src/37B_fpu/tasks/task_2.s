
;************************************************************************
;	TASK
;************************************************************************
task_2:
		;---------------------------------------
		; ������̕\��
		;---------------------------------------
		cdecl	draw_str, 63, 1, 0x07, .s0		; draw_str(.s0);

		;---------------------------------------
		; ������
		;---------------------------------------
												; ---------+---------+---------|---------|---------|---------|
												;       ST0|      ST1|      ST2|      ST3|      ST4|      ST5|
												; ---------+---------+---------|---------|---------|---------|
		fild	dword [.c1000]					;     1000 |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
		fldpi									;       pi |    1000 |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
		fidiv	dword [.c180]					;   pi/180 |    1000 |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
		fldpi									;       pi |  pi/180 |    1000 |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
		fadd	st0, st0						;     2*pi |  pi/180 |    1000 |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
		fldz									;   �� = 0 |    2*pi |  pi/180 |    1000 |xxxxxxxxx|xxxxxxxxx|
												; ---------+---------+---------|---------|---------|---------|
												;   �� = 0 |    2*pi |       d |    1000 |xxxxxxxxx|xxxxxxxxx|
												; ---------+---------+---------|---------|---------|---------|

		;---------------------------------------
		; ���C�����[�v
		;---------------------------------------
.10L:											; for ( ; ; )
												; {
		;---------------------------------------
		; sin(t)
		;---------------------------------------
												; ---------+---------+---------|---------|---------|---------|
												;       ST0|      ST1|      ST2|      ST3|      ST4|      ST5|
												; ---------+---------+---------|---------|---------|---------|
												;       �� |    2*pi |       d |    1000 |xxxxxxxxx|xxxxxxxxx|
												; ---------+---------+---------|---------|---------|---------|
		fadd	st0, st2						;   �� + d |    2*pi |       d |    1000 |xxxxxxxxx|xxxxxxxxx|
		fprem									;   MOD(��)|      �� |    2*pi |       d |    1000 |xxxxxxxxx|
		fld		st0								;       �� |      �� |    2*pi |       d |    1000 |xxxxxxxxx|
		fsin									;   sin(��)|      �� |    2*pi |       d |    1000 |xxxxxxxxx|
		fmul	st0, st4						;ST4sin(��)|      �� |    2*pi |       d |    1000 |xxxxxxxxx|
												; ---------+---------+---------|---------|---------|---------|
		fbstp	[.bcd]							;       �� |    2*pi |       d |    1000 |xxxxxxxxx|xxxxxxxxx|
												; ---------+---------+---------|---------|---------|---------|

		mov		eax, [.bcd]						;   EAX = 1000 * sin(t);
		mov		ebx, eax						;   EBX = EAX;

		and		eax, 0x0F0F						;   // ���4�r�b�g���}�X�N
		or		eax, 0x3030						;   // ���4�r�b�g��0x3��ݒ�

		shr		ebx, 4							;   EBX >>= 4;
		and		ebx, 0x0F0F						;   // �e�o�C�g�̉���4�r�b�g���L��
		or		ebx, 0x3030						;   // ���4�r�b�g��0x3��ݒ�

		mov		[.s2 + 0], bh					;   // 1����
		mov		[.s3 + 0], ah					;   // ����1����
		mov		[.s3 + 1], bl					;   // ����2����
		mov		[.s3 + 2], al					;   // ����3����

		mov		eax, 7							;   // �����̕\��
		bt		[.bcd + 9], eax					;   CF = bcd[9] & 0x80;
		jc		.10F							;   if (CF)
												;   {
		mov		[.s1 + 0], byte '+'				;     *s1 = '+';
		jmp		.10E							;   }
.10F:											;   else
												;   {
		mov		[.s1 + 0], byte '-'				;     *s1 = '-';
.10E:											;   }

		cdecl	draw_str, 72, 1, 0x07, .s1		; draw_str(.s1);

		;---------------------------------------
		; �E�F�C�g
		;---------------------------------------
		mov		ecx, 20							;   ECX = 20
												;   do
												;   {
.20L:	mov		eax, [TIMER_COUNT]				;     EAX = TIMER_COUNT;
.21L:	cmp		[TIMER_COUNT], eax				;     while (TIMER_COUNT != EAX)
		je		.21L							;       ;
		loop	.20L							;   } while (--ECX);

		jmp		.10L							; }


ALIGN 4, db 0
.c1000:		dd	1000
.c180:		dd	180

.bcd:	times 10 db	0x00

.s0		db	"Task-2", 0
.s1:	db	"-"
.s2:	db	"0."
.s3:	db	"000", 0

