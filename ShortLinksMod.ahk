/*
	Software to autoconvert links with bitly
	It will convert link in the control that the mouse is on using the shortcut Ctrl+Alt+L
	
	How to use -> Click on to the Text Area (So that this application can get a focus on the text you want converted) And press Ctrl+Alt+L
*/

#SingleInstance,force
#Persistent
#NoEnv
SetFormat,float,20.2

menu, tray, NoDefault
menu, tray, NoStandard
menu, tray, add, Exit
menu, tray, add, Reload
return

reload:
Reload
return

exit:
ExitApp

^!L::
/*
MouseGetPos,x,y,winid,ctrl
ControlGetText,txt,%ctrl%,ahk_id %winid%
*/
txt := Clipboard
links := getLinks(txt)
n := 0
loop,parse,links,`n
{
	lin = %A_LoopField%
	if lin !=
		n := A_Index
}

if n > 0
{
	Gui, destroy
	Gui, -border +LastFound +AlwaysOnTOp +ToolWindow
	Gui, Add, Text, x12 y10 w170 h20 ,Shortening %n% links...
	Gui, Add, Progress, x12 y30 w170 h10 -smooth vprog,
	Gui, Show, w199 h48,Processing
	hwnd1 := WinExist()
	WinSet, ExStyle, +0x00000020, ahk_id %hwnd1%
	WinSet, Transparent, 180, ahk_id %hwnd1%
	loop,parse,links,`n
	{
		p := a_index/n*100
		GuiControl,,prog,% p
		try {
			short := shortenLink(A_LoopField)
			error := false
		} catch e {
			MsgBox,0,Shorten Link,There was a problem shortening %A_LoopField%`n`nError: %e%
			error := true
		}
		if !error
		{
			short = %short%
			if short !=
				StringReplace,txt,txt,%a_loopfield%,%short%,all
		}
	}
	Clipboard := txt
	Gui, destroy
}
else {
	MsgBox, 48, Shorten URL, Sorry`, we could not find any links on the control your mouse is on
}
return

GuiEscape:
Gui, destroy
return

getLinks(text){
	while pos := RegExMatch(text, "(https?:|.)\/\/[^\s]+", m, A_Index=1?1:pos+StrLen(m))
	{
		n := StrLen(m)
		if (!RegExMatch(m,"\w|\/",o,n))
			m := SubStr(m,1,(n-1))
		res .= (res=""?m:"`n" m)
	}
	res = %res%
	return res
}

shortenLink(URL){
	token:="2cfa0e9b466a4f798af4fa7e6d02a2499d1b496f" ;-Arun Sathiya's token
	url := UriEncode(URL)
	url_data=https://api-ssl.bitly.com/v3/shorten?access_token=%token%`&longUrl=%url%
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET", url_data)
	whr.Send()
	data := whr.ResponseText
	data := json(data, "data.url")
	StringReplace,data,data,`\,,all
	return data
}

UriEncode(Uri, Enc = "UTF-8")
{
	StrPutVar(Uri, Var, Enc)
	f := A_FormatInteger
	SetFormat, IntegerFast, H
	Loop
	{
		Code := NumGet(Var, A_Index - 1, "UChar")
		If (!Code)
			Break
		If (Code >= 0x30 && Code <= 0x39 ; 0-9
			|| Code >= 0x41 && Code <= 0x5A ; A-Z
			|| Code >= 0x61 && Code <= 0x7A) ; a-z
			Res .= Chr(Code)
		Else
			Res .= "%" . SubStr(Code + 0x100, -1)
	}
	SetFormat, IntegerFast, %f%
	Return, Res
}

StrPutVar(Str, ByRef Var, Enc = "")
{
	Len := StrPut(Str, Enc) * (Enc = "UTF-16" || Enc = "CP1200" ? 2 : 1)
	VarSetCapacity(Var, Len, 0)
	Return, StrPut(Str, &Var, Enc)
}

json(ByRef js, s, v = "") {
	j = %js%
	Loop, Parse, s, .
	{
		p = 2
		RegExMatch(A_LoopField, "([+\-]?)([^[]+)((?:\[\d+\])*)", q)
		Loop {
			If (!p := RegExMatch(j, "(?<!\\)(""|')([^\1]+?)(?<!\\)(?-1)\s*:\s*((\{(?:[^{}]++|(?-1))*\})|(\[(?:[^[\]]++|(?-1))*\])|"
				. "(?<!\\)(""|')[^\7]*?(?<!\\)(?-1)|[+\-]?\d+(?:\.\d*)?|true|false|null?)\s*(?:,|$|\})", x, p))
				Return
			Else If (x2 == q2 or q2 == "*") {
				j = %x3%
				z += p + StrLen(x2) - 2
				If (q3 != "" and InStr(j, "[") == 1) {
					StringTrimRight, q3, q3, 1
					Loop, Parse, q3, ], [
					{
						z += 1 + RegExMatch(SubStr(j, 2, -1), "^(?:\s*((\[(?:[^[\]]++|(?-1))*\])|(\{(?:[^{\}]++|(?-1))*\})|[^,]*?)\s*(?:,|$)){" . SubStr(A_LoopField, 1) + 1 . "}", x)
						j = %x1%
					}
				}
				Break
			}
			Else p += StrLen(x)
		}
	}
	If v !=
	{
		vs = "
		If (RegExMatch(v, "^\s*(?:""|')*\s*([+\-]?\d+(?:\.\d*)?|true|false|null?)\s*(?:""|')*\s*$", vx)
			and (vx1 + 0 or vx1 == 0 or vx1 == "true" or vx1 == "false" or vx1 == "null" or vx1 == "nul"))
			vs := "", v := vx1
		StringReplace, v, v, ", \", All
		js := SubStr(js, 1, z := RegExMatch(js, ":\s*", zx, z) + StrLen(zx) - 1) . vs . v . vs . SubStr(js, z + StrLen(x3) + 1)
	}
	Return, j == "false" ? 0 : j == "true" ? 1 : j == "null" or j == "nul"
		? "" : SubStr(j, 1, 1) == """" ? SubStr(j, 2, -1) : j
}