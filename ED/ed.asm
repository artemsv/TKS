.model small            			;editor.asm	17.12.02
.386

%LINUM 0
%NOCREF
%NOSYMS
PAGE 60,80
%TRUNC
%TEXT 45

extrn InitStd:proc,	HandlerStd:proc
extrn InitExe:proc,	IOError:proc,   PopupMenu:proc,		OutStr:proc
extrn Win1:proc,	ReadKey:proc,   Win2:proc,		GotoXY:proc
extrn OutDW:proc,	OutDB:proc,	CharFromPos:proc,	FreeMem:proc
extrn KeyPressed:proc,	FillByte:proc,	FillWord:proc,		Init:proc
extrn GetMem:proc,	Up:proc,	MouseWhere:proc,	MouseInit:proc
extrn MouseShow:proc,	InsertText:proc,Exec:proc,		MouseSetPos:proc
extrn GoEnd:proc,	FileOpen:proc,	UpdateCaretPos:proc,	CtrlY:proc
extrn FileRead:proc,	FileClose:proc,	ClearWorkArea:proc,	FileSize:proc
extrn MsgBox:proc,	CountLines:proc,NextLine:proc,		LineEnd:proc
extrn LineStart:proc,	CaretHide:proc,	CaretShow:proc,		MouseHide:proc
extrn UserScreen:proc,	BufL:proc,	Writeln:proc,		Val:proc	
extrn NextChar:proc,	PrevChar:proc,	PosFromChar:proc,	Plus:proc
extrn Minus:proc,	Down:proc,	Delete:proc,		Back:proc
extrn CtrlT:proc,	CtrlR:proc,	GetMouseInfo:proc,	Home:proc
extrn FileDialog:proc,	CtrlRight:proc,	IsAlpha:proc,		file:byte
extrn PgDown:proc,	PgUp:proc,	UpdateFileName:proc,	FileCreate:proc
extrn RestoreSelf:proc,	Menu:proc,	RestoreUser:proc,	FileWrite:proc
extrn CtrlDel:proc,	GetCurY:proc,	ClearFilename:proc,	UpdateMemory:proc
extrn fileTMP:byte,	Window:proc,	PutBlock:proc,		Button:proc
extrn CaretInsert:proc,			CaretNormal:proc
public x,y,firstLine,curPtr,bufSize,Flag,buf,margin
.stack 300
.data
extrn MsgSaveFile:byte,	MsgYes:byte,MsgNo:byte,msgCancel:byte,msgInsert:byte
extrn msgOverrite:byte,msgAbout:byte,initPtr:word,handlerPtr:word
	w	dw	?
	Y	db 	2
	X	db      1
	margin	dw	0		;����� � ������ ���
      	firstLine	dw	0	;��ࢠ� �����뢠���� ����� ����
	bufSize	dw	0	        ;ᬥ饭�� ���.ᨬ���� � ���� ।.
	curPtr	dw	0		;⥪��� ������ � ����
	flag	dw	00000000B       ;���� 䫠���
	total	dw	0		;�᫮ �����	
	tasm_f	db 'd:\asm\tasm.exe',0,28,' /zi /t d:\asm\projects\ed\1',13
	link_f	db 'd:\asm\tlink.exe',0,20,'d:\asm\projects\ed\1',13
	td_f	db 'd:\asm\td2.exe',0
	asm_f	db 'd:\asm\projects\ed\ed.exe',0
	invite	db ' Type EXIT to return AsmEd...',13,10,'$'
	command	db 'c:\command.com',0
	buf	dw	?		;�������� ���� ��࠭���� ��࠭�
.code
 
start:	call InitExe		;����ன�� DS � ᮧ����� "���"
	push 34
	call MouseInit
	call MouseShow
	call Init                                            	
	mov bx,2048			;32 ��-���ᨬ.ࠧ��� ���� ।-�
	call GetMem
	mov gs,ax			;GS-㪠�뢠�� �� ᥣ���� ����
	mov es,ax			;ᥣ���� �ਥ�����
	mov cx,2048*8			;32 ��	
	mov ax,2020h	                ;�஡���
	cld
	xor di,di
	rep stosw			;���樠������ ����
	mov bx,4000
	call GetMem
	mov buf,ax
	mov dx,0808
	call GotoXY
	call DrawLines
	call UpdateCaretPos
main_loop:		 	;横� ����祭�� ᮡ�⨩
	call UpdateMemory
	call GetMouseInfo
	jnc short @@1
	call MouseEvent
	jmp main_loop
@@1:  	call KeyPressed	 	;������� ᨬ��� �� ���� ����������
	jz short main_loop	;ᨬ��� �� ������ 
	cmp ah,1
	jne short @@2		;���७��� ������
	call ExtCode	 	;������ ���७�� ���
	jmp short main_loop
@@2:	call NormCode
	jmp short main_loop
quit:	push gs
	pop es
	call FreeMem	
	mov ah,4ch
	int 21h

NormCode:
	cmp al,13
	jne short NC100
	call InsertText
	mov al,10
	call InsertText
	cmp Y,22
	je short NC500
	mov X,1
	inc Y
	jmp short NC500
NC100:
	cmp al,8
	jne short NC200			;�� �� ������ BackSpace
	call Back
	jmp short NC500
NC200:
	cmp al,25                       ;Ctrl+Y
	jne short NC250
	call CtrlY
	jmp short NC500
NC250:
	cmp al,20			;Ctrl+T
	jne short NC300
	call CtrlT
	jmp short NC500
NC300:
	cmp al,18			;Ctrl+R
	jne short NC310
	call CtrlR
	jmp short NC500
NC310:	cmp al,127			;Ctrl+Backspace
	jne short NC400
	mov bx,100
	call GetMem
	jmp short NC500
NC400:
	call InsertText
	call DrawLines
	cmp x,78
	je short NC500
	inc x
NC500:
	call UpdateCaretPos
	call PosFromChar
	call DrawLines
	bts flag,1			;��⠭���� ��� Modified
NC600:	ret

ExtCode:
	xchg al,cl			;��࠭��� AL
	mov ah,2
	int 16h				;������� � AL ���� 0000:0417
	xchg al,ah                      ;��࠭��� ��� � AH
	xchg cl,al			;����⠭����� AL
	cmp al,59			;F1
	jne short EC100
	lea si,msgAbout
	call MsgBox
	jmp EC700
EC100:
	cmp al,60                       ;F2
	jne short EC200
	call SaveFile
	jmp EC700
EC200:
	cmp al,61                   	;F3
	jne short EC210
	call OpenFile
	jmp EC699
EC210:
	cmp al,62			;F4
	jne short EC220
	call Tasm
	jmp EC700
EC220:
	cmp al,63			;F5
	jne short EC230
	call Lib
	jmp EC700	
EC230:
	cmp al,64			;F6
	jne short EC240
	lea di,td_f
	call Exec
	jmp EC700
EC240:
	cmp al,65			;F7
	jne short EC250
	jmp EC700
EC250:
	cmp al,66			;F8
	jne short EC260
	call RestoreUser
	lea dx,invite
	call Writeln
	lea di,command
	call Exec
	call RestoreSelf
	jmp EC700
EC260:
	cmp al,67			;F9
	jne short EC270
	call Run
	jmp EC700
EC270:
	cmp al,68			;F10
	jne short EC280
	call Menu
	jmp EC700
EC280:
	cmp al,85h			;F11
	jne short EC290
	jmp EC700
EC290:
	cmp al,86h			;F12
	jne short EC300
	call GetCurY
	jmp EC700
EC300:
	cmp al,45			;ALt+X
	jne short EC302
	call SaveFile
	jmp quit	
EC302:	
	cmp al,72			;��५�� �����
	jne short EC400
	test ah,11			;�஢��塞 �� ��� ���
	jz short EC310
	;Shift+Up
	jmp EC699
EC310:
	call Up
	jc EC699
	jmp EC600
EC400:
	cmp al,75			;��५�� �����
	jne short EC500
	test ah,11
	jz short EC410
	;Shift+left
	jmp EC700
EC410:	
	call Minus
	call UpdateCaretPos
	jmp EC699
EC500:
	cmp al,77       		;��५�� ��ࠢ�
	jne short EC600
	test ah,11
	jz short EC510
	;Shift+right
	jmp EC699
EC510:
	call Plus
	call UpdateCaretPos
	jmp EC700
EC600:
	cmp al,80			;��५�� ����
	jne short EC610	
	test ah,11
	jz short EC606
	;Shift+down
	jmp EC699
EC606:
	call Down
	jc EC699
	jmp EC700
EC610:
	cmp al,108			;Alt+F5
	jne short EC660
	call UserScreen
	jmp short EC700
EC660:
	cmp al,73			;PgUp
	jne short EC662
	call PgUp
	jmp short EC699
EC662:
	cmp al,81			;PgDown
	jne short EC665
	mov cx,22
EC664:	
	push cx
	call Down
	call DrawLines
	call UpdateCaretPos
	pop cx
	loop EC664
;	call PgDown
	jmp short EC699
EC665:
	cmp al,82			;Insert
	jne short EC669
	mov cx,8
	mov dx,1745h
	btc flag,0
	jc short EC667
	call CaretInsert
	jmp short EC700
EC667:	call CaretNormal
	jmp short EC700
EC669:
	cmp al,83			;Delete
	jne short EC670
	call Delete
	bts flag,1			;��⠭���� ��� Modified
	jmp short EC699
EC670:
	cmp al,93h			;Ctrl+Del
	jne short EC671
	call CtrlDel
	bts flag,1			;��⠭���� ��� Modified
	jmp short EC699
EC671:
	cmp al,71			;Home
	jne short EC672
	call Home
	jmp short EC700
EC672:
	cmp al,79			;End
	jne short EC674
	call GoEnd
	jmp short EC700
EC674:
	cmp al,116			;Ctrl+��५�� ��ࠢ� 
	jne short EC676
	call CtrlRight
	jmp short EC699
EC676:
	cmp al,115			;Ctrl+��५�� �����
	jne short EC678
	jmp short EC700
EC678:
EC699:	call DrawLines
EC700:	call UpdateCaretPos
	ret

MouseEvent:				;b AH-���न��� �� Y,� AL-�� X 
	cmp ah,24                       ;��ப� �����?
	jne short ME100
	cmp al,60
	jb short ME010
	call UserScreen
	jmp short ME300
ME010:
	cmp al,50
	jb short ME020
	call Menu                       ;F10
	jmp short ME300
ME020:
	cmp al,42
	jb short ME030
	call Run                        ;F9
	jmp short ME300
ME030:
	cmp al,29
	jb short ME040
	call Tasm                       ;F4
	jmp short ME300
ME040:	
	cmp al,20
	jb short ME050
	call OpenFile                   ;F3
	jmp short ME300
ME050:
	cmp al,11
	jb short ME060
	call SaveFile                   ;F2
	jmp short ME300
ME060:
	jmp quit                        ;��
ME100:
	cmp ah,0
	je short ME200
	cmp al,0
	je short ME400			;饫箪 �� ࠬ��
	cmp al,79
	je short ME400			;饫箪 �� ࠬ��
	cmp ah,1
	je short ME400
	cmp ah,23
	je short ME400			;饫箪 �� ࠬ��
	cmp ah,24
	je short ME300
	mov Y,ah
	mov X,al
	call CharFromPos		;���������� curPtr
	jmp short ME400
ME200:					;ᮡ�⨥ ��� ����
	call GetMouseInfo
	jc short ME200
	call OpenFile
ME300:					;ᮡ�⨥ ��� ��ப� �����
ME400:	ret

DrawLines:
	mov bp,bufSize
	mov ax,curPtr
	push ax
	call MouseHide
	call ClearWorkArea
	mov cx,firstLine		;������⢮ �ய�᪠���� ��ப
	mov curPtr,0			;ᬥ饭�� ���� ।���஢����
	jcxz DL200			;��ࢠ� ��ப�-�������
DL100: 					;横� ���᪠ ��ࢮ� ������� ��ப�
	call NextLine
	loop DL100
DL200:					;横� �뢮�� ��ப �� �࠭
	mov si,curPtr
	push ds 
	mov dx,0201h                    ;㣮� � ����������-��砫� �뢮��
	push gs
	pop ds				;DS-ᥣ���� ���� ।���஢����
DL300:
	call OutStr
	add si,2                        ;#13#10
	inc dh
	cmp dh,23			;���⨣�� ������ ��ப�?
	je short DL400
	jmp DL300
DL400:
	pop ds
	pop ax
	mov curPtr,ax
	call MouseShow
	ret	
	
ReadFile :
	push ds
	lea dx,file
	mov al,0
	call FileOpen
	jnc short RF100
	call IOError
	stc
	jmp short RF200		
RF100:	push ax				;��࠭��� ���ਯ�� 䠩��
	mov bx,ax
	call FileSize
	jc short RF200
	mov cx,ax
	mov bufSize,ax			;ࠧ��� 䠩��
	push gs
	pop ds				;� DS - ᥣ���� ����
	mov dx,0			;� DX - ᬥ饭�� � ����
	pop bx				;���ਯ�� 䠩��
	call FileRead
	jc short RF200
	call FileClose
	clc				;䫠� �訡��
RF200:	pop ds
	ret

WriteFile:
	push ds dx bx cx
	lea dx,file
	call FileCreate
	jc short WF100
	mov bx,ax
	mov cx,bufSize
	push gs
	pop ds
	xor dx,dx			;ᬥ饭�� � ᥣ���� ����
	call FileWrite
	jc short WF100
	call FileClose
WF100:	pop cx bx dx ds
	ret

SaveFile:
	bt flag,1				;�஢�ઠ ��� Modified
	jnc short SF700				
	call CaretHide
	mov ax,buf				;�������� ����
	mov dx,0715h
	mov bx,0828h
	mov ax,7F20h
	lea di,InitStd
	mov word ptr initPtr,di
	lea di,HandlerStd
	mov word ptr handlerPtr,di
	clc
	call Window
	push dx
	mov dx,091Bh
	mov cx,28
	lea si,msgSaveFile
	mov al,70h
	stc				;���뢠�� ���� ��ਡ�⮢
	call OutDB
	mov dx,0C19h
	lea si,msgYes
	stc				;�뤥������ ������
	call Button	
	add dl,12
	lea si,msgNo
	clc
	call Button	
	add dl,12
	lea si,msgCancel
	clc
	call Button	
	call ReadKey
	pop dx
	mov ax,buf
	call PutBlock
	call CaretShow
SF100:
	call WriteFile	
SF700:
	ret

OpenFile:
	call FileDialog
	cmp ax,3			;AX=3 - Cancel-������ �� �ਭ��
	je short OF200
	call ClearFileName
	push ds
	pop es
	lea si,fileTMP
	lea di,file
OF100:	movsb
	cmp byte ptr [si],0
	jne short OF100
	call UpdateFileName
	call ReadFile
	jc short OF200
	call DrawLines
	btr flag,1			;���뢠�� ��� ������஢������	
OF200:	ret

Debugger:
	call RestoreUser
	call WriteFile
	lea di,td_f
	jmp short T100
	
Tasm:	call RestoreUser
	call WriteFile
	lea di,tasm_f
T100:	call Exec
	call ReadKey
	call RestoreSelf
	call DrawLines
	ret

Run:	call RestoreUser
	push gs
	lea di,asm_f
	call Exec
	pop gs
	call RestoreSelf
	ret
Lib:   	ret

end start
