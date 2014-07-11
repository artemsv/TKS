; 		Библиотека макросов        		
;	(c) Copyright 2002 by Sokolov Artem
;	дата создания:     05.12.02

FileCreate macro FileName
  mov ah,3ch            ;функция создания файла
  mov cx,0		;нормальные атрибуты
  lea dx,FileName	;имя файла
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
  
  