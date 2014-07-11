.model tiny
.code
.startup
	jmp start
	msg db 'Настоящяя программа!!!',13,10,'$'
	db 1000 dup(65)
start:
	lea dx,msg
	mov ah,9
	int 21h
	mov ah,4ch
	int 21h
end