set talk off
set format to
set color to w+/b+,n+/w,n+/n+
pr5=0
do while pr5<6
   clear
   @ 5,5 prompt"1.Создание базы данных"
   @ 6,5 prompt"2.Выдача формы 1"
   @ 7,5 prompt"3.Выдача формы 2"
   @ 8,5 prompt"4.Выдача формы 3"
   @ 9,5 prompt"5.Выдача среднего бала учащихся по групам" 
   @ 10,5 say"Для выхода нажми <Esc>"
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