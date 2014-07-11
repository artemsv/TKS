set talk off
set status off
set menu off
set device to print
clear all
STL=PROW()+1
USE JUN1
@ STL+1,2 SAY GR
@ STL+1,12 SAY TEM
DO PRINTT
SRED=AVERAGE BAL
@ STL+41,40 SAY SRED
set device to screen 
