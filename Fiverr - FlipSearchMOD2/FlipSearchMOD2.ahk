#SingleInstance, force
#Persistent
#NoEnv
#NoTrayIcon

ID := "flipkarto15"
TOKEN := "efdc2ea0394b4585a5854704b22b788a"

Menu, listmenu, Add, Copy ID,copy_pid
Menu, listmenu, Add, Copy Title,copy_title
Menu, listmenu, Add, Copy Link,copy_link
Gui +LastFound
hWnd := WinExist()
Gui, Add, GroupBox, x12 y10 w450 h90 vinfo, 
Gui, Add, Text, x22 y30 w120 h20 , Query / Product URL
Gui, Add, Edit, x142 y30 w310 h20 vquery,
Gui, Add, Button, x352 y60 w100 h30 gsearch Default vsearch, Search
Gui, Add, ListView, x12 y110 w450 h250 -Multi +Grid vlistview glist AltSubmit,ID|TITLE|URL
Gui, Show, w474 h369, FlipCart - Search
DllCall( "RegisterShellHookWindow", UInt,Hwnd )
MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
OnMessage( MsgNum, "ShellMessage" )
Return

ShellMessage( wParam,lParam )
{
	WinGetTitle, title, ahk_id %lParam%
	If (wParam=4) {
		if title = FlipCart - Search
		{
			GuiControl,focus,query
			Send, ^a
		}
	}
}

GuiSize:
if errorlevel = 0
{
	GuiControl,focus,query
	Send, ^a
}
return

#IfWinActive, FlipCart - Search ;this is to fix the Ctrl+Backspace
^BackSpace::
Send, ^+{left}{delete}
return
#IfWinActive

list:
n := LV_GetNext()
if n = 0
	return
if a_guievent = DoubleClick
{
	LV_GetText(pid,n,1)
	Clipboard := pid
	MsgBox, 64, FlipCart Search, %pid% has been copied to the clipboard
}
if a_guievent = RightClick
	menu, listmenu, show
return

copy_pid:
LV_GetText(pid,n,1)
Clipboard := pid
MsgBox, 64, FlipCart Search, %pid% has been copied to the clipboard
return

copy_title:
LV_GetText(title,n,2)
Clipboard := title
MsgBox, 64, FlipCart Search, %title% has been copied to the clipboard
return

copy_link:
LV_GetText(link,n,3)
Clipboard := link
MsgBox, 64, FlipCart Search, %link% has been copied to the clipboard
return

GuiClose:
ExitApp

search:
Gui, submit, nohide
query = %query%
if query =
	return
if isUrl(query)
	goto, search_link
else
	goto, search_query
return

search_link:
GuiControl,-Redraw,listview
LV_Delete()
GuiControl,+Redraw,listview
GuiControl,disable, query
GuiControl,disable, search
GuiControl,, info, Please wait...
if query contains pid
{
	StringReplace, xq, query, pid=,•,all
	loop,parse, xq, `•
		if a_index = 2
			pidq = %A_LoopField%
	
	loop,parse, pidq, `&
		if a_index = 1
			pida = %A_LoopField%
		
	item_ID = %pida%
}
else 
{
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET", query, true)
	whr.Send()
	whr.WaitForResponse()
	htmlpage := whr.ResponseText
	StringReplace,htmlpage,htmlpage,%a_space%,,all
	StringReplace,htmlpage,htmlpage,pid=`",•
	loop, parse, htmlpage, `•
	{
		if a_index = 2
			loop,parse,a_loopfield,`"
				if a_index = 1
					item_ID = %A_LoopField%
	}
}
item_ID = %item_ID%
if item_ID contains %a_space%
	MsgBox, 48, FlipCart Search, There was a problem getting the product ID from the link "%query%" it might not be a valid product URL
if item_ID =
	MsgBox, 48, FlipCart Search, There was a problem getting the product ID from the link "%query%" it might not be a valid product URL
else
{
	MsgBox, 68, FlipCart Search, The product ID for the URL "%query%" is:`n`n%item_ID%`n`nCopy to clipboard?
	IfMsgBox, Yes
		Clipboard := item_ID
}
htmlpage =
GuiControl,enable, query
GuiControl,enable, search
GuiControl,, info,
return

search_query:
GuiControl,disable, query
GuiControl,disable, search
GuiControl,, info, Please wait...
request := ComObjCreate("WinHttp.WinHttpRequest.5.1")
request.Open("GET", "https://affiliate-api.flipkart.net/affiliate/search/json?query=" query "&resultCount=20", False)
request.SetRequestHeader("Fk-Affiliate-Id", ID)
request.SetRequestHeader("Fk-Affiliate-Token", TOKEN)
request.SetRequestHeader("User-Agent", "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)")
request.SetRequestHeader("Referer", "https://affiliate-api.flipkart.net")
request.Send()
data := request.ResponseText
GuiControl,-Redraw,listview
LV_Delete()
loop
{
	item_ID := json(data,"productInfoList[" A_Index "].productBaseInfo.productIdentifier.productId")
	item_ID = %item_ID%
	if item_ID =
		break
	item_title := json(data,"productInfoList[" A_Index "].productBaseInfo.productAttributes.title")
	item_link := json(data,"productInfoList[" A_Index "].productBaseInfo.productAttributes.productUrl")
	LV_Add("",item_ID,item_title,item_link)
}
loop, % lv_getcount("Col")
	LV_ModifyCol(a_index,"AutoHdr")
GuiControl,+Redraw,listview
GuiControl,enable, query
GuiControl,enable, search
GuiControl,, info,
return

isUrl(l){
	if l contains http://,https://,www.,ftp://
		return true
	return false
}

;very important
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