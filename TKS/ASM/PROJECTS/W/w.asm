.model tiny
  extrn Win1:proc,ReadKey:proc,Cls:proc,Win2:proc,WhereXY:proc,GotoXY:proc
  extrn ShowMouse:proc,InitMouse:proc,KeyPressed:proc
.code
.startup
	call InitMouse
	call ShowMouse
;	call ReadKey
	mov dx,0000h
	mov bx,1040h
	call Win2
key:    call WhereXY	
	call KeyPressed
	jz key
	jne key
	cmp ah,80
	je down
	cmp ah,72
	je up
	cmp ah,75
	je left
	cmp ah,77
	je right
	cmp ah,68
	je quit
	jmp key
down:
 	inc dh
	call GotoXY
	jmp key
up:
	dec dh
  	call GotoXY
	jmp key
left:
	dec dl
  	call GotoXY
	jmp key
right:
	inc dl
  	call GotoXY
	jmp key

quit:
	mov ah,4ch
	int 21h
	
end 