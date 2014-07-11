.model	tiny
.586
extrn fileread:proc,fileopen:proc,readln:proc,writeln:proc,filewrite:proc
extrn keypressed:proc,filecreate:proc,fileclose:proc,FileSize:proc
.code
.startup
     jmp EndData
     dos	 db 'АБВГДЕЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеежзийклмнопрстуфхцчшщъыьэюя'
     win	 db '└┴┬├─┼и╞╟╚╔╩╦╠═╬╧╨╤╥╙╘╒╓╫╪┘┌█▄▌▐▀рстуфх╕цчшщъыьэюяЁёЄєЇїЎў°∙·√№¤■ '
     msg1	 db 13,10,'Конвертер текстовых файлов ANSI и ASCII',13,10
                 db 'Version 1.2 (c) Copyright 2002 by Sokol Software ',13,10,10,'$'
     msg2	 db 'Введите 1,если ANSI в ASCII и 2,если ASCII	в ANSI (q-выход)',13,10,'$'
     msg3	 db 'Введите имя исходного файла:',13,10,'$'
     msg5	 db 'Ошибка доступа к файлу',13,10,'$'
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
get_char:		 ;цикл опроса клавиатуры
  call	keypressed	 ;получить символ из буфера
  jz get_char		 ;символ не введен
  cmp al,'1'
  je one		 ;введен символ	'1'
  cmp al,'2'
  je two		 ;введен символ	'2'
  cmp al,'q'
  je quit		 ;введен символ	'q'
  cmp al,'Q'
  je quit		 ;введен символ	'Q'
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
  call	writeln		 ;вывели приглашение ко	вводу
  lea dx,file		 ;смещение буфера ввода
  mov cx,63		 ;длина	буфера ввода
  call	readln		 ;ввели	имя исходного файла
  cmp si,0		 ;в SI - длина строки
  jz quit		 ;если ввели пустую строку
  mov file[si],0	 ;ограничивает имя файла
  mov al,0		 ;атрибут открываемого файла
  mov dx,offset file	 ;смещение имени файла
  call	FileOpen
  jc quit
  mov h1,ax		 ;сохраняем дескриптор исходного файла
  mov bx,ax		 ;дескриптор файла
  call	FileSize	 ;в DX:AX - размер файла
  mov word ptr len,dx		 ;запомнили длину файла
  shl len,16
  and len,0FFFF0000h
  add word ptr len,ax
  mov file[si-2],'~'	 ;формируем имя нового файла
  mov file[si],0	 ;
  mov dx,offset file	 ;
  call	FileCreate	 ;
  jc quit		 ;
  mov h2,ax		 ;сохраняем дескриптор нового файла

cycle:

;читаем байт исходного файла

  mov bx,h1		 ;
  mov cx,1		 ;длина	буфера
  mov dx,offset buf	 ;смещение буфера чтения
  call	FileRead
  jc error		 ;
  
;перекодируем байт в буфере buf

  mov ax,ds		 ;инициализируем ES
  mov es,ax
  xor ax,ax
  mov al,buf[0] 	 ;символ перекодируемого буфера
  mov di,old		 ;смещение исходной строки-эталона
  mov cx,66		 ;длина	строки эталона
  cld			 ;
  repne scasb		 ;ищем символ в	AL в строке исходного эталона
  jnz write		 ;не нашли-перекодировать не нужно
  inc cx		 ;получим индекс в CX
  sub cx,66
  neg cx
  mov si,cx		 ;SI-индексный,а CX-нет!
  mov di,new
  add di,si
  mov al,[di];берем новый байт	из второй строки-эталона
  mov buf[0],al          ;заменили

write:

;пишем перекодированный байт в новый файл

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
