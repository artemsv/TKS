.model small			;  ��� ᮧ����� :12.12.02.
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

;������� ���� ��ਡ�⮢ ��אַ㣮�쭮� ������ �࠭� � ᮮ⢥��⢨� � ��᪮�
;���� ��ਡ�⮢ �����࣠���� ����樨 AND c ���⮬ � AL � ����樨 OR � AH
PUBLIC ChangeAtribut,Shadow,Win1,Win2,PutBlock,GetBlock,FillBackBlock,GetStart

ChangeAtribut:			;� DX ���孨� ���� 㣮�,� BH-����,BL-�����
	push si di dx bx ds cx 	;���� ��ਡ�⮢ AND AL + ���� ��ਡ�⮢ OR AH
	call GetStart           ;����ࠨ���� DI � ES � ᮮ⢥�ᢨ� � DX
	mov dx,ax		;��࠭塞 ���� ��������� ��ਡ�⮢
	push di
	pop si			;
	push es
	pop ds                  ;ᥣ���� ���筨��-�����������
CA200:
	xor cx,cx
	mov cl,bl		;����� ��।��� ��ப�
	jcxz CA400
CA300:
	lodsw				;����㧨�� ᫮�� �� ����������
	and ah,dl			;�����塞 ���� ��ਡ�⮢ � ᮮ�.
	or ah,dh			;� ��᪮�
	stosw                           ;��࠭��� ���������� ᫮��
	loop CA300
	dec bh                          ;���稪 ��ப ��אַ�.���⪠ �࠭�
	cmp bh,0
	je short CA400
	add di,160			;���室 � ᫥���饩 ��ப� �࠭�
	xor cx,cx
	mov cl,bl
	sub di,cx
	sub di,cx
	push di
	pop si	
	jmp short CA200
CA400:	pop cx
	jmp GB200
	                        	
Shadow:				;� DX ���孨� ���� 㣮�,� BH-����,BL-�����
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

;�������� ᫮��� ��אַ㣮��� ���⮪ ����������

FillBackBlock:			;� DX ���孨� ���� 㣮�,� BH-����,BL-�����
	push si di dx bx cx	;� AX-���� ��ਡ�⮢+ᨬ����� ����
	call GetStart	
	mov dh,bh		;�᫮ �⮫�殢 ���⪠ �࠭�	
	mov bh,0
FBB100:				;横� �� �⮫�栬 ���⪠ �࠭�
	xor cx,cx
	mov cl,bl		;����� ���⪠
	rep stosw		;�뢥�� ��ப�
	dec dh			;㬥����� ���稪 ��ப
	cmp dh,0
	je short FBB200		;�뢥�� �� ��ப�
	add di,160		;��३� � ᫥���饩 ��ப� ���⪠ �࠭�
	sub di,bx
	sub di,bx
	jmp short FBB100	
FBB200:	pop cx
	jmp short GB300

;����ࠨ���� ES:DI �� ᬥ饭�� �窨 DH,DL (Y,X) � ����������

GetStart:			;� DX - ���孨� 㣮�
	push ax cx dx		;������� MUL ����� DX !?
	mov ax,0B800h
	mov es,ax    		;����ன�� ᥣ���� �ਥ�����-�����������
	xor ax,ax		
	mov al,dh		;y ���孨� ���� 㣮�
	mov cx,160
	mul cx
	pop dx			;����⠭�������� DL
	xor cx,cx
	mov cl,dl
	add ax,cx
	add ax,cx
	mov di,ax               ;� DI �����頥� ᬥ饭�� �⮣� 㣫�
	pop cx ax
	cld			;��� �ࠢ���,��᫥ �맮�� GetStart-��ப.����.
	ret
	
GetBlock:			;������� � ���� ���⮪ �࠭�
	push si di dx bx ds ax	;AX-ᥣ���� ���� �ਥ�����
	inc bh                  ;DX-���孨� ���� 㣮�,� BH-����,BL-�����
	add bl,2
	mov ax,0B800h
	mov ds,ax		;����ன�� ���筨��
	call GetStart		;
	pop es			;���� �ਥ�����
	xchg si,di
	mov di,0
	xor ax,ax
	mov al,bh		;�᫮ �⮫�殢 ���⪠ �࠭�	
	mov bh,0
GB100:				;横� �� ��ப�� ���⪠ �࠭�
	xor cx,cx
	mov cl,bl
	rep movsw		;���᫠�� ��।��� ��ப� �࠭� � ����
	dec ax
	cmp ax,0
	je short GB200		;᪮��஢��� ���� ���⮪ �࠭�
	add si,160		;��३� � ᫥���饩 ��ப� ���⪠ �࠭�
	sub si,bx
	sub si,bx
	jmp short GB100	
GB200:	pop ds
GB300:	pop bx dx di si
	ret

PutBlock:			;������� ���� � �����������
	push si di dx bx ds		;AX-ᥣ���� ���� �ਥ�����		                            	
	inc bh			;DX-���孨� ���� 㣮�,� BH-����,BL-�����
	add bl,2
	mov ds,ax		;buffer
	mov si,0
	call GetStart		;
	xor ax,ax
	mov al,bh		;�᫮ �⮫�殢 ���⪠ �࠭�	
	mov bh,0
PB100:				;横� �� ��ப�� ���⪠ �࠭�
	xor cx,cx
	mov cl,bl
	rep movsw		;���᫠�� ��।��� ��ப� �࠭� � ����
	dec ax
	cmp ax,0
	je short GB200		;᪮��஢��� ���� ���⮪ �࠭�
	add di,160		;��३� � ᫥���饩 ��ப� ���⪠ �࠭�
	sub di,bx
	sub di,bx
	jmp short PB100	

Win1:	push si			;�ॡ�� � DH-y1,DL-x1,BH-����,BL-�����
	pushf			;��࠭塞 䫠� CF-�ਧ��� ������
	mov ver,179
	mov hor,196
	mov ulf,218
	mov urt,191
	mov dlf,192
	mov drt,217 
	jmp short W300
Win2:   push si
	pushf			;��࠭塞 䫠� CF-�ਧ��� ������
	mov ver,186
	mov hor,205
	mov ulf,201
	mov urt,187
	mov dlf,200
	mov drt,188 
	cmp bh,3
	jb W800				;᫨誮� �����쪠� ����
	cmp bl,3
	jb short W800				;᫨誮� �����쪠� �����
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
	popf				;�뭨���� 䫠� CF-�ਧ��� ������
	jc short W800
	sub di,155
	mov al,5Bh			; ���뢠��� ᪮���
	cld
	stosb
	push ds
	mov ax,0B800h
	mov ds,ax
	inc di
	mov ax,di
	mov si,ax
	lodsw   			;᫮��
	and ah,11111010B		;������ 梥� ������
	mov al,0FEh                     ;������
	stosw
	mov al,5Dh                      ;�����.᪮���
	stosb
	pop ds 
W800:	pop si
	ret

end