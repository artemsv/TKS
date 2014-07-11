.model small		;файловый диалог  08.01.03.
.386
extrn Win2:proc,ChangeAtribut:proc,GetBlock:proc,PutBlock:proc,CaretHide:proc
extrn CaretShow:proc,MouseHide:proc,MouseShow:proc,FillBackBlock:proc
extrn Shadow:proc,GetStart:proc,FillByte:proc,Pause:proc,CopyFiles:proc
extrn buf:word,OutStr:proc,ChangeAtribut:proc,KeyPressed:proc,HandlerStd:proc
extrn GetMouseInfo:proc,GetCurDir:proc,OutDB:proc,file:byte,ClearFileName:proc
extrn Window:proc,GetMem:proc,FreeMem:proc,SetCurDir:proc,FillWord:proc
extrn FillByte:proc,Len:proc
PUBLIC FileDialog,fileTMP
.data
	extrn initPtr:word,handlerPtr:word
	dir	db	260 dup (67)
	norm	dw	7400h
	cur 	dw      2E00h
	fileTMP	db 	12 dup(5Eh)
	byte3	db	?
.code

IsFile:					;является ли объект в fileTMP файлом
	push dx bx
	mov cx,11111B
	lea dx,fileTMP
	mov ah,4Eh
	int 21h				;FindFirst
	mov ah,2Fh
	int 21h				;get current DTA
	cmp byte ptr es:[bx+15h],10h	
	je short IF100
	stc
	jmp short IF200
IF100:	clc
IF200:	pop bx dx 
	ret
	
FileDialogInit:
	push dx 
	add dx,010Dh
	call VertLine
	mov dx,062Dh
	call VertLine
	pop dx 
	mov cx,11111B
	call CopyFiles
	xor bp,bp				;первый прорисовываемый файл
	call DrawFiles
	call SelectFirst
	call UpdateDirName
	ret
	
ClearFileWindow:			;очищает окно выбора файлов
	push dx bx
	mov al,20h			;заполняем пробелами
	mov ah,byte ptr norm+1
	mov dx,0614h
	mov bx,0E0Ch
	mov cx,3
CFW100:	call FillBackBlock		;очищает очередную панель
	add dl,13
	loop CFW100
	pop bx dx
	ret

SelectFirst:				;выделяет первый пункт
	call MouseHide
	mov dx,0614h
	mov bx,010Ch
	mov ax,cur
	call ChangeAtribut		;выделяем первый пункт
	call MouseShow
	ret

DeleteSelect:				;снимает выделение с текущего пункта
	call MouseHide
	mov ax,norm            
	call ChangeAtribut	
	call MouseShow	
	ret

GoParentDir:				;установить текущим родительский
	push dx ds
	pop es
	lea di,dir
	cld
	mov al,0
	mov cx,64
	repne scasb			;ищем конец имени текущего
	std
	mov al,'\'
	mov cx,64
	repne scasb                     ;ищем начало текущего каталога
	cmp byte ptr es:[di],':'
	jne short GPD100			;родительский-корневой
	inc di
GPD100:	mov byte ptr es:[di+1],0
	lea dx,dir
	call SetCurDir
	pop dx
	ret
	
GoSubDir:				;войти в подкаталог
	lea di,dir
	push dx ds
	pop es 
	cld
	mov al,0
	mov cx,64
	repne scasb			;ищем конец имени текущего
	cmp byte ptr es:[di-2],'\'	;текущий-корневой?
	je short GSD100
	inc di
GSD100:	dec di
	mov byte ptr es:[di-1],'\'	;в этот конец добавляем черту
	lea si,fileTMP			;смещение в DS (DS=FS!)
	mov cx,12			;максимальная длина имени каталога
GSD160:	movsb				;цикл копирования имени подкаталога
	cmp byte ptr [si-1],0		;из временного буфера в FS:0000 в dir
	je short GSD160
	loop GSD160
GSD200:	lea dx,dir
	call SetCurDir
	pop dx
	ret	
			
UpdateDirName:				;обновляет строку каталога
	push bp dx bx si
	lea si,dir
	call GetCurDir
	mov dx,0519h
	mov cx,20h
	mov ah,byte ptr norm+1
	mov al,205
	call FillWord                   ;обновим место надписи имени каталога
	call Len			;CX-длина строки в SI
	push cx
	mov cx,3			;'D:\' - 3 символа
	mov bh,01
	mov bl,cl
	mov ax,7EFFh
	call ChangeAtribut
	mov cx,3
	call OutDB			;вывели стандартную часть пути
	add dl,3
	;теперь надо знать,уместится ли остальная часть пути?
	pop cx				;длина всего пути
	sub cx,3			;длина оставшегося пути
	cmp cx,22			;22-длина оставшегося места
	jb short UDN100		;места хватит
	mov bp,cx
	sub bp,28			;BP-непомещающийся остаток
	mov bh,01
	mov bl,3
	mov ax,7EFFh
	call ChangeAtribut
	mov al,'.'
	mov cx,3			;2 точки
	call FillByte			;3 точки вместо непоместившегося пути
	add dl,3
	add si,bp
UDN100:	mov bl,cl
	mov bh,01
	mov ax,7EFFh
	call ChangeAtribut
	clc			;сбросим CF,чтобы не учтиывать атрибут в AL
	call OutDB		
	pop si bx dx bp
	ret
	
GetPunct:				;возвращает в AH номер текущего пункта
	mov ah,dh
	sub ah,05h
	cmp dl,14h
	je short GP200				;первая панель
	cmp dl,21h
	jne short GP100				;третья панель
	add ah,14
	jmp short GP200
GP100:	add ah,28
GP200:	ret

GetCoord:		;преобразует номер пункта в AH в координату в DX
	cmp ah,14
	ja short GC100				;не в первой панели
	add ah,05h
	mov dl,14h
	jmp short GC300
GC100:	cmp ah,28
	ja short GC200
	sub ah,9
	mov dl,21h
	jmp short GC300
GC200:	sub ah,23
	mov dl,2Eh
GC300:	mov dh,ah
	ret

DrawFiles:	 	;прорисовывает все файлы в буфере в FS:000E
	mov si,12				;слово-кол-во файлов	
	push dx si bx ds fs			;BP-столько фалов пропустить
	pop ds					;DS:000E-буфер
	mov bx,word ptr [si]			;BX-количество файлов
	mov dx,0614h
	mov byte3,dl
	add si,2                                ;пропускаем слово-кол-во файлов
	xor ah,ah				;счётчик символов имени файла
DF100:	lodsb					;AL-символ имени
	or al,al
	je short DF300				;напоролись на конец файла
	cmp al,'.'
	je short DF200
DF150:	mov cx,1
	call FillByte
	inc di
	inc dl
	inc ah
	jmp short DF100
DF200:						;цикл заполнения пробелами
	or ah,ah
	je short DF150				;это первая точка род.каталога
	cmp byte ptr [si-2],2Eh
	je short DF150				;это вторая точка род.каталога
	mov al,32
	mov cx,1
	call FillByte
	inc di
	inc dl
	inc ah
	cmp ah,9
	jb short DF200
	jmp short DF100
DF300:	
	xor ah,ah				;счетчик символов имени файла
	dec bx
	jz short DF400				;файлы кончились
	mov dl,byte3
	inc dh					;позиция по Y в окне
	cmp dh,14h
	jb short DF100
	cmp dl,2Eh
	je short DF400				;это была последняя панель
	mov dh,06h
	add dl,0Dh
	add byte3,0Dh
	jmp short DF100
DF400:	pop ds bx si dx
	ret
	
VertLine:					;чертит вертикальную линию
	push dx
	mov al,'│'
VL100:	mov cx,1
	call FillByte
	inc dh
	cmp dh,14h
	jb short VL100
	pop dx
	ret

GetSelectFile:	;копирует в 12-байтовый буфер fileTMP имя выбранного файла
		;из главного буфера со всеми именами в FS:000E
	call GetPunct			;AH-номер текущего пункта
	mov al,0
	xchg al,ah
	add bp,ax			;теперь этот номер в BP
	mov al,13			;признак конца имени файла
	mov cx,bp			;счётчик концов имён файлов ;)
	dec cx
	mov si,14			;SI-начало главного буфера с именами
	push bp ds ds fs
	pop ds es			;DS-сегмент буфера с именами файлов 
	jcxz GSF300			;это первый файл-сразу на копирование
GSF100:                                 ;цикл поиска начала выбр-го файла
	cmp byte ptr [si],0
	jne short GSF200
	inc si				;пропустим термин.ноль
	dec cx
	jcxz GSF300			;нашли имя выбранного файла
GSF200:	
	inc si	
	jmp short GSF100
GSF300:                 		;теперь в SI - имя этого файла
	lea di,fileTMP
	cld
GSF400:	lodsb
	stosb
	or al,al
	jne GSF400
	pop ds bp
	ret
	
FileDialog:
	mov bx,1000
	call GetMem
	mov fs,ax				;память для буфера имён файлов
	mov dx,0513h
	mov bx,1028h
	mov ah,byte ptr norm+1
	mov al,20h
	lea di,FileDialogInit
	mov initPtr,di
	lea di,FileDialogHandler
	mov handlerPtr,di
	clc
	call Window
	ret					;AX-код выхода

FileDialogHandler:		;обработчик событий для окна выбора файлов
	jc short SF150				;от мыши
	cmp ah,1
	je short SF300				;нажата расширенная клавиша
	cmp al,13				;нажата клавиша Enter?
	jne short SF140
	call UpdateDirName
	call GetSelectFile
	call UpdateDirName
	cmp byte ptr [fileTMP],'.'		;это не корневой каталог?
	je short SF120				;это файл или подкаталог
	call IsFile				;если в fileTMP файл - CF=1
	jc short SF136				;это файл
	call GoSubDir	
	jmp short SF130
SF120:
	call GoParentDir
SF130:
	call UpdateDirName
	mov cx,11111B				;атрибуты файлов
	call CopyFiles
	call ClearFileWindow
	xor bp,bp			;первый прорисовываемый файл - первый ;)
	call DrawFiles
	call SelectFirst
	clc				;окно закрывать не надо
	jmp SF1300
SF136:
	xor ax,ax			;код выхода - OK
	jmp SF1250		
SF140:
	cmp al,27	
	jne SF1200
	stc			        ;окно надо закрыть
	jmp SF1250
SF150:
	clc				
	jmp SF1200
SF300:  
	cmp al,72		;стрелка вверх
	jne short SF600
	call DeleteSelect
	cmp dh,06h		;верхняя строка?
	je short SF400
	dec dh
	jmp short SF1000
SF400:	
	cmp dl,14h		;первая панель?
	je short SF500
	sub dl,0Dh		;переходим на предыдущую панель
	mov dh,13h		;нижний пункт
	jmp short SF1000	
SF500:
	or bp,bp		;прорисовывается-ли первый файл в списке
	je short SF1000		;да-ничего нельзя сделать
	dec bp                  ;прорисовка на один файл раньше
	jmp short SF1100	
SF600:
	cmp al,77		;стрелка вправо
	jne short SF700
	call DeleteSelect
	cmp dl,2Eh		;последняя панель?
	je SF1200		;да-ничего нельзя сделать
	call GetPunct		;получим в AH номер пункта
	add ah,14		;получим номер требуемого пункта
	mov cx,word ptr fs:[12]
	or ch,ch		
	jnz short SF610         ;файлов больше чем 255-с CL сравнивать нельзя
	cmp cl,ah
	jae short SF610		;файлов хватит
	mov ah,cl		;файлов не хватит-выделяем последний файл
SF610: 
	call GetCoord		;получаем координаты нового пункта
	jmp short SF1000
SF700:
	cmp al,80		;стрелка вниз
	jne SF1200
	call DeleteSelect
	call GetPunct		;AH-номер текущего пункта
	cmp ah,42		;всего имеется 42 пункта 
	je short SF1000		;временно нету
	inc ah			;номер требуемого пункта	
	mov cx,word ptr fs:[12]	;CX-количество файлов
	or ch,ch
	jne short SF710		;файлов больше чем 255
	cmp cl,ah
	jae short SF710		;файлов хватит
	dec ah			;это был последний файл-возврат
SF710:
	call GetCoord	
	jmp short SF1000	
SF1000:
	call MouseHide
	mov ax,cur            	;маска
	call ChangeAtribut
	call MouseShow
	jmp SF1200
SF1100:	
 	call DrawFiles
SF1200:	
	call HandlerStd
	jnc SF1300
SF1250:	
	push fs
	pop es
	call FreeMem
	stc			;закрыть
SF1300:	
	ret
end