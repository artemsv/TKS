;����� ����
.model small			;		��� ᮧ�����:  24.12.02.
.data
	men db 	7,12,3,'New',12,'Open...   F3',12,'Save      F2'
	    db  10,'Save As...',5,'Print',9,'DOS Shell',12,'Exit   Alt+X'
.code
  	extrn GetStart:proc,GetBlock:proc,FillBackBlock:proc,Win1:proc
  	extrn Shadow:proc,GetMem:proc,ReadKey:proc,OutDB:proc,ChangeAtribut:proc
  	extrn CaretHide:proc,CaretShow:proc,KeyPressed:proc,GetMouseInfo:proc
	extrn PutBlock:proc
	extrn buf:word

PUBLIC PopupMenu,Menu

Menu:	push si
	mov dx,0100h
	lea si,men
	call PopupMenu
	pop si
	ret

PopupMenu:		;DX-㣮�,SI-��ப� �㭪⮢
	call CaretHide
	push dx
	push si			;��࠭塞 ��砫� ��ப� ���ᠭ�� �㭪⮢
	call GetStart		;
	mov bh,[si]		;���� ����
	add bh,2                ;2 ᨬ���� �� ࠬ��
	mov bl,[si+1]           ;����� ᠬ��� �������� �㭪�
	add bl,2		;2 ᨬ���� �� ࠬ�� � ���� ��஭
	push bx			;��࠭塞 ࠧ���� ����
	mov ax,buf		;�������� ����
	call GetBlock
	mov ax,7020h
	call FillBackBlock
	stc
	call Win1
	call Shadow	
	pop bx			;����� ��������,��?-�ᥣ� ���ᥣ� 
	pop si			;�몮��ਢ��� �� �⥪� SI(�� ��� BX)
	push bx
	mov al,[si]		;����稪 �㭪⮢
	inc dl			;���न��� �� X ��ࢮ�� �㭪�
	add si,2		;ᬥ饭�� ��ப� ��ࢮ�� �㭪�
PM100:
	xor cx,cx
	mov cl,byte ptr [si]	;����� ��।���� �㭪�
	inc dh			;���न��� Y �㭪� ����
	inc si			;�ய�᪠�� ���� �����
	call OutDB
	dec al			;���稪 �㭪⮢
	or al,al
	je short PM200		;�뢥�� �� �㭪��
	jmp short PM100
PM200:
	pop bx
	pop dx			;����⠭�������� ���न���� 㣫�
	push dx			;�����࠭��� 㣮� ����
	push bx			;�����࠭��� ࠧ���� ����
	add dx,0101h		;���न���� ��ࢮ� ��ப� ����
	mov ch,dh		;��砫쭠� ���न��� �㭪� ����
	mov cl,dh		
	add cl,bh
	sub cl,3                ;CL-���ᨬ.����.,��� ����� ����� �㭪� ����
	mov bh,1                ;���� �㭪� ����
	sub bl,2                ;����� �㭪� ����
	mov ax,002Fh            ;��᪠
	call ChangeAtribut	;�뤥���� ����� ��ப� ����
PM300:
	call GetMouseInfo
	jc short PM400
	call KeyPressed	
	jz short PM300
	cmp ah,1
	je short PM500		;����� ���७��� ������
	cmp al,13
	je short PM400		;����� ������ Enter
	cmp al,27	
	je short PM400
	jmp short PM300
PM400:
	pop bx
	pop dx
	mov ax,buf
	call PutBlock		;����⠭�������� �࠭
	call CaretShow
	ret	
PM500:
	cmp al,72		;��५�� �����
	je short PM800
	cmp al,80               ;��५�� ����
	je short PM600
	jmp short PM300
PM600:
	mov ax,70FFh            
	call ChangeAtribut	;᭨��� �뤥����� ⥪�饣� �㭪� ����
	cmp dh,cl		;CL-���ᨬ.����.,��� ����� ����� �㭪� ����
	je short PM700		;�� ᠬ� ������ �㭪�
	inc dh
	jmp short PM1000
PM700:
	mov dh,ch
	jmp short PM1000
PM800:
	mov ax,70FFh            
	call ChangeAtribut	;᭨��� �뤥����� ⥪�饣� �㭪� ����
	cmp dh,ch		;CH-��砫�.����.,��� ����� ����� �㭪� ����
	je short PM900		;�� ᠬ� ���孨� �㭪�
	dec dh
	jmp short PM1000
PM900:
	mov dh,cl
PM1000:
	mov ax,002Fh            ;��᪠
	call ChangeAtribut
	jmp PM300
end