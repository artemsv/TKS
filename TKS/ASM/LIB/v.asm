.model small	;����� ���㠫��� ��ꥪ⮢	23.01.03.
.386
.data

	handlerPtr	dw	0	;���� ��楤��� ��ࠡ�⪨ ᮡ�⨩
	initPtr		dw	0	;���� ��楤��� ���樠����樨

	extrn buf:word

PUBLIC InitStd,Window,Button,initPtr,HandlerStd,handlerPtr

.code

extrn GetBlock:proc,FillBackBlock:proc,Win2:proc,Shadow:proc,GetMouseInfo:proc
extrn OutDB:proc,FillWord:proc,MouseHide:proc,MouseShow:proc,KeyPressed:proc
extrn CaretHide:proc,CaretShow:proc,PutBlock:proc

HandlerStd:			;��ࠡ��뢠�� ⮫쪮 Esc � 饫箪 �� ������
	jnc short HS100		;DX-㣮�,BX-ࠧ���,AX-����.���(CF=1)��� ���
	cmp ah,dh		;������
	jne short HS300
	mov cl,dl
	mov ch,dl
	add cl,2
	add ch,4
	cmp al,ch
	ja short HS300
	cmp al,cl
	jb short HS300
	mov ax,3			;���� ��室�:0-Ok,1-Yes,2-No,3-Cancel
	jmp short HS200
HS100:	cmp ah,1
	je short HS300
	cmp al,27
	jne short HS300
	mov ax,3				;Cancel
HS200:	stc					;CF=1 - ���� �������
	jmp short HS400
HS300:	clc
HS400:	ret

InitStd:
	ret

Window:						;DX-㣮�,BX-ࠧ���,AX-��ਡ��
	push dx bx 
	pushf					;CF-�ਧ��� ������
	push ax					;AX-��ਡ�� ���������� �࠭�
	call MouseHide
	call CaretHide
	mov ax,buf				;�������� ����
	call GetBlock
	pop ax
	call FillBackBlock
	popf                                    ;����⠭�������� CF
	call Win2
	call Shadow
	call word ptr [initPtr]		;��ࠬ����:DX-㣮�,BX-ࠧ����
	call MouseShow
W100:
	call GetMouseInfo
	jc short W300
	call KeyPressed	
	jz short W100
W200:	clc				;CF ��襭-ᮡ�⨥ �� ����������
W300:	call word ptr [handlerPtr]
	jnc short W100			;CF ��襭-���� ����뢠�� �� ����
	pop bx dx
	push ax				;��࠭塞 ��� ��室�
	mov ax,buf
	call PutBlock
	call CaretShow	
	pop ax
	ret

Button:						;DX-㣮�,SI-��ப�
	jc short B100
	mov al,20h				;���筠� ������
	jmp short B200
B100:	mov al,2Fh				;�뤥������ ������
B200:	push cx bx dx
	mov cx,8
	stc
	call OutDB				;��ப� �� ������
	add dx,0101h
	mov cx,8
	mov ax,70DFh                            ;'�'
	call FillWord				;������ ⥭�
	add dx,0FF07h
	mov cx,1
	mov ax,70DCh				;'�'
	call FillWord				;�ࠢ�� ⥭�
	pop dx bx cx
	ret

end