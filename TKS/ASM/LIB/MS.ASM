.model small
.386
.code

PUBLIC MouseShow,MouseInit,MouseHide,MouseSetPos,GetMouseInfo,MouseButtons
PUBLIC MouseRelease,MouseWhere

MouseShow:
	mov ax,1
	int 33h
	ret

MouseHide:
	mov ax,2
	int 33h
	ret

MouseInit:
 	mov ax,0
	int 33h
	ret

MouseSetPos:			;� CX - ��ਧ��⠫쭠�,� DX - ���⨪��쭠�
	mov ax,04h
	int 33h
	ret

GetMouseInfo:		;�����.: � AH - ���न��� �� Y ,� AL - �� X	
	push dx bx cx   ;��⠭�������� CF �᫨ ����� ����� ������
	mov ax,03h		
	int 33h			
	push bx			;��࠭塞 ���� �����
	mov bl,8                ;���� 
	mov ax,dx
	div bl
	mov bh,al		;� BH - ���न��� �� Y
	mov ax,cx
	div bl			;� AL - ���न��� �� X
	mov ah,bh		;� AH - ���न��� �� Y
	pop bx                  ;����⠭�������� ���� �����
	test bl,1
	jne short GMI100
	pop cx bx dx
	clc
	jmp short GMI200		
GMI100:	pop cx bx dx
	stc
GMI200:	ret
	
MouseButtons:			;�㫥��� ��� � BL=1  -  ����� ����� ������
	push dx			;���� ��� � BL=1  -  ����� �ࠢ�� ������
	push cx
	mov ax,5		;� AH - ���न��� �� Y ,� AL - �� X	
	mov bx,0
	int 33h 		;CX-X,DX-Y,AX-����� (0 � 1-� ����)
	xor bx,bx
	test al,0
	je MB100
	mov bl,8                ;���� 
	mov ax,dx
	div bl
	mov bh,al		
	mov ax,cx
	div bl
	mov ah,bh
	mov bl,1	
MB100:
	pop cx
	pop dx	
	ret

MouseRelease:
	mov ax,6
	mov bx,0
	int 33h
	ret

MouseWhere:				;� AH - ���न��� �� Y ,� AL - �� X	
	mov ax,3
	int 33h
	mov bl,8
	mov ax,dx
	div bl
	mov bh,al		
	mov ax,cx
	div bl
	mov ah,bh
	ret
end