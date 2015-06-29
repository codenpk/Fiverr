/*
	Script for zevav By Martin Thuku
	
	Description
	******************************************************************************************
	I'd like a few AutoHotKey macros that, in the context of MS Word only,

	1) if a user highlights a word or phrase and presses alt-A, that word or phrase is stored as variable "a".
	2) " and presses alt-Q, it's stored as "q."
	3) when a user presses ctrl-alt-1, the boolean variable "interviewNoTimestamps" is toggled true/false.
	4) when interviewNoTimestamps is true, the enter key inserts: a) line break, b) variable a or q, depending on which was last inserted, c) colon, d) tab
	******************************************************************************************
*/

#SingleInstance,force
#Persistent
win_text = Microsoft Word Document
selected_text=
interviewNoTimestamps := true

#IfWinActive,,Microsoft Word Document ;;This ensures that we run hotkeys on a ms word window only

	!a:: ;;get the highlighted word or phrase when we press Alt - A
	WinActivate,,%win_text%
	send,{CtrlDown}c{CtrlUp}
	a := Clipboard ;;we get the copied selection
	return
	
	!q:: ;;Store selection to variable Q
	q := a
	return
	
	^!1::
	^!Numpad1:: ;;toggle interviewNoTimestamps on Ctrl + Alt + 1 (whether it numpad 1 or 1)
	if interviewNoTimestamps
		interviewNoTimestamps := false
	else
		interviewNoTimestamps := true
	return
	
	;UNCLEAR LOGICS ON THE LAST QUERY
	
	

return
#IfWinActive ;;This clears the hotkeys for use on other windows
return

