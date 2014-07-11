.model small		;䠩���� ������  08.01.03.
.386
extrn Win2:proc,ChangeAtribut:proc,GetBlock:proc,PutBlock:proc,CaretHide:proc
extrn CaretShow:proc,MouseHide:proc,MouseShow:proc,FillBackBlock:proc
extrn Shadow:proc,GetStart:proc,FillByte:proc,Pause:proc,CopyFiles:proc
extrn buf:word,OutStr:proc,ChangeAtribut:proc,KeyPressed:proc,HandlerStd:proc
extrn GetMouseInfo:proc,GetCurDir:proc,OutDB:proc,file:byte,ClearFileName:proc
extrn Window:proc,GetMem:proc,FreeMem:proc,SetCurDir:proc,FillWord:proc
extrn FillByte:proc,Len:proc
PUBLIC FileDialog,fileTMP
.data
	extrn initPtr:word,handlerPtr:word
	dir	db	260 dup (67)
	norm	dw	7400h
	cur 	dw      2E00h
	fileTMP	db 	12 dup(5Eh)
	byte3	db	?
.code

IsFile:					;���� �� ��ꥪ� � fileTMP 䠩���
	push dx bx
	mov cx,11111B
	lea dx,fileTMP
	mov ah,4Eh
	int 21h				;FindFirst
	mov ah,2Fh
	int 21h				;get current DTA
	cmp byte ptr es:[bx+15h],10h	
	je short IF100
	stc
	jmp short IF200
IF100:	clc
IF200:	pop bx dx 
	ret
	
FileDialogInit:
	push dx 
	add dx,010Dh
	call VertLine
	mov dx,062Dh
	call VertLine
	pop dx 
	mov cx,11111B
	call CopyFiles
	xor bp,bp				;���� ���ᮢ뢠��� 䠩�
	call DrawFiles
	call SelectFirst
	call UpdateDirName
	ret
	
ClearFileWindow:			;��頥� ���� �롮� 䠩���
	push dx bx
	mov al,20h			;������塞 �஡�����
	mov ah,byte ptr norm+1
	mov dx,0614h
	mov bx,0E0Ch
	mov cx,3
CFW100:	call FillBackBlock		;��頥� ��।��� ������
	add dl,13
	loop CFW100
	pop bx dx
	ret

SelectFirst:				;�뤥��� ���� �㭪�
	call MouseHide
	mov dx,0614h
	mov bx,010Ch
	mov ax,cur
	call ChangeAtribut		;�뤥�塞 ���� �㭪�
	call MouseShow
	ret

DeleteSelect:				;᭨���� �뤥����� � ⥪�饣� �㭪�
	call MouseHide
	mov ax,norm            
	call ChangeAtribut	
	call MouseShow	
	ret

GoParentDir:				;��⠭����� ⥪�騬 த�⥫�᪨�
	push dx ds
	pop es
	lea di,dir
	cld
	mov al,0
	mov cx,64
	repne scasb			;�饬 ����� ����� ⥪�饣�
	std
	mov al,'\'
	mov cx,64
	repne scasb                     ;�饬 ��砫� ⥪�饣� ��⠫���
	cmp byte ptr es:[di],':'
	jne short GPD100			;த�⥫�᪨�-��୥���
	inc di
GPD100:	mov byte ptr es:[di+1],0
	lea dx,dir
	call SetCurDir
	pop dx
	ret
	
GoSubDir:				;���� � �����⠫��
	lea di,dir
	push dx ds
	pop es 
	cld
	mov al,0
	mov cx,64
	repne scasb			;�饬 ����� ����� ⥪�饣�
	cmp byte ptr es:[di-2],'\'	;⥪�騩-��୥���?
	je short GSD100
	inc di
GSD100:	dec di
	mov byte ptr es:[di-1],'\'	;� ��� ����� ������塞 ����
	lea si,fileTMP			;ᬥ饭�� � DS (DS=FS!)
	mov cx,12			;���ᨬ��쭠� ����� ����� ��⠫���
GSD160:	movsb				;横� ����஢���� ����� �����⠫���
	cmp byte ptr [si-1],0		;�� �६������ ���� � FS:0000 � dir
	je short GSD160
	loop GSD160
GSD200:	lea dx,dir
	call SetCurDir
	pop dx
	ret	
			
UpdateDirName:				;�������� ��ப� ��⠫���
	push bp dx bx si
	lea si,dir
	call GetCurDir
	mov dx,0519h
	mov cx,20h
	mov ah,byte ptr norm+1
	mov al,205
	call FillWord                   ;������� ���� ������ ����� ��⠫���
	call Len			;CX-����� ��ப� � SI
	push cx
	mov cx,3			;'D:\' - 3 ᨬ����
	mov bh,01
	mov bl,cl
	mov ax,7EFFh
	call ChangeAtribut
	mov cx,3
	call OutDB			;�뢥�� �⠭������ ���� ���
	add dl,3
	;⥯��� ���� �����,㬥����� �� ��⠫쭠� ���� ���?
	pop cx				;����� �ᥣ� ���
	sub cx,3			;����� ��⠢襣��� ���
	cmp cx,22			;22-����� ��⠢襣��� ����
	jb short UDN100		;���� 墠��
	mov bp,cx
	sub bp,28			;BP-��������騩�� ���⮪
	mov bh,01
	mov bl,3
	mov ax,7EFFh
	call ChangeAtribut
	mov al,'.'
	mov cx,3			;2 �窨
	call FillByte			;3 �窨 ����� �������⨢襣��� ���
	add dl,3
	add si,bp
UDN100:	mov bl,cl
	mov bh,01
	mov ax,7EFFh
	call ChangeAtribut
	clc			;��ᨬ CF,�⮡� �� ���뢠�� ��ਡ�� � AL
	call OutDB		
	pop si bx dx bp
	ret
	
GetPunct:				;�����頥� � AH ����� ⥪�饣� �㭪�
	mov ah,dh
	sub ah,05h
	cmp dl,14h
	je short GP200				;��ࢠ� ������
	cmp dl,21h
	jne short GP100				;����� ������
	add ah,14
	jmp short GP200
GP100:	add ah,28
GP200:	ret

GetCoord:		;�८�ࠧ�� ����� �㭪� � AH � ���न���� � DX
	cmp ah,14
	ja short GC100				;�� � ��ࢮ� ������
	add ah,05h
	mov dl,14h
	jmp short GC300
GC100:	cmp ah,28
	ja short GC200
	sub ah,9
	mov dl,21h
	jmp short GC300
GC200:	sub ah,23
	mov dl,2Eh
GC300:	mov dh,ah
	ret

DrawFiles:	 	;���ᮢ뢠�� �� 䠩�� � ���� � FS:000E
	mov si,12				;᫮��-���-�� 䠩���	
	push dx si bx ds fs			;BP-�⮫쪮 䠫�� �ய�����
	pop ds					;DS:000E-����
	mov bx,word ptr [si]			;BX-������⢮ 䠩���
	mov dx,0614h
	mov byte3,dl
	add si,2                                ;�ய�᪠�� ᫮��-���-�� 䠩���
	xor ah,ah				;����稪 ᨬ����� ����� 䠩��
DF100:	lodsb					;AL-ᨬ��� �����
	or al,al
	je short DF300				;����஫��� �� ����� 䠩��
	cmp al,'.'
	je short DF200
DF150:	mov cx,1
	call FillByte
	inc di
	inc dl
	inc ah
	jmp short DF100
DF200:						;横� ���������� �஡�����
	or ah,ah
	je short DF150				;�� ��ࢠ� �窠 த.��⠫���
	cmp byte ptr [si-2],2Eh
	je short DF150				;�� ���� �窠 த.��⠫���
	mov al,32
	mov cx,1
	call FillByte
	inc di
	inc dl
	inc ah
	cmp ah,9
	jb short DF200
	jmp short DF100
DF300:	
	xor ah,ah				;���稪 ᨬ����� ����� 䠩��
	dec bx
	jz short DF400				;䠩�� ���稫���
	mov dl,byte3
	inc dh					;������ �� Y � ����
	cmp dh,14h
	jb short DF100
	cmp dl,2Eh
	je short DF400				;�� �뫠 ��᫥���� ������
	mov dh,06h
	add dl,0Dh
	add byte3,0Dh
	jmp short DF100
DF400:	pop ds bx si dx
	ret
	
VertLine:					;���� ���⨪����� �����
	push dx
	mov al,'�'
VL100:	mov cx,1
	call FillByte
	inc dh
	cmp dh,14h
	jb short VL100
	pop dx
	ret

GetSelectFile:	;������� � 12-���⮢� ���� fileTMP ��� ��࠭���� 䠩��
		;�� �������� ���� � �ᥬ� ������� � FS:000E
	call GetPunct			;AH-����� ⥪�饣� �㭪�
	mov al,0
	xchg al,ah
	add bp,ax			;⥯��� ��� ����� � BP
	mov al,13			;�ਧ��� ���� ����� 䠩��
	mov cx,bp			;����稪 ���殢 ��� 䠩��� ;)
	dec cx
	mov si,14			;SI-��砫� �������� ���� � �������
	push bp ds ds fs
	pop ds es			;DS-ᥣ���� ���� � ������� 䠩��� 
	jcxz GSF300			;�� ���� 䠩�-�ࠧ� �� ����஢����
GSF100:                                 ;横� ���᪠ ��砫� ���-�� 䠩��
	cmp byte ptr [si],0
	jne short GSF200
	inc si				;�ய��⨬ �ନ�.����
	dec cx
	jcxz GSF300			;��諨 ��� ��࠭���� 䠩��
GSF200:	
	inc si	
	jmp short GSF100
GSF300:                 		;⥯��� � SI - ��� �⮣� 䠩��
	lea di,fileTMP
	cld
GSF400:	lodsb
	stosb
	or al,al
	jne GSF400
	pop ds bp
	ret
	
FileDialog:
	mov bx,1000
	call GetMem
	mov fs,ax				;������ ��� ���� ��� 䠩���
	mov dx,0513h
	mov bx,1028h
	mov ah,byte ptr norm+1
	mov al,20h
	lea di,FileDialogInit
	mov initPtr,di
	lea di,FileDialogHandler
	mov handlerPtr,di
	clc
	call Window
	ret					;AX-��� ��室�

FileDialogHandler:		;��ࠡ��稪 ᮡ�⨩ ��� ���� �롮� 䠩���
	jc short SF150				;�� ���
	cmp ah,1
	je short SF300				;����� ���७��� ������
	cmp al,13				;����� ������ Enter?
	jne short SF140
	call UpdateDirName
	call GetSelectFile
	call UpdateDirName
	cmp byte ptr [fileTMP],'.'		;�� �� ��୥��� ��⠫��?
	je short SF120				;�� 䠩� ��� �����⠫��
	call IsFile				;�᫨ � fileTMP 䠩� - CF=1
	jc short SF136				;�� 䠩�
	call GoSubDir	
	jmp short SF130
SF120:
	call GoParentDir
SF130:
	call UpdateDirName
	mov cx,11111B				;��ਡ��� 䠩���
	call CopyFiles
	call ClearFileWindow
	xor bp,bp			;���� ���ᮢ뢠��� 䠩� - ���� ;)
	call DrawFiles
	call SelectFirst
	clc				;���� ����뢠�� �� ����
	jmp SF1300
SF136:
	xor ax,ax			;��� ��室� - OK
	jmp SF1250		
SF140:
	cmp al,27	
	jne SF1200
	stc			        ;���� ���� �������
	jmp SF1250
SF150:
	clc				
	jmp SF1200
SF300:  
	cmp al,72		;��५�� �����
	jne short SF600
	call DeleteSelect
	cmp dh,06h		;������ ��ப�?
	je short SF400
	dec dh
	jmp short SF1000
SF400:	
	cmp dl,14h		;��ࢠ� ������?
	je short SF500
	sub dl,0Dh		;���室�� �� �।����� ������
	mov dh,13h		;������ �㭪�
	jmp short SF1000	
SF500:
	or bp,bp		;���ᮢ뢠����-�� ���� 䠩� � ᯨ᪥
	je short SF1000		;��-��祣� ����� ᤥ����
	dec bp                  ;���ᮢ�� �� ���� 䠩� ࠭��
	jmp short SF1100	
SF600:
	cmp al,77		;��५�� ��ࠢ�
	jne short SF700
	call DeleteSelect
	cmp dl,2Eh		;��᫥���� ������?
	je SF1200		;��-��祣� ����� ᤥ����
	call GetPunct		;����稬 � AH ����� �㭪�
	add ah,14		;����稬 ����� �ॡ㥬��� �㭪�
	mov cx,word ptr fs:[12]
	or ch,ch		
	jnz short SF610         ;䠩��� ����� 祬 255-� CL �ࠢ������ �����
	cmp cl,ah
	jae short SF610		;䠩��� 墠��
	mov ah,cl		;䠩��� �� 墠��-�뤥�塞 ��᫥���� 䠩�
SF610: 
	call GetCoord		;����砥� ���न���� ������ �㭪�
	jmp short SF1000
SF700:
	cmp al,80		;��५�� ����
	jne SF1200
	call DeleteSelect
	call GetPunct		;AH-����� ⥪�饣� �㭪�
	cmp ah,42		;�ᥣ� ������� 42 �㭪� 
	je short SF1000		;�६���� ����
	inc ah			;����� �ॡ㥬��� �㭪�	
	mov cx,word ptr fs:[12]	;CX-������⢮ 䠩���
	or ch,ch
	jne short SF710		;䠩��� ����� 祬 255
	cmp cl,ah
	jae short SF710		;䠩��� 墠��
	dec ah			;�� �� ��᫥���� 䠩�-������
SF710:
	call GetCoord	
	jmp short SF1000	
SF1000:
	call MouseHide
	mov ax,cur            	;��᪠
	call ChangeAtribut
	call MouseShow
	jmp SF1200
SF1100:	
 	call DrawFiles
SF1200:	
	call HandlerStd
	jnc SF1300
SF1250:	
	push fs
	pop es
	call FreeMem
	stc			;�������
SF1300:	
	ret
end