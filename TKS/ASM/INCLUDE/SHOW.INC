;;show.inc
;;макроопределение для визуализации регистров al, ah, ax, eax
;;на входе:
;;arg_n - имя одного из регистров al,ah,ax,eax
;;n_poz - номер позиции на экране, по умолчанию - 1000
Show	MACRO	arg_n,n_poz:=<1000>
LOCAL	main_part,disp,pause,template,VideoBuffer,p_mode,m1,m2
;;переход на начало блока команд,
;;чтобы избежать выполнения данных
	jmp	main_part
;;некоторые константы и переменные
FALSE	equ	0	;;ложь
TRUE	equ	0ffffh	;;истина
?reg8bit=false	;;флаг того, что передан регистр ah или al
?reg16bit=false	;;флаг того, что передан регистр ax
?reg32bit=false	;;флаг того, что передан регистр eax
;;таблица-шаблон для xlat
template	db	'0123456789ABCDEF'
;;адрес видеобуфера - для прямого вывода на экран
VideoBuffer	dw	0b800h

main_part:		;;начало блока команд
;;сохранение в стеке используемых регистров:
;;eax, ebx, ecx, edx, edi, ds, es
	push	ax
	push	bx
	push	cx
	push	dx
	push	di
	push	ds
	push	es
	push	cs
	pop	ds
;;в bx - адрес таблицы-шаблона (для xlat)
	lea	bx,cs:template
	xor	cx,cx	;очистка cx
;;начало блока определения того,
;;какой регистр был передан макросу
IFIDNI	<al>,<&arg_n>	;;если аргумент=al или AL,
?reg8bit=TRUE		;;установка флага 8-битового регистра
	mov	ah,al
ENDIF
;;передан не al или AL
IFIDNI	<ah>,<&arg_n>	;;если аргумент=ah или AH,
?reg8bit=TRUE		;;установка флага 8-битового регистра
ENDIF
;;передан не AH или ah
IFIDNI	<ax>,<&arg_n>	;;если аргумент равен ax или AX,
?reg16bit=TRUE		;;установка флага 16-битового регистра
ENDIF
;;передан не ah, AH ,ax или AX
IF	(?reg8bit)	;;если передан al или ah
	push	ax
	and	ah,0f0h	;;обращение к старшей четвёрке битов ah
	shr	ax,12	;;сдвиг битов в начало (16-4=12)
	xlat		;;трансляция таблицы-шаблона
;;помещение символа из al в edi
	mov	di,ax
	shl	di,8
	inc	cx
	pop	ax
	and	ax,0f00h	;;обращение к младшей тетраде ah
	shr	ax,8	;;сдвиг битов в начало (16-(4+4)=8)
	xlat		;;трансляция таблицы-шаблона
	or	di,ax	;;помещение очередного символа в di
	shl	di,16
	inc	cx
ENDIF
IF	(?reg16bit)	;;если передан ax или ax
;;начало обработки значения регистра ax
	push	ax
;;обращение к старшей четвёрке битов ax
	and	ax,0f000h
	shr	ax,12	;;сдвиг битов в начало (16-4=12)
	xlat		;;трансляция таблицы-шаблона
;;помещение символа из al в старшую
;;тетраду старшей половины edi
	mov	di,ax
	shl	di,8
	inc	cx
	pop	ax
	push	ax
;;обращение ко второй четвёрке битов ax
	and	ax,0f00h
	shr	ax,8	;;сдвиг битов в начало (16-(4+4)=8)
	xlat		;;трансляция таблицы-шаблона
;;помещение очередного символа в младшую
;;тетраду старшей половины edi
	or	di,ax
	shl	di,8
	inc	cx
	pop	ax
	push	ax
	and	ax,0f0h	;;обращение к третьей четвёрке битов в ax
	shr	ax,4	;;сдвиг битов в начало (16-(4+4+4)=4)
	xlat		;;трансляция таблицы-шаблона
	or	di,ax	;;помещение очередного символа в edi
	shl	di,8
	inc	cx
	pop	ax
	and	ax,0fh	;;обращение к младшей четвёрке битов ax
	xlat		;;трансляция таблицы-шаблона
	or	di,ax	;;помещение очередного символа в edi
	inc	cx
ENDIF
;;для реального режима
;;загружаем в es адрес видеопамяти
	mov	ax,cs:VideoBuffer
	mov	es,ax
p_mode:
;;для реального и защищенного режимов
;;количество циклов в cx
	cld		;;просмотр вперед - для stosw
	xchg	di,bx
	mov	di,n_poz	;;начальная позиция для
			;;вывода на экран
disp:
	cmp	cx,4
	jle	m1	;переход, если ecx<=4
	shld	ax,edx,8
	shl	dx,8
	jmp	m2
m1:
	shld	ax,ebx,8
	shl	bx,8
m2:
	mov	ah,71h	;;байт-атрибут
	stosw		;;копирование значения ax
			;;в es:di (видеобуфер)
	loop	disp	;;повтор цикла cx раз
	mov	cx,65535	;;задержка
pause:	loop	pause
;;переопределение/восстановление из стека
;;используемых регистров
	pop	es
	pop	ds
	pop	di
	pop	dx
	pop	cx
	pop	bx
	pop	ax
ENDM

