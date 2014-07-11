model small
.stack   256 
.data
  string db 'Assembler',13,10,'$'
.code
start:
  mov ax,@data
  mov ds,ax
  lea dx,string
  mov ah,9
  int 21h
  mov ah,4ch
  int 21h
end start