set talk off
set status off
pr1=0
p12=0
  p11=0
  use grup
   st1=2
   stl1=3
   i=0
   grup1="        "
   @ 1,25 say ' Укажите номер группы'
   otvet="   "
   pr2=0
   clear
    do while.not.eof()
      @ st1,stl1 say kgr1 picture "9999"
      @ st1,stl1+5 say gr1
      st1=st1+1
      skip 1
    enddo
   @ 23,10 say "Ведите номер группы" get otvet picture "@z 9999"
     read
    clear
    pr12=val(otvet)
    use jun1
    go top
    locate for kgr=otvet   
    grup1=gr
    clear
    st=2
    stl=3
    i=0
    ktem1="            "
     otvet1="   "
     use qtem 
     do while .not.eof()
         @ st,stl say ktem picture '@z 999'
         @ st,stl+5 say tem
         st=st+1
         skip 1
     enddo
    @ 23,10 say 'Введите номер темы' get otvet1 picture '@z 999'
    read
    clear
    pr11=val(otvet1)
    use jun1
    go top
    locate for ktem=otvet1.and.kgr=otvet
    ktem1=tem 
    kdat=dat
    do otch31
    
