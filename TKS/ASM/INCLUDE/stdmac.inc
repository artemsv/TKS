; 		������⥪� ����ᮢ        		
;	(c) Copyright 2002 by Sokolov Artem
;	��� ᮧ�����:     04.12.02

Exit macro cod
  mov   al,cod
  mov   ah,4ch
  int   21h
endm

Prolog macro
  mov	ax,@data
  mov	ds,ax
endm  
 
ReadKey	 macro                  ;���� ᨬ���� � ����������.
  mov	ah,01h			;�� ��室� - � al ������ ᨬ���.
  int	21h
endm

OutChar macro                   ;�뢮� ᨬ���� �� ��࠭.
;�� �室� - � dl �뢮���� ᨬ���.
  mov	ah,02h
  int	21h
endm

OverScan macro color		;��⠭���� 梥� �࠭��� ��࠭�
  mov ah,0BH
  mov bl,color
  mov bh,0
  int 10h
endm

GotoXY macro X,Y		;����樮��஢���� �����
  mov dl,X
  mov dh,Y
  mov bh,0			;����� ��࠭���
  mov ah,2
  int 10h
endm

OutStr macro str,len,X1,Y1
   mov ax,0B800h			
   mov es,ax
   mov ax,Y1
   mov dx,160
   mul dx
   add ax,X1
   add ax,X1
   mov di,ax
   mov cx,len
next:
   lea si,str
   movsb
   inc di;
   loop next
endm 
