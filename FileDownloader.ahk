;*********************************************************
;|		Creating The File Downloader					|;
;|		Copyright (c) fiverr.com/Fixedforever			|;
;|		Created By fiverr.com/martinthuku				|;
;|		All rights reserved								|;
;*********************************************************

#SingleInstance, force
#Persistent
#NoEnv
#NoTrayIcon

Gui, +alwaysontop
Gui, Add, GroupBox, x2 y0 w460 h90, 
Gui, Add, Text, x12 y20 w100 h20 , Enter the URL
Gui, Add, Edit, x112 y20 w340 h20 vurl gisurl,http://feeds.feedburner.com/freakonomicsradio
Gui, Add, Text, x12 y50 w100 h20 , File Extensions
Gui, Add, DropDownList, x112 y50 w70 h200 choose1 vext, *.mp3|*.mp4|*.wav|*.wma|*.jpg|*.png|*.gif|*.*
Gui, Add, Button, x202 y50 w250 h30 vfetchfiles gfetchfiles, Fetch Files
Gui, Add, ListView, x2 y100 w460 h260 Checked vlist AltSubmit +Grid grightclicklist,Status|File URL
Gui, Add, Button, x12 y370 w100 h30 gcheckall vcheckall Disabled, Check All
Gui, Add, Button, x112 y370 w100 h30 guncheckall vuncheckall Disabled, Un-Check All
Gui, Add, Button, x252 y370 w200 h30 gdownload vdownload Disabled, Download Selected
Gui, Show, w468 h411,Download File (By Fixedforever)
return

GuiClose:
ExitApp

rightclicklist:
r := A_EventInfo
if r = 0
	return
if A_GuiEvent != RightClick
	return
LV_GetText(selectedURL, r, 2)
Menu, rightclicklistitem, add
Menu, rightclicklistitem, DeleteAll
Menu, rightclicklistitem, add, Copy URL, copyLink
Menu, rightclicklistitem, show
return

copyLink:
Clipboard := selectedURL
return

isurl:
Gui, submit, nohide
if isurl(url)
	GuiControl, enable, fetchfiles
else
	GuiControl, disable, fetchfiles
return

fetchfiles:
Gui, submit, nohide
GuiControl, disable, fetchfiles
GuiControl,,fetchfiles,Please wait...
p := ComObjCreate("WinHttp.WinHttpRequest.5.1")
p.Open("GET", url, true)
p.Send()
p.WaitForResponse()
data := p.ResponseText
StringReplace,data,data,`",%a_space%`"%a_space%,all
StringReplace,data,data,`',%a_space%`'%a_space%,all
data2 := fetchLinks(data)
LV_Delete()
GuiControl, -Redraw, list
loop, parse, data2, `n
{
	SplitPath, a_loopfield,,,_ext
	StringReplace,ext,ext,*.,,all
	if _ext = %ext%
		LV_Add("Check","Ready for download",a_loopfield)
}
n := LV_GetCount()
if n != 0
{
	GuiControl, enable, checkall
	GuiControl, enable, uncheckall
	GuiControl, enable, download
}
else
{
	GuiControl, disable, checkall
	GuiControl, disable, uncheckall
	GuiControl, disable, download
}
loop, % lv_getcount("Col")
	LV_ModifyCol(a_index,"AutoHdr")
GuiControl, +Redraw, list
GuiControl, enable, fetchfiles
GuiControl,,fetchfiles,Fetch Files
return

download:
WinSet,alwaysontop, off,Download File (By Fixedforever)
FileSelectFolder,fol,%a_desktop%,1,Select destination folder
if errorlevel
{
	WinSet,alwaysontop, on,Download File (By Fixedforever)
	return
}
if fol =
{
	WinSet,alwaysontop, on,Download File (By Fixedforever)
	return
}
WinSet,alwaysontop, on,Download File (By Fixedforever)
Gui, submit, nohide
GuiControl, disable, checkall
GuiControl, disable, uncheckall
GuiControl, disable, fetchfiles
GuiControl, disable, download
GuiControl,, download, Downloading...
row := LV_GetNext(0)
loop
{
	row := LV_GetNext(row,"Checked")
	if not row
		break
	LV_GetText(fileURL,a_index,2)
	LV_Modify(row,,"Loading...")
	SplitPath,fileURL,fileName
	destFile = %fol%\%fileName%
	getFile(row,fileURL,destFile,True) ;getFile(row,fileURL,destFile,False) - false if you dont want overwrites
	LV_Modify(row,,"Download Complete!")
}
GuiControl, enable, checkall
GuiControl, enable, uncheckall
GuiControl, enable, fetchfiles
GuiControl, enable, download
GuiControl,, download, Download Selected
return

uncheckall:
loop, % lv_getcount()
	LV_Modify(a_index,"-Check")
return

checkall:
loop, % lv_getcount()
	LV_Modify(a_index,"Check")
return


;functions
fetchLinks(haystack){
	plink =
	links =
	p = 0
	loop
	{
		n := p + StrLen(plink) + 1
		p := RegExMatch(haystack, "(https?://|www\.)[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(/\S*[^\.\'\?\\\s\,\?])?", link, n)
		if p = 0
			break
		links .= (links = "" ? link : "`n" link)
		plink = %link%
	}
	Sort, links, U D`n
	return links
}

isurl(url){
	return RegExMatch(url, "^(https?://|www\.)[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(/\S*[^\.\'\?\\\s\,\?])?$")
}

getFile(ListRow,URL,Dest,Overwrite := True){
	if Overwrite
		FileDelete, % Dest
	WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	WebRequest.Open("HEAD", URL)
	WebRequest.Send()
	FinalSize := WebRequest.GetResponseHeader("Content-Length")
	SetTimer, _updateStatus, 100
	UrlDownloadToFile, %URL%, %Dest%
	return
	
	_updateStatus:
	SetTimer, _updateStatus, off
	global List
	Gui, 1: default
	CurrentSize := FileOpen(Dest, "r").Length
	CurrentSizeTick := A_TickCount
	Speed := Round((CurrentSize/1024-LastSize/1024)/((CurrentSizeTick-LastSizeTick)/1000)) . " Kb/s"
	LastSizeTick := CurrentSizeTick
	LastSize := FileOpen(Dest, "r").Length
	PercentDone := Round(CurrentSize/FinalSize*100)
	SetFormat,float, 20.2
	d := (LastSize/1024)/1000
	f := (FinalSize/1000)/1000
	d = %d%
	f = %f%
	LV_Modify(ListRow,,"Downloading " d "Mbs of " f "Mbs " PercentDone "`% " Speed)
	LV_ModifyCol(1,"AutoHdr")
	SetTimer, _updateStatus, 100
	Return
}