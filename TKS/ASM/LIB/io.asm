;       ����� � ��楤�ࠬ� 䠩������ ����� �뢮��	��� ᮧ�����: 05.12.02
.model small
.386
.code

PUBLIC FileCreate,FileRead,FileClose,FileWrite,FileOpen,FileSize

FileCreate proc near		;ᮧ���� 䠩� � ������,��室�騬�� � DX
	push cx
  	mov ah,3ch              ;�㭪�� ᮧ����� 䠩��
  	mov cx,0		;��ଠ��� ��ਡ���
  	int 21h
	pop cx
  	ret 
endp  

FileRead:			;�ॡ��: CX-����� ����  DX-����
  	mov ah,3fh		;	  BX-���ਯ�� 䠩��
  	int 21h
  	ret 

FileWrite:			;�ॡ��: CX-����� ����  DX-����
  	mov ah,40h		;	  BX-���ਯ�� 䠩��
  	int 21h
 	ret 

FileOpen:			;�����頥� ���ਯ�� ����⮣� 䠩�� � AX
  	mov ah,3dh		;� DX - ��ப� � ������ ���뢠����� 䠩��
  	int 21h
  	ret 

FileClose:			;� BX - ���ਯ�� ����뢠����� 䠩��
  	mov ah,3ch
  	int 21h
  	ret 

FileSize:			;BX - ���ਯ�� 䠩��
	push cx			;�� ��室� DX:AX - ����� 䠩��
  	mov ah,42h
  	mov al,2		;��砫쭠� ������-� ����
  	mov cx,0		;���襥 ᫮�� ᬥ饭�� ��砫쭮� ����樨
  	mov dx,0		;����襥 ᫮�� ᬥ饭�� ��砫쭮� ����樨
  	int 21h
  	push dx	ax		;��࠭塞 १����
;⥯��� ���� ����⠭����� ������ 㪠��⥫�-��६����� ��� � ��砫� 䠩��
  	mov ah,42h
  	mov al,0		;��砫쭠� ������-� ��砫� 䠩��
  	mov cx,0		;���襥 ᫮�� ᬥ饭�� ��砫쭮� ����樨
  	mov dx,0		;����襥 ᫮�� ᬥ饭�� ��砫쭮� ����樨
  	int 21h
  	pop ax dx cx
  	ret
end  
