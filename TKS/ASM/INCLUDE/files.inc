; 		������⥪� ����ᮢ        		
;	(c) Copyright 2002 by Sokolov Artem
;	��� ᮧ�����:     05.12.02

FileCreate macro FileName
  mov ah,3ch            ;�㭪�� ᮧ����� 䠩��
  mov cx,0		;��ଠ��� ��ਡ���
  lea dx,FileName	;��� 䠩��
  int 21h
endm  

FileRead macro handle,buf,len
  mov bx,handle
  mov ah,3fh
  mov cx,len
  lea dx,buf
  int 21h
  ;jc error
endm

FileWrite macro handle,buf,len
  mov bx,handle
  mov ah,40h
  mov cx,len
  lea dx,buf
  int 21h
  ;jc error
endm
  
  