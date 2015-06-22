#SingleInstance,force
#Persistent
#NoEnv

/*	
	IF YOU LIKE GIVE ME A SHOUT OUT AT @martinirenes - twitter. I love making friends
	To get the token, which is very important here, make sure you log in to your account and access this link:
	https://bitly.com/a/oauth_apps
	Generate a token and paste it in the variable token here below
*/

token:="1e302efa292498b648474dd823f7c3ba804ce2f7" ;this is mine

/*
	Here is a sample interface to get the long url from the user
*/
Gui, Font, S20 CDefault, Arial
Gui, Add, Text, x12 y10 w250 h40 vinfo, Shorten URL ;;for title and progress
Gui, Font, S10 CDefault, Arial
Gui, Add, Edit, x12 y60 w340 h30 vpaste,
Gui, Add, Button, x362 y60 w100 h30 gshorten, Shorten
Gui, Add, Edit, x12 y100 w340 h30 ReadOnly vout,
Gui, Add, Button, x362 y100 w100 h30 gcopy Disabled vcopy, Copy
Gui, Show, w479 h149, Shorten URL
return

GuiClose:
ExitApp

shorten: ;called when the user clicks shorten
Gui,submit,nohide
if isurl(paste)
{
	;;lets start to convert the url
	GuiControl,,info,Shortening... ;lets tell the user the progress is going on
	data := convert(paste) ;get the short url or the "failed"
	
	if data = failed
		MsgBox,0,Shorten URL,Something went wrong with your access token or url
	else
	{
		GuiControl,Enable,copy
		GuiControl,,out,%data%
	}
	GuiControl,,info,Shorten URL ;lets return to our original state now that the work is done	
}
else
{
	MsgBox,0,Shorten URL,Thats not a url
	GuiControl,Disable,copy
	GuiControl,,out,
}
return

copy: ;called when the user clicks copy
Gui,submit,nohide
Clipboard := out
MsgBox,0,Shorten URL,Copied!
return

convert(url){
	global token ;or you can replace this with the variable token
	global converter ;or you can replace this with the variable converter. See top
	
	
	url := UriEncode(url) ;urlencode the url
	url_data=https://api-ssl.bitly.com/v3/shorten?access_token=%token%`&longUrl=%url% ;this is the api from bitly for converting
	
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1") ;JUST DOWNLOAD JSON DATA TO A VARIABLE
	whr.Open("GET", url_data)
	whr.Send()
	data := whr.ResponseText
	data := json(data, "data.url") ;get url from JSON
	StringReplace,data,data,`\,,all ;clean up
	return data ;return the short url
}

isurl(url){ ;returns true if you have passed a valid url
	return RegExMatch(url, "^(https?://|www\.)[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(/\S*)?$")
}

/*
	THESE BELOW ARE FUNCTIONS TO ENCODE URL WITH AHK
*/ 
UriEncode(Uri, Enc = "UTF-8"){  ;returns a url decoded string 
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

StrPutVar(Str, ByRef Var, Enc = ""){ ;for use by the url encoder
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