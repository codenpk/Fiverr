#SingleInstance, force
#Persistent

^!p::
Gui, Destroy
Gui, +AlwaysOnTop +ToolWindow
Gui, Add, Edit, x2 y2 w200 h50 vpaste gpaste,
Gui, Show, w204 h54,Paste link to copy LargeImage URL
return

GuiClose:
GuiEscape:
Gui, Destroy
return

paste:
Gui, submit
paste = %paste%
xml := getSource(paste)
if xml !=
{
	StringReplace,xml2,xml,LargeImage,•,all
	StringReplace,xml2,xml2,<URL>,|,all
	StringReplace,xml2,xml2,</URL>,|,all
	loop, parse, xml2, `•
	{
		if a_index = 2
		{
			loop, parse, a_loopfield, `|
			{
				if a_index = 2
				{
					Clipboard := A_LoopField
					TrayTip,getLargeImage, First LargeImage URL has been copied to clipboard!`n`n%A_LoopField%
					return
				}
			}
		}
	}
}
MsgBox,4,getLargeImage,Your URL did not return a correct XML`, do you want to copy what the link returned?
IfMsgBox, No
	return
Clipboard := xml
TrayTip, getLargeImage, %paste%`nResults have been copied to the clipboard
return

getSource(link){
	try {
		request := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		request.Open("GET", link, true)
		request.Send()
		request.WaitForResponse()
		source := request.ResponseText
		return source
	}
	catch e
	{
		return ""
	}
}