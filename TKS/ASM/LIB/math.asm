.model small			;����� ��⥬���᪨� ��楤��  16.01.03.
.586
.code

PUBLIC Val

Val:			;�८�ࠧ�� �᫮ � EAX � ��ப� � SI,CX - ���-�� ���
        push edx ebx ds si
	pop di es
	cmp eax,100000
	jb short V10
	mov edx,0
	mov ebx,100000
	div ebx				;EDX-���⮪,EAX-��⭮�
	add al,30h
	stosb
	mov eax,edx
	and eax,0000FFFFh
	shr edx,16
	jmp short V20
V10:	mov edx,eax
	shr edx,16
V20:	cmp ax,10000
	jb short V100
	mov bx,10000
	div bx				;AL-�᫮ ����⪮� �����
	add al,30h
	stosb
	mov ax,dx			;����頥� ���⮪
	jmp short V200
V100:	cmp si,di
	je short V200
	mov byte ptr [di],30h
	inc di
V200:	cmp ax,1000
	jb short V300
	mov dx,0
	mov bx,1000
	div bx
	add al,30h
	stosb
	mov ax,dx			;����頥� ���⮪
	jmp short V400
V300:	cmp si,di
	je short V400
	mov byte ptr [di],30h
	inc di
V400:	cmp ax,100
	jb short V500
	mov bl,100
	div bl
	add al,30h
	stosb
	mov al,ah			;����頥� ���⮪
	xor ah,ah
	jmp short V600
V500:	cmp si,di
	je short V600
	mov byte ptr [di],30h
	inc di
V600:	cmp al,10
	jb short V700
	mov bl,10
	div bl
	add al,30h
	stosb
	mov al,ah
	add al,30h
	stosb
	jmp short V800
V700:	cmp si,di
	je short V780
	mov byte ptr [di],30h
	inc di
V780:	add al,30h
	stosb
V800:	mov cx,di
	sub cx,si
	pop ebx edx
	ret
end	
		