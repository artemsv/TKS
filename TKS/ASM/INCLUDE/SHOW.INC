;;show.inc
;;���ம�।������ ��� ���㠫���樨 ॣ���஢ al, ah, ax, eax
;;�� �室�:
;;arg_n - ��� ������ �� ॣ���஢ al,ah,ax,eax
;;n_poz - ����� ����樨 �� ��࠭�, �� 㬮�砭�� - 1000
Show	MACRO	arg_n,n_poz:=<1000>
LOCAL	main_part,disp,pause,template,VideoBuffer,p_mode,m1,m2
;;���室 �� ��砫� ����� ������,
;;�⮡� �������� �믮������ ������
	jmp	main_part
;;������� ����⠭�� � ��६����
FALSE	equ	0	;;����
TRUE	equ	0ffffh	;;��⨭�
?reg8bit=false	;;䫠� ⮣�, �� ��।�� ॣ���� ah ��� al
?reg16bit=false	;;䫠� ⮣�, �� ��।�� ॣ���� ax
?reg32bit=false	;;䫠� ⮣�, �� ��।�� ॣ���� eax
;;⠡���-蠡��� ��� xlat
template	db	'0123456789ABCDEF'
;;���� ��������� - ��� ��אַ�� �뢮�� �� ��࠭
VideoBuffer	dw	0b800h

main_part:		;;��砫� ����� ������
;;��࠭���� � �⥪� �ᯮ��㥬�� ॣ���஢:
;;eax, ebx, ecx, edx, edi, ds, es
	push	ax
	push	bx
	push	cx
	push	dx
	push	di
	push	ds
	push	es
	push	cs
	pop	ds
;;� bx - ���� ⠡����-蠡���� (��� xlat)
	lea	bx,cs:template
	xor	cx,cx	;���⪠ cx
;;��砫� ����� ��।������ ⮣�,
;;����� ॣ���� �� ��।�� ������
IFIDNI	<al>,<&arg_n>	;;�᫨ ��㬥��=al ��� AL,
?reg8bit=TRUE		;;��⠭���� 䫠�� 8-��⮢��� ॣ����
	mov	ah,al
ENDIF
;;��।�� �� al ��� AL
IFIDNI	<ah>,<&arg_n>	;;�᫨ ��㬥��=ah ��� AH,
?reg8bit=TRUE		;;��⠭���� 䫠�� 8-��⮢��� ॣ����
ENDIF
;;��।�� �� AH ��� ah
IFIDNI	<ax>,<&arg_n>	;;�᫨ ��㬥�� ࠢ�� ax ��� AX,
?reg16bit=TRUE		;;��⠭���� 䫠�� 16-��⮢��� ॣ����
ENDIF
;;��।�� �� ah, AH ,ax ��� AX
IF	(?reg8bit)	;;�᫨ ��।�� al ��� ah
	push	ax
	and	ah,0f0h	;;���饭�� � ���襩 ���થ ��⮢ ah
	shr	ax,12	;;ᤢ�� ��⮢ � ��砫� (16-4=12)
	xlat		;;�࠭���� ⠡����-蠡����
;;����饭�� ᨬ���� �� al � edi
	mov	di,ax
	shl	di,8
	inc	cx
	pop	ax
	and	ax,0f00h	;;���饭�� � ����襩 ��ࠤ� ah
	shr	ax,8	;;ᤢ�� ��⮢ � ��砫� (16-(4+4)=8)
	xlat		;;�࠭���� ⠡����-蠡����
	or	di,ax	;;����饭�� ��।���� ᨬ���� � di
	shl	di,16
	inc	cx
ENDIF
IF	(?reg16bit)	;;�᫨ ��।�� ax ��� ax
;;��砫� ��ࠡ�⪨ ���祭�� ॣ���� ax
	push	ax
;;���饭�� � ���襩 ���થ ��⮢ ax
	and	ax,0f000h
	shr	ax,12	;;ᤢ�� ��⮢ � ��砫� (16-4=12)
	xlat		;;�࠭���� ⠡����-蠡����
;;����饭�� ᨬ���� �� al � ������
;;��ࠤ� ���襩 �������� edi
	mov	di,ax
	shl	di,8
	inc	cx
	pop	ax
	push	ax
;;���饭�� �� ��ன ���થ ��⮢ ax
	and	ax,0f00h
	shr	ax,8	;;ᤢ�� ��⮢ � ��砫� (16-(4+4)=8)
	xlat		;;�࠭���� ⠡����-蠡����
;;����饭�� ��।���� ᨬ���� � �������
;;��ࠤ� ���襩 �������� edi
	or	di,ax
	shl	di,8
	inc	cx
	pop	ax
	push	ax
	and	ax,0f0h	;;���饭�� � ���쥩 ���થ ��⮢ � ax
	shr	ax,4	;;ᤢ�� ��⮢ � ��砫� (16-(4+4+4)=4)
	xlat		;;�࠭���� ⠡����-蠡����
	or	di,ax	;;����饭�� ��।���� ᨬ���� � edi
	shl	di,8
	inc	cx
	pop	ax
	and	ax,0fh	;;���饭�� � ����襩 ���થ ��⮢ ax
	xlat		;;�࠭���� ⠡����-蠡����
	or	di,ax	;;����饭�� ��।���� ᨬ���� � edi
	inc	cx
ENDIF
;;��� ॠ�쭮�� ०���
;;����㦠�� � es ���� ����������
	mov	ax,cs:VideoBuffer
	mov	es,ax
p_mode:
;;��� ॠ�쭮�� � ���饭���� ०����
;;������⢮ 横��� � cx
	cld		;;��ᬮ�� ���। - ��� stosw
	xchg	di,bx
	mov	di,n_poz	;;��砫쭠� ������ ���
			;;�뢮�� �� ��࠭
disp:
	cmp	cx,4
	jle	m1	;���室, �᫨ ecx<=4
	shld	ax,edx,8
	shl	dx,8
	jmp	m2
m1:
	shld	ax,ebx,8
	shl	bx,8
m2:
	mov	ah,71h	;;����-��ਡ��
	stosw		;;����஢���� ���祭�� ax
			;;� es:di (���������)
	loop	disp	;;����� 横�� cx ࠧ
	mov	cx,65535	;;����প�
pause:	loop	pause
;;��८�।������/����⠭������� �� �⥪�
;;�ᯮ��㥬�� ॣ���஢
	pop	es
	pop	ds
	pop	di
	pop	dx
	pop	cx
	pop	bx
	pop	ax
ENDM

