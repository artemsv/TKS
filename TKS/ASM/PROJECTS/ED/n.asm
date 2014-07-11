;модуль меню
.model small			;		дата создания:  24.12.02.
.data
	men db 	7,12,3,'New',12,'Open...   F3',12,'Save      F2'
	    db  10,'Save As...',5,'Print',9,'DOS Shell',12,'Exit   Alt+X'
.code
  	extrn GetStart:proc,GetBlock:proc,FillBackBlock:proc,Win1:proc
  	extrn Shadow:proc,GetMem:proc,ReadKey:proc,OutDB:proc,ChangeAtribut:proc
  	extrn CaretHide:proc,CaretShow:proc,KeyPressed:proc,GetMouseInfo:proc
	extrn PutBlock:proc
	extrn buf:word

PUBLIC PopupMenu,Menu

Menu:	push si
	mov dx,0100h
	lea si,men
	call PopupMenu
	pop si
	ret

PopupMenu:		;DX-угол,SI-строка пунктов
	call CaretHide
	push dx
	push si			;сохраняем начало строки описания пунктов
	call GetStart		;
	mov bh,[si]		;высота меню
	add bh,2                ;2 символа на рамку
	mov bl,[si+1]           ;длина самого длинного пункта
	add bl,2		;2 символа на рамку с двух сторон
	push bx			;сохраняем размеры меню
	mov ax,buf		;глобальный буфер
	call GetBlock
	mov ax,7020h
	call FillBackBlock
	stc
	call Win1
	call Shadow	
	pop bx			;неясные движения,да?-всего навсего 
	pop si			;выковыриваем из стека SI(он под BX)
	push bx
	mov al,[si]		;счётчик пунктов
	inc dl			;координата по X первого пункта
	add si,2		;смещение строки первого пункта
PM100:
	xor cx,cx
	mov cl,byte ptr [si]	;длина очередного пункта
	inc dh			;координата Y пункта меню
	inc si			;пропускаем байт длины
	call OutDB
	dec al			;счетчик пунктов
	or al,al
	je short PM200		;вывели все пункты
	jmp short PM100
PM200:
	pop bx
	pop dx			;восстанавливаем координаты угла
	push dx			;пересохранили угол меню
	push bx			;пересохранили размеры меню
	add dx,0101h		;координаты первой строки меню
	mov ch,dh		;начальная координата пункта меню
	mov cl,dh		
	add cl,bh
	sub cl,3                ;CL-максим.коорд.,кот может иметь пункт меню
	mov bh,1                ;высота пункта меню
	sub bl,2                ;длина пункта меню
	mov ax,002Fh            ;маска
	call ChangeAtribut	;выделили первую строку меню
PM300:
	call GetMouseInfo
	jc short PM400
	call KeyPressed	
	jz short PM300
	cmp ah,1
	je short PM500		;нажата расширенная клавиша
	cmp al,13
	je short PM400		;нажата клавиша Enter
	cmp al,27	
	je short PM400
	jmp short PM300
PM400:
	pop bx
	pop dx
	mov ax,buf
	call PutBlock		;восстанавливаем экран
	call CaretShow
	ret	
PM500:
	cmp al,72		;стрелка вверх
	je short PM800
	cmp al,80               ;стрелка вниз
	je short PM600
	jmp short PM300
PM600:
	mov ax,70FFh            
	call ChangeAtribut	;снимем выделение текущего пункта меню
	cmp dh,cl		;CL-максим.коорд.,кот может иметь пункт меню
	je short PM700		;это самый нижний пункт
	inc dh
	jmp short PM1000
PM700:
	mov dh,ch
	jmp short PM1000
PM800:
	mov ax,70FFh            
	call ChangeAtribut	;снимем выделение текущего пункта меню
	cmp dh,ch		;CH-начальн.коорд.,кот может иметь пункт меню
	je short PM900		;это самый верхний пункт
	dec dh
	jmp short PM1000
PM900:
	mov dh,cl
PM1000:
	mov ax,002Fh            ;маска
	call ChangeAtribut
	jmp PM300
end