#SingleInstance, force
#Persistent
#NoTrayIcon
#NoEnv

Gui, +alwaysontop
Gui, Font, S12 CDefault, Consolas
Gui, Add, Text, x12 y10 w310 h20 cRed, TinyTube Downloader
Gui, Font, S8 CDefault, Consolas
Gui, Add, Text, x12 y40 w60 h20 , Paste URL
Gui, Add, Edit, x72 y40 w250 h20 vurl gisyoutubelink,
Gui, Add, Button, x2 y70 w110 h30 gdownload vdownload, Start Download
Gui, Add, Progress, x113 y70 w210 h10 -smooth, 25
Gui, Add, Text, x113 y80 w210 h20 , Downloading 10 or 45
Gui, Show, w335 h114, TinyTube - By Fiverr/martinthuku
return

GuiClose:
ExitApp


isyoutubelink:
return

download:
Gui, submit, nohide
l := UriDecode(url)
MsgBox % l
return

; modified from jackieku's code (http://www.autohotkey.com/forum/post-310959.html#310959)
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

UriDecode(Uri, Enc = "UTF-8")
{
	Pos := 1
	Loop
	{
		Pos := RegExMatch(Uri, "i)(?:%[\da-f]{2})+", Code, Pos++)
		If (Pos = 0)
			Break
		VarSetCapacity(Var, StrLen(Code) // 3, 0)
		StringTrimLeft, Code, Code, 1
		Loop, Parse, Code, `%
			NumPut("0x" . A_LoopField, Var, A_Index - 1, "UChar")
		StringReplace, Uri, Uri, `%%Code%, % StrGet(&Var, Enc), All
	}
	Return, Uri
}

StrPutVar(Str, ByRef Var, Enc = "")
{
	Len := StrPut(Str, Enc) * (Enc = "UTF-16" || Enc = "CP1200" ? 2 : 1)
	VarSetCapacity(Var, Len, 0)
	Return, StrPut(Str, &Var, Enc)
}