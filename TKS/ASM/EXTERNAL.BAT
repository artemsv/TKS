@ECHO OFF

REM EXTERNAL.BAT - example batch file to be used instaed of calling
REM an external program directly. Part of ASM Edit.

REM (c) Copyright by O Love & Tels 1996.  All Rights Reserved.

REM Just set up your command.com as external program and this batch
REM file as first paramter. After this add the parameters for this
REM batch file.

REM To access the parameters passed by ASM Edit to this BATCH file
REM write %n where n is the number of the parameter.


REM Things to do before the external program:

REM example: make copy of file to process for backup
REM We assume that as first parameter is the complete path & name of
REM the file to assemble passed. In ASM Edit you would use !ACPML for this.

copy %1 *.ba1


REM executing the external program

REM example: assemble via TASM to object file, pass all options from ASM Edit

TASM %1 %2 %3 %4 %5 %6 %7


REM Things to do after the external program:

REM example: erase *.lst file created by TASM and filter output of assembler
REM to "RESULT.". Please refer to 'Redirection' in the Help Index for further
REM details of setting up your own filter.

REM Note: The program filter is not yet HERE! You have to write it by yourself.

DEL *.lst
FILTER RESULT.ERR RESULT

REM Exit DOS box and return to ASM Edit

EXIT
