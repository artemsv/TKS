.model tiny
.code
.startup
jmp install
Hook09 proc far ;��p����� int 09h
     push ax
     push bx
     push cx
     push di
     push ds
     push es
     mov  ax,cs     ;ᥣ���� p�������
     mov  ds,ax
     in   al,60h
     mov  ah,al
     cmp  al,45h
     je   Quit         ; �p���p�� ������ 
  OldHook09:
     pop  es
     pop  ds
     pop  di
     pop  cx
     pop  bx
     pop  ax
     db   0EAh                              ; ����� far jump
     OldHandler09 dd ?                      ; jump xxxx:yyyy
  Quit:
     in   al,61h                            ; �p��뢠�� ����p����p ��������p�
     mov  ah,al                             ; � p��p�蠥� ��p����� ᫥�. ᨬ�.
     or   al,80h
     out  61h,al
     xchg ah,al
     out  61h,al
     mov  al,20h
     out  20h,al
     pop  es
     pop  ds
     pop  di
     pop  cx
     pop  bx
     pop  ax
     iret
Hook09 endp

end_tsr:
  ff db 'AntiPause 1.0  Copyright (c) 2002 by Sokol Software Ink.',13,10,'$'
install:
  mov ax,3509h
  int 21h
  mov word ptr [OldHandler09],bx
  mov word ptr [OldHandler09+2],es   ; ����砥� � ��p��塞 ��p� ����p int 09
  mov dx,offset Hook09
  mov ax,2509h                       ; ��⠭�������� ᢮�
  int 21h
  lea dx,ff
  mov ah,9
  int 21h  
  mov dx,offset END_TSR
  int 27h                             ; ��� � p��.
end