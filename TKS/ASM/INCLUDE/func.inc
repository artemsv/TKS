	retf
WriteChar endp	;конец процедуры

Writeln proc near str:word
public Writeln
  lea dx,str
  mov ah,9
  int 21h
Writeln endp   
