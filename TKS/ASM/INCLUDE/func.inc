	retf
WriteChar endp	;����� ��楤���

Writeln proc near str:word
public Writeln
  lea dx,str
  mov ah,9
  int 21h
Writeln endp   
