.model	tiny
.586
extrn fileread:proc,fileopen:proc,readln:proc,writeln:proc,filewrite:proc
extrn keypressed:proc,filecreate:proc,fileclose:proc,FileSize:proc
.code
.startup
     jmp EndData
     dos	 db '������������������������������������������������������������������'
     win	 db '�����Ũ����������������������������������������������������������'
     msg1	 db 13,10,'�������� ⥪�⮢�� 䠩��� ANSI � ASCII',13,10
                 db 'Version 1.2 (c) Copyright 2002 by Sokol Software ',13,10,10,'$'
     msg2	 db '������ 1,�᫨ ANSI � ASCII � 2,�᫨ ASCII	� ANSI (q-��室)',13,10,'$'
     msg3	 db '������ ��� ��室���� 䠩��:',13,10,'$'
     msg5	 db '�訡�� ����㯠 � 䠩��',13,10,'$'
     file	 db 63 dup(3)
     buf	 db ?
     old	 dw dos
     new	 dw win
     len	 dd ?
     h1		 dw ?
     h2	 	 dw ?
EndData:
  lea dx,msg1
  call	writeln
  lea dx,msg2
  call	writeln
get_char:		 ;横� ���� ����������
  call	keypressed	 ;������� ᨬ��� �� ����
  jz get_char		 ;ᨬ��� �� ������
  cmp al,'1'
  je one		 ;������ ᨬ���	'1'
  cmp al,'2'
  je two		 ;������ ᨬ���	'2'
  cmp al,'q'
  je quit		 ;������ ᨬ���	'q'
  cmp al,'Q'
  je quit		 ;������ ᨬ���	'Q'
  jmp get_char
one:
  mov ax,offset win
  mov old,ax
  mov ax,offset dos
  mov new,ax
  jmp begin
two:
  mov ax,offset dos
  mov old,ax
  mov ax,offset win
  mov new,ax
begin:
  lea dx,msg3		 ;
  call	writeln		 ;�뢥�� �ਣ��襭�� ��	�����
  lea dx,file		 ;ᬥ饭�� ���� �����
  mov cx,63		 ;�����	���� �����
  call	readln		 ;�����	��� ��室���� 䠩��
  cmp si,0		 ;� SI - ����� ��ப�
  jz quit		 ;�᫨ ����� ������ ��ப�
  mov file[si],0	 ;��࠭�稢��� ��� 䠩��
  mov al,0		 ;��ਡ�� ���뢠����� 䠩��
  mov dx,offset file	 ;ᬥ饭�� ����� 䠩��
  call	FileOpen
  jc quit
  mov h1,ax		 ;��࠭塞 ���ਯ�� ��室���� 䠩��
  mov bx,ax		 ;���ਯ�� 䠩��
  call	FileSize	 ;� DX:AX - ࠧ��� 䠩��
  mov word ptr len,dx		 ;��������� ����� 䠩��
  shl len,16
  and len,0FFFF0000h
  add word ptr len,ax
  mov file[si-2],'~'	 ;�ନ�㥬 ��� ������ 䠩��
  mov file[si],0	 ;
  mov dx,offset file	 ;
  call	FileCreate	 ;
  jc quit		 ;
  mov h2,ax		 ;��࠭塞 ���ਯ�� ������ 䠩��

cycle:

;�⠥� ���� ��室���� 䠩��

  mov bx,h1		 ;
  mov cx,1		 ;�����	����
  mov dx,offset buf	 ;ᬥ饭�� ���� �⥭��
  call	FileRead
  jc error		 ;
  
;��४����㥬 ���� � ���� buf

  mov ax,ds		 ;���樠�����㥬 ES
  mov es,ax
  xor ax,ax
  mov al,buf[0] 	 ;ᨬ��� ��४����㥬��� ����
  mov di,old		 ;ᬥ饭�� ��室��� ��ப�-�⠫���
  mov cx,66		 ;�����	��ப� �⠫���
  cld			 ;
  repne scasb		 ;�饬 ᨬ��� �	AL � ��ப� ��室���� �⠫���
  jnz write		 ;�� ��諨-��४���஢��� �� �㦭�
  inc cx		 ;����稬 ������ � CX
  sub cx,66
  neg cx
  mov si,cx		 ;SI-�������,� CX-���!
  mov di,new
  add di,si
  mov al,[di];��६ ���� ����	�� ��ன ��ப�-�⠫���
  mov buf[0],al          ;��������

write:

;��襬 ��४���஢���� ���� � ���� 䠩�

  mov bx,h2
  mov dx,offset buf	 ;
  mov cx,1
  call	FileWrite	 ;
  jc quit		 ;
  dec len
  cmp len,0
  je complete
  jmp cycle

complete:

  mov bx,h1		 ;
  call	FileClose	 ;
  mov bx,h2
  call	FileClose	 ;  
  jmp quit		 ;
error:			 ;
  lea dx,msg5		 ;
  call Writeln		 ;
quit:			 ;
  mov ah,4Ch		 ;
  int 21h		 ;
end 
