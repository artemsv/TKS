set talk off
set format to
set color to w+/b+,n+/w,n+/n+
pr5=0
do while pr5<6
   clear
   @ 5,5 prompt"1.�������� ���� ������"
   @ 6,5 prompt"2.�뤠� ��� 1"
   @ 7,5 prompt"3.�뤠� ��� 2"
   @ 8,5 prompt"4.�뤠� ��� 3"
   @ 9,5 prompt"5.�뤠� �।���� ���� ������ �� ��㯠�" 
   @ 10,5 say"��� ��室� ����� <Esc>"
   menu to pr5
   if pr5=0 
      exit
   endif
   if pr5=1
     clear 
     do otch1
   endif
   if pr5=2
      do ot34
   endif
   if pr5=3
      do otch3
   endif
   if pr5=4
      do otch4
   endif
   if pr5=5
      do ot45
   endif 
enddo
