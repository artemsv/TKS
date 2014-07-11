;       ����� � ��楤�ࠬ� 䠩������ ����� �뢮��
;	(c) Copyright 2002 by Sokolov Artem
;	��� ᮧ�����:     07.12.02

.model small,pascal
.data
	params	dw	0
	com	dd	?
		dd	?
		dd	?
	keep_ss	dw	0
	keep_sp	dw	0
	keep_ds	dw	0
        path	db	'*.*',0	;蠡��� ��� ���᪠
.386
.code
	extrn EndProg:proc,IsAlpha:proc

PUBLIC Exec,InitExe,FreeMem,GetMem,GetCurDrive,SetCurDir,GetCurDir,CopyFiles  

Exec:					;DI-��������� ��ப�
	push di				;��࠭��� ᬥ饭�� ����� 䠩��
	mov al,0			;⥯��� ���� ���� ᬥ饭�� ���.��ப�
	push ds
	pop es
	mov cx,63
	cld
	repne scasb			;�饬 ��砫� ����� ����᪠����� 䠩��
	push di
	pop si				;SI-��������� ��ப� 
	pop di				;DI-��� ����᪠����� 䠩��
	mov keep_ds,ds			;��࠭塞 DS ��뢠�饩 �ண�
	mov ax,@data
	mov ds,ax
	mov word ptr com,offset si
	mov word ptr com+2,seg si
	mov ax,seg params
	mov es,ax
	mov bx,offset params
	mov keep_ss,ss
	mov keep_sp,sp
	mov dx,offset di
	mov ax,seg di
	mov ds,ax
	mov ah,4bh
	mov al,0
	int 21h
	mov ss,keep_ss
	mov sp,keep_sp
	mov ds,keep_ds
	ret

InitExe:
	mov ax,@data
	mov ds,ax
	call far ptr EndProg
	mov bx,es
	sub bx,ax
	neg bx
	mov ah,4ah
	int 21h	
	ret

FreeMem:			;ES-ᥣ���� �᢮���������� ����� �����
	mov ah,49h
	int 21h
	ret

GetMem:				;� BX - �᫮ �ॡ㥬�� ��ࠣ�䮢
	mov ah,48h
  	int 21h
  	ret

GetCurDrive:			;������⥫쯮 㬮�砭�� � AL ����� (0-A,2-C...)
	mov ah,19h
	int 21h
	ret

SetCurDir:			;DS:DX-���� � ��ப� � ��⠫����
	mov ah,3bh
	int 21h
	ret

GetCurDir:			;DS:SI-���� 64 ����
	push si
	call GetCurDrive
	add al,41h		;�८�ࠧ㥬 � �㪢�
	mov [si],al
	mov byte ptr [si+1],':'
	mov byte ptr [si+2],'\'
	add si,3
	mov ah,47h
	mov dl,0		;0-�� 㬮�砭��( 1-A,2-B,3-C � �.�)
	int 21h
	pop si
	ret

CanICopy:				;�����頥� CF=1 �᫨ ����஢��� �����
	cmp byte ptr es:[0095h],10h	;���� ��ਡ�⮢ � DTA
	sete al				;�᫨ �� ��⠫��,AL=1
	cmp bx,2			;�� ���� ��室?(di = 3)
	sete ah				;�᫨ ��-AL = 1
	add al,ah                       ;����஢��� �����,�᫨ AL=0 ��� 2
	cmp al,1			
	je short CIC100			;����஢��� �����!!!
	clc
	ret
CIC100:	stc
	ret	

CopyFiles:			;������� �� 䠩�� ⥪�饣� � FS:000E
	;�� ��ࢮ� ��室� ������� �� ��⠫���,�� ��஬-䠩��
	push dx bx si di 
	mov di,14			;ᬥ饭�� � �⮬ ����
	mov ah,2FH
	int 21h                 	;������� ⥪���� DTA  ES:BX
	mov bx,2			;᪠��஢��� �� ��� ��室�(�� 3!!!)
CF100:					;������ 横�	
	mov ah,4eH
	lea dx,path
	int 21h  			;�饬 ���� 䠩�
	jc short CF400			;�� ��諨
	call CanICopy
	jc short CF500			;� �⮬ ��室� ����஢��� �����
	xor bp,bp  			;���稪 䠩���
	mov si,9Eh			;SI-ᬥ饭�� ����� 䠩�� � DTA
CF200:
	inc bp					;
CF300:	lods byte ptr es:[si]
	cmp al,2Eh
	jne short CF360
	cmp di,14				;DI-�� ��砫� ���� � FS ?	
	jne short CF360
	cmp byte ptr es:[si],2Eh
	je short CF360				;�� ���� �窠-��⠢���
	dec bp
	jmp short CF500				;�� ��ࢠ� �窠-�ய�����
CF360:
	cmp byte ptr es:[0095h],10h		;�� ��⠫��?
	je short CF400				;ॣ���� ��⠫��� �� ������
	call IsAlpha
	jnc short CF400				;�� �� �㪢�
	add al,20h
CF400:	mov byte ptr fs:[di],al
	inc di
	or al,al
	jne short CF300
CF500:
	lea dx,path 
	mov ah,4fh
	int 21h					;�᪠�� ᫥���騩 䠩�
	mov si,9Eh				;BX-ᬥ饭�� ����� 䠩�� � DTA
	jc short CF600
	call CanICopy
	jc short CF500
	jmp short CF200
CF600:
	dec bx					;���稪 ��室��
	jnz short CF100				;�� �� ���� ��室
	mov word ptr fs:[0012],bp		;������⢮ 䠩���
	pop di si bx dx
	ret
end 