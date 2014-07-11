.model small
.386
.code

PUBLIC MouseShow,MouseInit,MouseHide,MouseSetPos,GetMouseInfo,MouseButtons
PUBLIC MouseRelease,MouseWhere

MouseShow:
	mov ax,1
	int 33h
	ret

MouseHide:
	mov ax,2
	int 33h
	ret

MouseInit:
 	mov ax,0
	int 33h
	ret

MouseSetPos:			;в CX - горизонтальная,в DX - вертикальная
	mov ax,04h
	int 33h
	ret

GetMouseInfo:		;возвр.: в AH - координата по Y ,в AL - по X	
	push dx bx cx   ;устанавливает CF если нажата левая кнопка
	mov ax,03h		
	int 33h			
	push bx			;сохраняем байт статуса
	mov bl,8                ;высота 
	mov ax,dx
	div bl
	mov bh,al		;в BH - координата по Y
	mov ax,cx
	div bl			;в AL - координата по X
	mov ah,bh		;в AH - координата по Y
	pop bx                  ;восстанавливаем байт статуса
	test bl,1
	jne short GMI100
	pop cx bx dx
	clc
	jmp short GMI200		
GMI100:	pop cx bx dx
	stc
GMI200:	ret
	
MouseButtons:			;нулевой бит в BL=1  -  нажата левая кнопка
	push dx			;первый бит в BL=1  -  нажата правая кнопка
	push cx
	mov ax,5		;в AH - координата по Y ,в AL - по X	
	mov bx,0
	int 33h 		;CX-X,DX-Y,AX-статус (0 и 1-й биты)
	xor bx,bx
	test al,0
	je MB100
	mov bl,8                ;высота 
	mov ax,dx
	div bl
	mov bh,al		
	mov ax,cx
	div bl
	mov ah,bh
	mov bl,1	
MB100:
	pop cx
	pop dx	
	ret

MouseRelease:
	mov ax,6
	mov bx,0
	int 33h
	ret

MouseWhere:				;в AH - координата по Y ,в AL - по X	
	mov ax,3
	int 33h
	mov bl,8
	mov ax,dx
	div bl
	mov bh,al		
	mov ax,cx
	div bl
	mov ah,bh
	ret
end