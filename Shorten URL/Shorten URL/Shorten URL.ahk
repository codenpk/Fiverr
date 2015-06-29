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
	To get the converter url, upload the convert_bitly.php I have attached in this bundle to your server and provide its url here without the paramenters
	e.g. 
	converter=http://yourdomain.com/convert_bitly.php
	AVOID using http://localhost. Might give you a headache. I didnt get a solution there
*/

converter:="http://mxd.vacau.com/convert_bitly.php" ;this is mine - its made from 000webhost.com

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


convert(url){ ;THIS IS THE MAIN FUNCTION BABY
	global token ;or you can replace this with the variable token
	global converter ;or you can replace this with the variable converter. See top
	
	
	url := UriEncode(url) ;urlencode the url
	url_data = %converter%?url=%url%&token=%token%
	
	
	pwb := ComObjCreate("InternetExplorer.Application")
	pwb.Visible := false
	pwb.ToolBar := false
	pwb.Navigate(url_data) 
	While pwb.ReadyState != 4
		Sleep 100
	
	short_url := pwb.document.getElementById("output").innerText
	;short_url := pwb.document.getElementsByTagName("div").length
	pwb.quit() ;;IMPORTANT TO QUIT THE IE
	
	return short_url	
}

isurl(url){
	return RegExMatch(url, "^(https?://|www\.)[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(/\S*)?$")
}

/*
	THESE BELOW ARE FUNCTIONS TO ENCODE URL WITH AHK
*/
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