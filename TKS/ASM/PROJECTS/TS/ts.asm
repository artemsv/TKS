.model tiny
extrn OutDB:proc
.code
.startup
jmp install
Hook70 proc far ;��p����� int 70
     push ax
     push bx
     push cx
     push di
     push ds
     push es
     mov  ax,cs     ;ᥣ���� p�������
     mov  ds,ax
     jmp w
	der db '�ਢ�� �� ���뢠��� 70!!!',13,10,'$'
w:
     lea dx,der
     mov ah,9
     int 21h
     pop  es
     pop  ds
     pop  di
     pop  cx
     pop  bx
     pop  ax
     iret
endp
install:
  mov dx,offset Hook70
  mov ax,2546h                       ; ��⠭�������� ᢮�
  int 21h
  mov dx,offset install
  int 27h                             ; ��� � p��.
end