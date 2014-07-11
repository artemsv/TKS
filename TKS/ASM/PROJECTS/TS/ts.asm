.model tiny
extrn OutDB:proc
.code
.startup
jmp install
Hook70 proc far ;обpабока int 70
     push ax
     push bx
     push cx
     push di
     push ds
     push es
     mov  ax,cs     ;сегмент pезедента
     mov  ds,ax
     jmp w
	der db 'Привет из прерывания 70!!!',13,10,'$'
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
  mov ax,2546h                       ; устанавливаем свой
  int 21h
  mov dx,offset install
  int 27h                             ; выйти и pез.
end