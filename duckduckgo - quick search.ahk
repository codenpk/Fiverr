#SingleInstance, force
#Persistent

menu, tray, NoDefault
menu, tray, nostandard
menu, tray, add, Toggle Hotkey, toggle
menu, tray, add
menu, tray, add, Exit

active := true
return


:*:;::
if !active
{
	Send, `;
	return
}
InputBox,query,Search DuckDuckGo,,,200,100
if errorlevel
	return
query = %query%
if query=
	return
URL := "https://duckduckgo.com/?q=" query
ie := ComObjCreate("InternetExplorer.Application")
ie.Visible := true
ie.Silent := true
ie.Toolbar := false
ie.Navigate(URL)
while ie.ReadyState != 4
	sleep, 100
Sleep, 2000
MsgBox % ie.LocationURL "`n" ie.document.title
return

#IfWinActive,Search DuckDuckGo
^BackSpace:: ;control backspace hack
Send, {ctrldown}{shiftdown}{left}{shiftup}{ctrlup}{backspace}
return
#IfWinActive

toggle:
if active
{
	active := false
	TrayTip,duckduckgo - quick search,Quick search deactivated
}
else {
	active := true
	TrayTip,duckduckgo - quick search,Quick search is now active
}
return

Exit:
ExitApp