;       ����� � ��楤�ࠬ� �ࠢ����� ��ᯫ��� � ��������ன
;	(c) Copyright 2002 by Sokolov Artem
;	��� ᮧ�����:     05.12.02

.model small
.386
.code

	extrn GetStart:proc

PUBLIC CaretInsert,CaretNormal,CaretShow,CaretHide,Cls,OverScan,Writeln,GotoXY
PUBLIC WhereXy,Readln,KeyPressed,Pause,ReadKey,FillWord,FillByte,OutDW,OutDB

CaretInsert :
	mov ch,00000010B
	jmp short Caret1
CaretHide:
	mov cx,2000h
	jmp short Caret1
CaretShow:
CaretNormal:
	mov ch,00001110B
Caret1:
	mov ah,1
	xor cl,cl
	jmp short int10hRET

OverScan:
	mov ax,1001h
	jmp short int10hRET
	
Cls:  				; ��頥� ��࠭
  	cld
	mov ax,0B800H
  	mov es,ax
  	mov di,0
  	mov cx,2000
  	mov al,32
  	mov ah,7
  	rep stosw
  	ret

Writeln:			; �뢮��� ��ப� � ��࠭��⥫�� ᨬ�����
  	mov ah,9
  	int 21h
  	ret 

GotoXY:					;����樮�-� �����;DH-row,DL-column
  	mov bh,0			;����� ��࠭���
  	mov ah,2
int10hRET:
	int 10h
	ret

WhereXY:				;�����頥�: DH-row,DL-column
  	mov bh,0
  	mov ah,3
	jmp short int10hRET

Readln:					;���� ��ப� �ந����쭮� ����� 
;�� �室�:
;dx - ���� ��ப� �㤠 �㤥� ����饭 ����
;cl - ���ᨬ��쭠� ����� �������� ��ப�
;�� ��室� - ��������� ��ப� �� ����� dx
;bx - ����� ��������� ��ப�
        push si
	mov di,dx
  	mov [di],cl 		;� ���� ᨬ��� ��ப�-����� ����  
        mov ah,0ah		;�㭪�� ����� ��ப� � ����������
  	int 21h	;��᫥ ���뢠��� � buf[0]-������� �����,� buf[1]-ॠ�쭠�
  	mov al,[di+1]
  	mov cl,al	;����� ��������� ��ப� � al
	;ᤢ�� buf �� ��� ���� �����:
  	push	ds
  	pop	es
  	mov	si,di
  	add 	si,2
  	cld
  	rep	movsb
  	xor	cx,cx
  	mov   cl,al
  	mov   bx,cx
  	pop si
	ret

KeyPressed:				;�᫨ AL=0,� � AH-���७�� ���
        push dx
  	mov ah,6
  	mov dl,0FFH
  	int 21h
  	jz short no_char            	;��� �����
  	cmp al,0			;���७�� ���
  	je short ext_char
  	mov ah,0
no_char:
	pop dx
  	ret
ext_char:
  	int 21h				;����砥� ��ன ����
  	mov ah,1
	pop dx
  	ret

Pause:
  	mov ah,1
  	int 21h
  	ret

FillWord:			;DX-���孨� 㣮�,CX-���-�� ᫮�,AX-᫮��
	push es di si cx
	call GetStart
	rep stosw
	pop cx si di es
   	ret 

FillByte:			;DX-���孨� 㣮�,CX-���-�� ᫮�,AL-����
	push es di
	call GetStart
FB100:
	stosb
   	inc di
   	loop FB100
	pop di es
   	ret 

OutDB:				;DX-���孨� 㣮�,CX-�����,SI-��ப� ���筨�
	push es di cx
	pushf                   ;�᫨ CF ��襭,��ਡ�� �� ���뢠��
	call GetStart
	popf
	cld
ODB100:	pushf
	cmp byte ptr [si],13
	je short ODB400
	cmp byte ptr [si],0
	je short ODB400
	movsb
	popf
	jnc short ODB200
	stosb
	jmp short ODB300
ODB200:	inc di
ODB300: loop ODB100
	jmp short ODB500
ODB400:	popf
ODB500:	pop cx di es
	ret 

OutDW :
	push es di
	call GetStart
	rep movsw
	pop di es
   	ret

ReadKey:			;�� ������ ���. ZF=1,�᫨ ����.������
  	mov ah,0		;⮣�� � AH - ���७�� ���
	int 16h			;�᫨ ZF=0,⮣�� � AL ASCII-���,� AH scan-���
;	cmp al,0                
	ret
end