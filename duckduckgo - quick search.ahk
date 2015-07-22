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
whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
whr.Open("GET", URL, true)
whr.Send()
whr.WaitForResponse()
source := uriDecode(whr.ResponseText)
RegExMatch(source,"uddg=[a-zA-Z0-9\(\)=_\?\.:\/\/-]*",match)
StringReplace,match,match,uddg=,,all
match = %match%
if match !=
{
	whr.Open("GET", match, true)
	whr.Send()
	whr.WaitForResponse()
	source := uriDecode(whr.ResponseText)
	RegExMatch(source,"<title>.+</title>",title)
	StringReplace,title,title,<title>,,all
	StringReplace,title,title,</title>,,all
	Clipboard := match "[" title "]"
	TrayTip,duckduckgo - quick search,%match% [%title%] copied to clipboard
}
else {
	TrayTip,duckduckgo - quick search,No immediate link found. Please use "\" before query to get the first link
}
return

uriDecode(str) {
	Loop
		If RegExMatch(str, "i)(?<=%)[\da-f]{1,2}", hex)
			StringReplace, str, str, `%%hex%, % Chr("0x" . hex), All
		Else Break
	Return, str
}

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