.model	tiny
.586
extrn fileread:proc,fileopen:proc,readln:proc,writeln:proc,filewrite:proc
extrn keypressed:proc,filecreate:proc,fileclose:proc,FileSize:proc,Pause:proc
extrn OutDB:proc,OutDW:proc
include stdmac.inc
.code
.startup
     jmp EndData
     frame	 db 'Ú',78 dup(196),191
     file	 db 63 dup(3)
     lin1	 dw 80 dup(3*256+196)
     lin2	 db 80 dup(196)
     len	 dd ?
EndData:
  push 0
  push 23
  lea si,lin1
  push si
  push 80
  call OutDW
  call Pause
  ret
end