#SingleInstance, force
#Persistent

OnExit, _onexit
log := a_desktop "\movieslog.txt"

Gui, +alwaysontop
Gui, Add, Text, x12 y10 w130 h20 , Type Watchtvlinks URL
Gui, Add, Edit, x152 y10 w280 h20 vURL,
Gui, Add, Button, x332 y40 w100 h30 g_reload, Cancel / Reload
Gui, Add, GroupBox, x12 y70 w420 h110 , Progress
Gui, Add, Progress, x22 y90 w400 h10 -smooth vprog,0
Gui, Add, Text, x22 y110 w400 h60 vinfo,
Gui, Add, Button, x232 y40 w100 h30 gdownloadLinks vbtnD, Start Download
Gui, Show, w452 h195, Generate Download Links
return

GuiClose:
_onexit:
try {
	wb.Quit()
} catch e{
	;ignore
}
ExitApp

downloadLinks:
Gui, submit, nohide
GuiControl,disable, btnD
IfExist, % log
	FileDelete, % log
GuiControl,,info, Opening internet explorer
wb := ComObjCreate("InternetExplorer.Application")
wb.Visible := false
wb.Toolbar := false
wb.Silent := true
GuiControl,,info, Nagivating to %URL%
wb.Navigate(URL)
while wb.ReadyState != 4
	sleep, 30
GuiControl,,info, Load complete!
n := wb.Document.getElementById("recent").getElementsByTagName("a").length
groupLink =
loop, % n
	groupLink .= (groupLink = "" ? wb.Document.getElementById("recent").getElementsByTagName("a")[(A_Index -1)].href : "`n" wb.Document.getElementById("recent").getElementsByTagName("a")[(A_Index-1)].href)
MsgBox,0,Available links, % groupLink
/*
	attempting to download
*/
loop, parse, groupLink, `n
{
	url := A_LoopField
	GuiControl,,info, Navigating to %url%
	wb.Navigate(url)
	while wb.ReadyState != 4
		sleep, 30
	happylink =
	try{
		a := wb.Document.getElementById("allLinks").getElementsByTagName("a").length
		loop, % a
		{
			linkText := wb.Document.getElementById("allLinks").getElementsByTagName("a")[(A_Index - 1)].innerText
			if linkText contains happystreams
			{
				happylink := wb.Document.getElementById("allLinks").getElementsByTagName("a")[(A_Index - 1)].href
				break
			}
		}
		if happylink !=
		{
			GuiControl,,info, Navigating to %happylink%
			wb.Navigate(happylink)
			while wb.ReadyState != 4
				sleep, 30
			wb.Document.getElementById("btn_download").click()
			while wb.ReadyState != 4
				sleep, 30
			try {
				objects := wb.Document.getElementsByTagName("object")[0].getElementsByTagName("param").length
				loop, % objects
				{
					paramValue := wb.Document.getElementsByTagName("object")[0].getElementsByTagName("param")[(A_Index - 1)].value
					if paramValue contains http
					{
						dJunk := paramValue
						dJunk := uriDecode(dJunk)
						loop, parse, dJunk, `=
						{
							if a_loopfield contains flv
								dlink := A_LoopField
						}
						loop, parse, dlink, `&
						{
							if a_index = 1
							{
								dlink := A_LoopField
								FileAppend, (%url%)[%dlink%]`n,%log%
								GuiControl,,info, %dlink% saved!
							}
						}
					}
				}
			} catch e{
				MsgBox failed to get %happylink% video
			}			
		}
	} catch e{
		MsgBox There was an error downloading
	}
}

wb.Quit()
GuiControl,,info, Test complete with %n% links ready for download
GuiControl,disable, btnD
return

_reload:
Reload
return

uriDecode(str){
	Loop
		If RegExMatch(str, "i)(?<=%)[\da-f]{1,2}", hex)
			StringReplace, str, str, `%%hex%, % Chr("0x" . hex), All
		Else Break
	Return, str
}