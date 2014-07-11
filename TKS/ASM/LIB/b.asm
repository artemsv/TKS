;b.asm - ����� ��楤�� ��� ࠡ��� � ��ப���		03.01.03.
.model small
.386

extrn GetStart:proc,X:byte,Y:byte,firstLine:word,curPtr:word
extrn buffer:word,bufSize:word,Flag:word,margin:word

.code

PUBLIC NextLine,LineStart,LineEnd,OutStr,CharFromPos,InsertText,BufR,BufL,Move
PUBLIC NextChar,PrevChar,PosFromChar,IsSpacer,IsAlpha,GetCurY,Len,ParseStr

GetCurY:				;�����頥� ����� ⥪�饩 ��ப�
	xor si,si
	xor ax,ax
GCY100:	cmp si,curPtr
	je short GCY300
	cmp si,bufSize
	je short GCY300
	cmp byte ptr gs:[si],13
	jne short GCY200
	inc ax
GCY200:	inc si
	jmp short GCY100
GCY300: inc ax
	ret
	
Len:					;�����頥� ����� ��ப� � SI
	push si
	xor cx,cx
L100:	cmp byte ptr [si],13
	je short L200
	cmp byte ptr [si],0
	je short L200
	inc si
	inc cx
	jmp short L100
L200:	pop si
	ret

IsAlpha:				;�᫨ � AL �㪢�,��⠭�������� CF
	cmp al,41h			;'A'
	jb short IS200
	cmp al,5Ah                      ;'Z'
	jbe short IS100
	cmp al,7AH			;'z'
	ja short IS200
	cmp al,61h                      ;'a'
	jae short IS100
	jmp short IS200	

IsSpacer:				;�᫨ � Al ����� ᨬ���,���-�� CF
	cmp al,13
	jna short IS200
	cmp al,32
	je IS200
IS100:	stc
	jmp IS300
IS200:	clc
IS300:	ret

InsertText:                             ;��⠢��� ᨬ��� � AL � ����
	mov si,curPtr
	cmp byte ptr gs:[si],13
	je short IT100                  ;⥪.ᨬ���=#13-ᤢ����� ��易⥫쭮
	bt flag,0			;��⠭����� �� ��� ��⠢��?		
	jc short IT200			;�� ��⠭�����
IT100:	call BufR
IT200:	mov byte ptr gs:[si],al
	inc curPtr
	mov si,curPtr			;�� �⠫ �� curPtr ����� bufSize?
	cmp si,bufSize			;⠪�� ����� ���� � ०��� Overrite
	jbe short IT300
	mov bufSize,si			;�⠫-���४��㥬
IT300:
	ret

NextChar:				;�����.ᬥ�.᫥�.ᨬ���� � ����
	mov si,curPtr
	cmp si,bufSize			;�� ��᫥���� �� ᨬ��� ����?
	jae short NC400			;��᫥����	
NC100:	cmp word ptr gs:[si],0A0DH
	je short NC200
	inc si				;㢥��稢��� ⥪���� ������ � ����
	jmp short NC300
NC200:	add si,2			;�ய�� #13#10
NC300:	mov curPtr,si			;���९�塞 ��������� ⥪�饩 ����樨
NC400:	ret
	
PrevChar:	        		;�����.�।��騩 ᨬ��� � ����
	mov si,curPtr
	or si,si
	je short PC200			;�� ���� ᨬ��� ��ࢮ� ��ப�
	dec si
	je short PC100			;��࠭��,�� ��� �⮣� ᫥�.���.-��蠥�
	cmp word ptr gs:[si-1],0A0DH
	jne short PC100
	dec si
PC100:	mov curPtr,si
PC200:	ret

CharFromPos:				;�����頥� (SI) ⥪.������ � ����
	xor bx,bx                 	;����ࠨ���� curPtr �� X,Y
	xor ax,ax
	mov al,Y
	sub al,2			;AX-��ଠ��������� Y
	mov bl,X
	dec bl				;BX-��ଠ��������� X
	mov cx,firstLine
	add cx,ax			;AX-�⮫쪮 ��ப ���� �ய�����
	mov curPtr,0
CFP100:
	jcxz CFP200
	call NextLine
	inc si
	loop CFP100
CFP200:
	add si,bx
	mov curPtr,si	
	ret
	
PosFromChar:				;�������� ���祭�� curY,curX � ᮮ�.
					;� ⥪�騬� curPtr 
	mov cx,curPtr                   ;�⮫쪮 ᨬ����� �� ��砫� �� ⥪�饩
	xor si,si
	xor dx,dx			;����稪 ��ப
PFC100: 				;横� ������� ��ப
	cmp byte ptr gs:[si],13
	jne short PFC200
	inc dx				;��諨 ��ப�!!!
PFC200:
	inc si				;��������� �� ��砫� ���� � curPtr
	jcxz PFC300			;� ���� curPtr 㦥 ࠢ�� 0?
	dec cx
	jcxz PFC300			;��ᬮ�५� ���� ���� �� curPtr �� 0
	jmp short PFC100
PFC300:
	mov bx,firstLine
	sub dx,bx			;��ଠ��������� Y � DX
	add dx,2			;��䥪⨢�� Y � DX
	mov Y,dl			;��䥪⨢�� Y � DL
	;⥯��� ���� ���� X.�㤥� ��ᬠ�ਢ��� ��ப� �� �� ��砫� �� ⥪.
	mov X,1				;���樠������-� ��砫� ��ப�
	mov si,curPtr
	call LineStart
	cmp si,curPtr			;⥪��� ������-��ࢠ� � ��ப�?
	je short PFC600			;��-X 㦥 ࠢ�� 1-��室

PFC350:
	cmp byte ptr gs:[si],9
	jne short PFC360
	or X,7
	jmp short PFC360
PFC360:
	inc si
	inc X
	cmp si,curPtr
	jne short PFC350	
PFC600:	ret

OutStr:			;�뢮��� ��ப� �� �࠭,BP-����.������ � ����
	push es di cx                   ;DX-���न����,SI-��ப� ���筨�
	mov cx,78      
	call GetStart			;�����.DI �� ������ � ���������
	mov ax,di
	add ax,cx
	sub ax,2
	add ax,cx			;AX-����.���. � ��������.��� �⮩ ��ப�
OS100:                                  ;横� �뢮�� ��ப� �� �࠭
	cmp si,bp
	jae short OS400
	cmp byte ptr [si],13
	je short OS400
	cmp byte ptr [si],9
	jne short OS200
	or di,14
	add di,2
	inc si
	jmp short OS300
OS200:
	movsb
	inc di			;�ய�᪠�� ���� ��ਡ�⮢
OS300:
	cmp di,ax
	ja short OS350 
	loop OS100
	jcxz OS350		;����� ��ப� ������� 78 ᨬ�����
	jmp short OS400		;ᬮ��� �뢥�� ��� ��ப�
OS350:				;�ய�᪠�� ��⠢訥�� ᨬ���� �� ���� ��ப�
	cmp byte ptr [si],13
	je short OS400
	inc si
	jmp short OS350
OS400:
	pop cx di es
	ret		

NextLine:
	mov si,curPtr
	call LineEnd
	mov curPtr,si
	jmp NextChar

LineStart:                      	;in: GS:SI-㪠��⥫� 
LS100:					;out SI-��砫� ⥪�饩 ��ப�
	or si,si
	je short LS200			;⥪.���.-���� ᨬ��� ����
	cmp byte ptr gs:[si-1],10
	je short LS200			;���⨣�� ��砫� ��ப�
	dec si
	jmp LS100
LS200:	ret

LineEnd:				;in: GS:SI-㪠��⥫� 
LE100:					;out SI-����� ⥪�饩 ��ப�
	cmp si,bufSize
	jae short LE300			;���⨣�� ���� ����
	cmp byte ptr gs:[si],13
	je short LE300		        ;���⨣�� ���� ��ப�
	inc si
	jmp LE100
LE300:	ret

BufL:                                	;ᤢ����� ���� �� ���� ���� �����
	mov cx,bufSize
	sub cx,si
	push si                     	;SI-���� ����,CX-����� ����
	pop di
	inc si
	call Move
	dec bufSize
	ret
BufR:                                   ;ᤢ����� ���� �� ���� ���� ��ࠢ�
	mov cx,bufSize
	sub cx,si
	push si                         ;SI-���� ����,CX-����� ����
	pop di
	inc di
	call Move
	inc bufSize
	ret

Move :                                  ;ᤢ����� CX ���� � SI � DI
	push ax cx di si ds es          ;SI-���� ����,CX-����� ����
	cmp di,si
	jb short M100
	add si,cx
	add di,cx
	std     
	dec si
	dec di
	jmp short M200
M100:	cld
M200:	mov ax,gs                   	;ᥣ���� ���� ।���஢����
	mov es,ax                       ;ᥣ���� �ਥ�����-���� ।-�
	mov ds,ax                       ;ᥣ���� ���筨��-���� ।-�
	rep movsb
M300:	pop es ds si di cx ax           
	ret

ParseStr:       		;SI-ASCIIZ ��ப�;ᨬ���� ���殢 �����ப - #13
	push si
	xor bl,bl		;�����. � BL-����� ����.�����ப�,CH-�� ���-��
	xor cx,cx		;
	mov al,0		;ᨬ��� ��� ���᪠
PS100:			;横� ������� ����� ����.��ப� (BL) � �� ���-�� (CH)
	cmp byte ptr [si],13
	jne short PS200
	inc ch			;����稪 ��ப
	cmp bl,cl		;�ࠢ������ � ������ ����.��ப� �� �⮩
	jae short PS200		;��������� ��ப� �� ����� ���ᨬ��쭮� � BL
	mov bl,cl		;���. ������ ���祭�� � ����⢥ ����. ��ப�
	xor cl,cl
PS200:	cmp byte ptr [si],0
	je short PS300
	inc cl
	inc si
	jmp short PS100
PS300:	pop si
	ret
end