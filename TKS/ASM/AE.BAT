@ECHO OFF

REM set up your own DPMI host for Borland TLINK if you have NOT OS/2 with
REM DPMI enabled or Qarterdeck QEMM DPMI loaded, otherwise TLINK will stop
REM with a fault, remove the LoadHigh (LH) if you encounter problems
 REM LH DPMIRES.EXE

REM to replace the following lines with your own settings refer to the Help
REM 'Tutorial'.

 SET DPMIMEM=MAXMEM8192
 SET RTM=EXTLEAVE4096

REM start (and possibly load high) ASM Edit
REM You may remove the LH if you encounter problems with MASM 6.0 or TASM 5.0
REM Do NOT rename ASMEDIT.EXE nor ASMSHELL.EXE!!
 ASMSHELL.EXE %1 %2 %3 %4 %5 %6 %7 %8 %9
REM LH ASMSHELL.EXE %1 %2 %3 %4 %5 %6 %7 %8 %9

