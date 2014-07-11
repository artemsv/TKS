.model small
.386
.data
	extrn msgOk:byte,initPtr:word,handlerPtr:word,fileTMP:byte
	Menu db 'File  Edit  Search  Run  Debug  Options  Window  Help'
	Stat db 'Alt+X Exit F2 Save  F3 Open  F4 Assemble  F9 Run  F10 Menu  '
	     db 'Alt+F5 User Screen'
	userBuf	dw	?
	selfBuf dw	?
	file1	db	' '
	file	db 	'noname00.asm',0       
	indic	db	'     :     '
	memory	db  	'         '
	UserCaretPos	dw	5a5ah
	SelfCaretPos	dw	5a5ah
	byte1		db	?
	byte2		db	?
.code
	extrn FillWord:proc,OutDW:proc,FillBackBlock:proc,OutDW:proc,OutDB:proc
	extrn Win2:proc,GetBlock:proc,PutBlock:proc,Shadow:proc,CaretShow:proc
	extrn CaretHide:proc,ReadKey:proc,GetMem:proc,GotoXY:proc,WhereXY:proc
	extrn X:byte,Y:byte,firstLine:word,buf:word,curY:word,curX;word
	extrn ChangeAtribut:proc,FillByte:proc,bufSize:word,Window:proc
	extrn Val:proc,FillWord:proc,GetCurY:proc,OutStr:proc,Len:proc
	extrn ParseStr:proc,Button:proc,MouseHide:proc,MouseShow:proc
	extrn HandlerStd:proc,InitStd:proc

PUBLIC MsgBox,UpdateCaretPos,ClearWorkArea,UserScreen,Init,file
PUBLIC SaveSelf,RestoreSelf,UpdateFileName,ClearFileName,SaveUser,RestoreUser
PUBLIC UpdateMemory

ClearFileName:				;�������� �஡����� ���� file
	push ds
	pop es
	lea di,file
	mov al,32
	mov cx,12
	rep stosb
	ret

MsgBoxInit:			;SI-�뢮����� ASCIIZ ��ப�,DX-㣮�,BX-ࠧ���
	push dx bx si
	sub bl,6		;BL-����� ���� �뢮�� ��� ��ப�
	add dx,0203h
	mov byte1,dl		;���� ��࠭��� DL � BL
	mov byte2,bl
MBI400:				;横� �뢮�� ��ப ⥪��
	call Len		;CX-����� �뢮����� ��ப�
	mov bl,byte2        	;����⠭����� BL-����� ���� �뢮��
	sub bl,cl               ;����� ���⮣� ���� � ����� ��஭
	shr bl,1		;����� ᫥��
	mov dl,byte1		;����⠭����� DL
	add dl,bl		;�ਡ���塞 �����	
	mov cx,345
	mov al,70h              ;��ਡ��
	stc                     ;��ਡ�� ���뢠��
	call OutDB
	inc si			;�ய�᪠�� #13
	cmp byte ptr [si],0	;0-�ਧ��� ���� ⥪��
	je short MBI500		;�� �뫠 ��᫥���� ��ப�	
	add dh,1                ;���饭�� �� Y
	jmp short MBI400
MBI500:	
;	add dx,0A0Ch
	lea si,msgOk
	stc
	call Button
	pop si bx dx
	ret
	
MsgBoxHandler:  		;��ࠡ��稪 ᮡ�⨩ ��� ���� ᮮ�饭�� 
	call HandlerStd
MBH600: ret
	
MsgBox:				;SI-�뢮����� ASCIIZ ��ப�
	push es di bx cx dx 	;���� ��᫥ �ନ���쭮�� ���-⨯ ������
	push ds
	pop es			;ᥣ���� ���筨��
	mov bx,0600h		;��ࢮ��砫쭮 ࠧ���� ���� ࠢ�� 6x0
	call ParseStr		;BL-����� ����.�����ப�,CH-���-�� �����ப
	;⥯��� ���᫨� ࠧ���� ���� - DX � BX
	xor ax,ax
	mov al,bl		;BL-����� �������襩 ��ப�
	mov dl,2		;����⥫�
	div dl			;AL-��⭮�(�������� ����.��ப�),AH-���⮪
	add al,3		;1 ᨬ��� �� ࠬ�� � 2 �� �����
	mov dl,40		;�������� ����� �࠭�
	sub dl,al		;DL-���न��� X 㣫� ����
	add bh,ch		;BH-���� ����
	add bl,6		;BL-����� ����
	mov dh,25		;���� �࠭�
	sub dh,bh
	shr dh,1 		;����� ������� - DH-���न��� Y 㣫� ����
	mov ax,7F20h		;��ਡ�� ��� ���������� ����
	lea di,MsgBoxInit
	mov word ptr initPtr,di
	lea di,MsgBoxHandler
	mov word ptr handlerPtr,di
	clc			;������ �㦭�
	call Window
	pop dx cx bx di es
	ret

UpdateCaretPos:
	mov dx,1704h
	mov al,205
	mov cx,10
	call FillByte			;����⠭���� ࠬ��
	mov eax,0			;�� ��直� ��砩 ���襥 ᫮�� EAX=0
	call GetCurY			;AX=curY
	lea si,indic
	call Val			;CX-�᫮ ���
	mov bx,cx
	mov byte ptr [si][bx],':'
	inc cx
	push cx
	mov dx,1704h
	call OutDB
	xor ax,ax
	mov al,X
	lea si,indic
	call Val
	pop ax
	add dl,al
	call OutDB
	mov dh,Y
	mov dl,X
	call GotoXY
	ret

ClearWorkArea:
	push dx ax bx cx
	mov dx,0201h
	mov bx,154Eh
	mov ax,1F20h
	call FillBackBlock
	pop cx bx ax dx
	ret

Init:	mov bx,256
	call GetMem
	mov selfBuf,ax
	call GetMem
	mov userBuf,ax
	call SaveUser

	mov dx,0000h
	mov cx,2000
	mov ax,7020h
	call FillWord

	mov dx,0100h
	mov bx,1750h
	mov ax,1F00h
	call ChangeAtribut

	mov dx,1801h
	lea si, Stat
	mov cx,78
	clc
	call OutDB
	
	mov dx,0001h
	lea si,Menu
	mov cx,53
	clc
	call OutDB

	mov dx,0100h
	mov bx,1750h	
	stc			;������ �� �㦭�
	call Win2
	call UpdateFileName
	ret

SaveXXXX:				;��࠭�� �࠭ � ���� (ES)
	mov ax,0B800h
	mov ds,ax
	jmp short MoveScreens

RestoreXXXX:				;����⠭�������� �࠭ �� ���� (DS)
	mov ax,0B800h
	mov es,ax

MoveScreens:
	xor di,di
	xor si,si
	mov cx,2000
	rep movsw
	ret

SaveUser:			;��࠭�� �࠭ � ���짮��⥫�᪮� ����
	call MouseHide
	mov es,UserBuf
	lea bx,UserCaretPos
	jmp short SaveIt

SaveSelf:			;��࠭�� �࠭ � ���� �ணࠬ��
	call MouseHide
	mov es,selfBuf
	lea bx,SelfCaretPos
SaveIt:
	push ds
	call SaveXXXX
	pop ds
	call WhereXY
	mov [bx],dx
	call MouseShow
	ret

RestoreSelf:			;����⠭�������� �࠭ �ணࠬ��
	call MouseHide
	call SaveUser		;�।���⥫쭮 ��࠭塞 �࠭ ������⥫�
	push ds
	mov ds,selfBuf
	lea bx,SelfCaretPos
	jmp short RestoreIt

RestoreUser:			;����⠭�������� ���짮��⥫�᪨� �࠭ 
	call MouseHide
	call SaveSelf		;�।���⥫쭮 ��࠭塞 �࠭ �ணࠬ��
	push ds
	mov ds,userBuf
	lea bx,UserCaretPos

RestoreIt:
	call RestoreXXXX
	pop ds
	mov dx,[bx]		;DX-���� ��࠭񭭮�� ����.��������� �����
	call GotoXY
	call MouseShow
	ret

UserScreen:
	call RestoreUser
	call ReadKey
	call RestoreSelf
	ret

UpdateFileName:
	mov dx,0121h
	mov ax,1FCDh
	mov cx,13
	call FillWord
	lea si,file1
	mov cx,13
	mov al,14h
	stc
	call OutDB
	ret

UpdateMemory:			;�������� �������� ������⢠ �����
	mov bx,0FFFFh
	call GetMem
	mov ax,bx
	mov bx,16
	mul bx			;DX:AX-�᫮ ����
	push ax
	mov eax,edx
	shl eax,16
	pop ax
	lea si,indic
	call Val
	mov dx,0048h
	push cx
	mov cx,7
	mov ax,7420h
	call FillWord
	pop cx
	call OutDB
	ret	
end