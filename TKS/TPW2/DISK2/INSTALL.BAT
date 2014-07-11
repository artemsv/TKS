echo off
cls
break on
echo.
echo Borland Pascal with Objects 7.0
echo Maintenance Release Installation
echo.
if not exist BP7BIN.ZIP goto logdrive
if #%1# == ## goto help
set emptydir=N
set windowsdir=Y
set return=testwin
if not exist %1\bin\bpc.exe goto setemptydir
if not exist %1\units\*.tp* goto badsubdir
echo Updated files will be copied over existing files in
echo subdirectories of %1.
echo.
echo IMPORTANT: You should back up your current BP installation
echo before continuing this installation.

:testwin
set return=report
if #%2# == ## goto nowindowsdir
if not exist %2\system\gdi.exe goto badwindowsdir
echo.
echo The new version of BWCC.DLL will be copied to %2\SYSTEM.
:report
echo.
echo Press Ctrl-C or Ctrl-Break now to abort this install procedure, or
pause
echo.
echo Unzipping files to %1\bin...
unzip -d -o bp7bin.zip %1

if exist bp7etc.zip goto usedisk2
:testdisk2
echo.
echo Please insert disk 2 and
pause
if exist bp7etc.zip goto usedisk2
echo.
echo Error: Can't find disk 2 files!
goto testdisk2

:usedisk2
echo.
echo Unzipping files to %1...
unzip -d -o bp7etc.zip %1

if %windowsdir%==N goto closing
echo.
echo Copying BWCC.DLL to %2\SYSTEM\BWCC.DLL
copy bwcc.dll %2\system\bwcc.dll

:closing
echo.
echo.
echo Install is complete.
echo.
echo Make sure you perform a complete 'build' on all of your source
echo code. You do not need to rebuild the RTL source files.
goto end

:setemptydir
echo Update files will be copied to the temporary directory
echo %1.
echo After installation, copy the installed files from this temporary
echo directory to the appropriate BP directories on your system.
goto %return%

:badsubdir
echo The specified BP7 base directory (%1)
echo does not match the default BP7 subdirectory structure.
echo This program installs update files into the default
echo BP7 subdirectory structure (bp\bin, bp\units, etc).
echo.
echo This install program will now terminate.  From the Dos
echo prompt, create an empty subdirectory on your hard disk.
echo Then run this install program again and specify the new
echo (empty) subdirectory as the destination.  After installation
echo is complete, you can copy files into the BP7 directories
echo on your system.
echo.
goto end

:badwindowsdir
echo.
echo Warning: Can't find Windows in the %2 directory.
goto restwindir
:nowindowsdir
echo.
echo Warning: No Windows directory specified.
:restwindir
set windowsdir=N
echo.
echo The updated version of BWCC.DLL will not be installed.  If Windows
echo is already installed on your system, terminate install program
echo now and rerun it with the correct Windows directory parameter.
echo Otherwise, proceed with the installation and then copy BWCC.DLL
echo from update disk 2 into your \windows\system directory.
goto %return%

:help
echo Error: Invalid or missing command line parameter.
echo.
echo Command line parameters:
echo INSTALL  [BP7 dir]  [Windows dir]
echo.
echo where [BP7 dir] is the directory you want to install the
echo BP7 maintenance release files to (usually C:\BP)
echo and [Windows dir] is your Windows directory (usually C:\WINDOWS)
echo.
echo For example:
echo INSTALL  c:\bp c:\windows
echo.
goto end

:logdrive
echo Error:  Install files are not in the current drive or directory.
echo.
echo Set your current drive and directory to the disk drive containing
echo the install files, then rerun this install program.
echo.
echo For example, if the install disk is in drive A:, change to the
echo A: drive by typing A: [Enter] at a Dos command line prompt.
echo Then run INSTALL.
echo.

:end
