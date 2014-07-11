.model small
.386
.data
	msgAccessErr	db	'Ошибка доступа к файлу',13
	msgSaveFile	db	'File has been modified.Save?'
	msgOk		db	'   Ok   '
	msgYes		db	'  Yes   '
	msgNo		db	'   No   '
	msgCancel	db	' Cancel '
	msgInsert	db	'Insert  '
	msgOverrite	db	'Overrite'
	msgAbout	db	'Turbo AsmEdit',13,13,'Version 1.0',13,13
			db	'Copyright (c) 2002,2003 by',13,13
			db	'Sokol Software',13,0 
	msgErr		db	'Unknown error code.',13,0
	msgIOErr02	db	'File not found.',13,0
	msgIOErr03	db	'Path not found.',13,0
	msgIOErr05	db	'Access denied.',13,0

PUBLIC msgSaveFile,msgYes,msgNo,msgCancel,msgInsert,msgOverrite,msgAbout
PUBLIC IOError,msgOk
.code
extrn MsgBox:proc
IOError:
	cmp ax,02
	jne short IOE100
	lea si,msgIOErr02
	jmp short IOE400
IOE100:	cmp ax,03
	jne short IOE200
	lea si,msgIOErr03
	jmp short IOE400
IOE200:	cmp ax,05
	jne short IOE300 
	lea si,msgIOErr05
	jmp short IOE400
IOE300:	lea si,msgErr
IOE400:	call MsgBox
	ret

end
