.model small			;  дата создания :12.12.02.
.386
.data
extrn buf:word
	  ver   db ?
	  hor   db ?
	  ulf	db ?
	  urt	db ?
	  dlf	db ?
	  drt	db ?
.code

;изменяет байт атрибутов прямоугольной области экрана в соответствии с маской
;байт атрибутов подвергается операции AND c байтом в AL и операции OR с AH
PUBLIC ChangeAtribut,Shadow,Win1,Win2,PutBlock,GetBlock,FillBackBlock,GetStart

ChangeAtribut:			;в DX верхний левый угол,в BH-высота,BL-длина
	push si di dx bx ds cx 	;байт атрибутов AND AL + байт атрибутов OR AH
	call GetStart           ;настраиваем DI и ES в соответсвии с DX
	mov dx,ax		;сохраняем маску изменения атрибутов
	push di
	pop si			;
	push es
	pop ds                  ;сегмент источника-видеопамять
CA200:
	xor cx,cx
	mov cl,bl		;длина очередной строки
	jcxz CA400
CA300:
	lodsw				;загрузили слово из видеопамяти
	and ah,dl			;изменяем байт атрибутов в соотв.
	or ah,dh			;с маской
	stosw                           ;сохранили измененное слово
	loop CA300
	dec bh                          ;счетчик строк прямоуг.участка экрана
	cmp bh,0
	je short CA400
	add di,160			;переход к следующей строке экрана
	xor cx,cx
	mov cl,bl
	sub di,cx
	sub di,cx
	push di
	pop si	
	jmp short CA200
CA400:	pop cx
	jmp GB200
	                        	
Shadow:				;в DX верхний левый угол,в BH-высота,BL-длина
	push si di dx bx
	inc dh
	add dl,bl
	mov bl,2
	mov ax,000fh
	call ChangeAtribut
	pop bx
	pop dx
	push dx
	push bx
	add dl,2
	add dh,bh
	mov bh,1
	sub bl,2
	mov ax,000fh
	call ChangeAtribut
	jmp short GB300

;заполняет словом прямоугольный участок видеопамяти

FillBackBlock:			;в DX верхний левый угол,в BH-высота,BL-длина
	push si di dx bx cx	;в AX-байт атрибутов+символьный байт
	call GetStart	
	mov dh,bh		;число столбцов участка экрана	
	mov bh,0
FBB100:				;цикл по столбцам участка экрана
	xor cx,cx
	mov cl,bl		;длина участка
	rep stosw		;вывели строку
	dec dh			;уменьшить счетчик строк
	cmp dh,0
	je short FBB200		;вывели все строки
	add di,160		;перейти к следующей строке участка экрана
	sub di,bx
	sub di,bx
	jmp short FBB100	
FBB200:	pop cx
	jmp short GB300

;настраивает ES:DI на смещение точки DH,DL (Y,X) в видеопамяти

GetStart:			;в DX - верхний угол
	push ax cx dx		;команда MUL портит DX !?
	mov ax,0B800h
	mov es,ax    		;настройка сегмента приемника-видеопамять
	xor ax,ax		
	mov al,dh		;y верхний левый угол
	mov cx,160
	mul cx
	pop dx			;восстанавливаем DL
	xor cx,cx
	mov cl,dl
	add ax,cx
	add ax,cx
	mov di,ax               ;в DI возвращает смещение этого угла
	pop cx ax
	cld			;как правило,после вызова GetStart-строк.опер.
	ret
	
GetBlock:			;копирует в буфер участок экрана
	push si di dx bx ds ax	;AX-сегмент буфера приемника
	inc bh                  ;DX-верхний левый угол,в BH-высота,BL-длина
	add bl,2
	mov ax,0B800h
	mov ds,ax		;настройка источника
	call GetStart		;
	pop es			;буфер приемника
	xchg si,di
	mov di,0
	xor ax,ax
	mov al,bh		;число столбцов участка экрана	
	mov bh,0
GB100:				;цикл по строкам участка экрана
	xor cx,cx
	mov cl,bl
	rep movsw		;переслали очередную строку экрана в буфер
	dec ax
	cmp ax,0
	je short GB200		;скопировали весь участок экрана
	add si,160		;перейти к следующей строке участка экрана
	sub si,bx
	sub si,bx
	jmp short GB100	
GB200:	pop ds
GB300:	pop bx dx di si
	ret

PutBlock:			;копирует буфер в видеопамять
	push si di dx bx ds		;AX-сегмент буфера приемника		                            	
	inc bh			;DX-верхний левый угол,в BH-высота,BL-длина
	add bl,2
	mov ds,ax		;buffer
	mov si,0
	call GetStart		;
	xor ax,ax
	mov al,bh		;число столбцов участка экрана	
	mov bh,0
PB100:				;цикл по строкам участка экрана
	xor cx,cx
	mov cl,bl
	rep movsw		;переслали очередную строку экрана в буфер
	dec ax
	cmp ax,0
	je short GB200		;скопировали весь участок экрана
	add di,160		;перейти к следующей строке участка экрана
	sub di,bx
	sub di,bx
	jmp short PB100	

Win1:	push si			;требует в DH-y1,DL-x1,BH-высота,BL-длина
	pushf			;сохраняем флаг CF-признак кнопки
	mov ver,179
	mov hor,196
	mov ulf,218
	mov urt,191
	mov dlf,192
	mov drt,217 
	jmp short W300
Win2:   push si
	pushf			;сохраняем флаг CF-признак кнопки
	mov ver,186
	mov hor,205
	mov ulf,201
	mov urt,187
	mov dlf,200
	mov drt,188 
	cmp bh,3
	jb W800				;слишком маленькая высота
	cmp bl,3
	jb short W800				;слишком маленькая длина
W300:
	call GetStart
	mov al,ulf
	stosb	
	inc di
	mov al,hor		
	xor cx,cx
	mov cl,bl
	sub cl,2
W400:
	stosb
	inc di
	loop W400
	mov al,urt
	stosb
	add di,159
	mov al,ver
	mov cl,bh
	sub cl,2
W500:
	stosb
	add di,159
	loop W500
	mov al,drt
	std
	stosb
	dec di
	mov cl,bl
	sub cl,2
	mov al,hor
W600:
	stosb 
	dec di
	loop W600
	mov al,dlf		
	stosb
	mov al,ver		
	mov cl,bh
	sub cl,2
W700:
	sub di,159
	stosb
	loop W700
	popf				;вынимаем флаг CF-признак кнопки
	jc short W800
	sub di,155
	mov al,5Bh			; открывающая скобка
	cld
	stosb
	push ds
	mov ax,0B800h
	mov ds,ax
	inc di
	mov ax,di
	mov si,ax
	lodsw   			;слово
	and ah,11111010B		;зеленый цвет кнопки
	mov al,0FEh                     ;кнопка
	stosw
	mov al,5Dh                      ;закрыв.скобка
	stosb
	pop ds 
W800:	pop si
	ret

end