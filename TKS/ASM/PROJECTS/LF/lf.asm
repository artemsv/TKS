;05.12.02
.model tiny
.586
org 100h
.code	
  extrn FileRead:proc,FileOpen:proc,Readln:proc,Writeln:proc
.startup
  jmp	EndData
  buf   db 4096 dup(0)
  msg1  db 13,10,'�����稪 ���⮢�� 䠩��� � ������������',13,10
        db 'Version 1.2 (c) Copyright 2002 by Sokol Software ',13,10,10,'$'
  msg3  db '������ ��� 䠩�� ���⮢ � �ଠ� AFF 1.0',13,10,'$'
  msg4  db '���ࠢ���� �ଠ� 䠩��',13,10,'$'
  msg5  db '�訡�� ����㯠 � 䠩��',13,10,'$'
  msg6  db '����� ��⠭������',13,10,'$'
  msg7  db '����� �� ��⠭������',13,10,'$'
  file  db 63 dup(3) 
  sign1	db 'AFF 1.0',16,255,255,28
  sign2 db 11 dup(4)
  h	dw  ?
EndData:
  lea dx,msg1
  call Writeln
  lea dx,msg3
  call Writeln
  lea dx,file
  mov cl,63     	;ࠧ��� ���� �����
  call Readln 		;���� ����� 䠩��
  cmp si,0	        ;� SI - ����� ��ப�
  je not_inst	        ;�᫨ ����� ������ ��ப�
  mov file[si],0        ;��࠭�稢��� ��� 䠩��
  mov file[si+1],13
  mov file[si+2],10
  mov file[si+3],7
  mov file[si+4],'$'
  mov al,0
  call FileOpen
  jnc no_err
  lea dx,file
  call Writeln
  lea dx,msg5
  call Writeln
  jmp not_inst
no_err:
;���뢠�� ��������� 䠩��
  mov h,ax		;��࠭塞 ���ਯ�� 䠩��
  mov bx,ax		;���ਯ�� 䠩��
  lea dx,sign2          ;���� �����
  mov cx,11		;ࠧ��� ���� �����
  call FileRead

; �ࠢ������ ��������� 䠩�� � �⠫����� ᨣ����ன

  lea si,sign1
  lea di,sign2
  push ds
  pop es
  mov cx,11
  rep cmpsb
  je good
  lea dx,msg4
  call Writeln
  jmp not_inst

;���뢠�� ������ ��ࠧ� ���⮢

good:
  lea dx,buf
  mov cx,4096
  mov bx,h
  call FileRead
  jc not_inst

;���㧪� ������������

  lea dx,buf
  mov bp,dx
  mov ah,11h
  mov al,0
  mov cx,256            ;������⢮ ᨬ�����
  mov dx,0
  mov bl,0
  mov bh,16
  int 10h
  lea dx,msg6
  call Writeln
  jmp quit

not_inst:
  lea dx,msg7
  call Writeln
quit:
  mov	ax, 4c00h	
  int	21h		
end