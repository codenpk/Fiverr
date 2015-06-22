#SingleInstance,force
#Persistent
;#NoTrayIcon ;TODO - remove this comment
#Include DB.ahk
Menu, FileMenu, Add, &Open`tCtrl+O, MenuFileOpen  ; See remarks below about Ctrl+O.
Menu, FileMenu, Add, E&xit, MenuHandler
Menu, HelpMenu, Add, &About, MenuHandler
Menu, MyMenuBar, Add, &File, :FileMenu  ; Attach the two sub-menus that were created above.
Menu, MyMenuBar, Add, &Help, :HelpMenu
Gui, Menu, MyMenuBar
ImageListID := IL_Create(100)
Loop 100
    IL_Add(ImageListID, "shell32.dll", A_Index)
Gui, +Resize +MinSize500x300
Gui, Add, TreeView, x12 y10 w220 h550 ImageList%ImageListID% vtv gtv AltSubmit,
Gui, Font, S16 CDefault, Verdana
Gui, Add, Text, x242 y10 w300 h30 , Claims Tracking Manager
Gui, Font, S10 CDefault, Verdana
Gui, Add, Text, x+5 y10 w300 h30 cGray vselectedInfo,
Gui, Font, S8 CDefault, Verdana
Gui, Add, Tab2, x242 y50 w760 h510 vtabs, Claims Tracking Sheet|Summary

Gui, Tab, Claims Tracking Sheet
Gui, Add, ListView, x252 y80 w737 h460 +Grid -Multi AltSubmit vlistmain,BATCH NUMBER|MSP|MONTH|YEAR|DATE RECEIVED|CLAIM NATURE|TOTAL INVOICE AMOUNT|CREDIT NOTES|RESUBMISSION|NET INVOICED AMOUNTS|COUNT OF CLAIMS|REMITTANCE AMT|PAYABLE AMT|MANUAL CLAIMS(OFF THE SYSTEM)|DATE APPROVED|DATE SUBMITTED|SUBMITTED BY|REMARKS|DAYS IN CLAIMS|VARIANCE|REASON FOR VARIANCE

Gui, Tab, Summary
Gui, Add, ListView, x252 y80 w737 h460 +Grid -Multi -Hdr vlistsum,Summary

Gui, Add, statusbar
Gui, Show, w1021 h590, Claims Tracking Manager
gosub, defaultData
return

GuiClose:
ExitApp

GuiSize:
GuiControl,movedraw,tv,% "h" (A_GuiHeight-40)
GuiControl,movedraw,tabs,% "w" (A_GuiWidth-250) " h" (A_GuiHeight-80)
GuiControl,movedraw,listmain,% "w" (A_GuiWidth-270) " h" (A_GuiHeight-120)
GuiControl,movedraw,listsum,% "w" (A_GuiWidth-270) " h" (A_GuiHeight-120)
return

defaultData:
Gui, 1: Default
;set the status bar data
SB_SetParts(200,200)
SB_SetText("Logged on as " a_username,1)
SB_SetText("Please select a Month",2)
SB_SetText("`t`t" A_DD "/" A_MM "/" A_YYYY " " A_Hour ":" A_Min,3)
;set the treeview data
regions = KENYA|TANZANIA|UGANDA
loop,parse,regions,`|
{
	regionTV := TV_Add(a_loopfield,0,"Icon86 +Bold")
	years = 2015
	loop,parse,years,`|
		x := A_Index
	loop,parse,years,`|
	{
		yy := A_LoopField
		yearTV := TV_Add(a_loopfield,regionTV,"Icon4 +Bold")
		if a_index = %x%
			currentYear := yearTV
		months = JANUARY|FEBRUARY|MARCH|APRIL|MAY|JUNE|JULY|AUGUST|SEPTEMBER|OCTOBER|NOVEMBER|DECEMBER
		loop,parse,months,`|
		{
			monthTV := TV_Add(a_loopfield,yearTV,"Icon55 +Bold")
			if a_loopfield = %a_MMMM%
			{
				currentMonth := monthTV
				if yy = %a_yyyy%
					break
			}
		}
	}
}
return

selectMonth:
return

tv:
isMonth := false
isYear := false
isCountry := false

itemID := TV_GetSelection()
if itemID = 0
	return
pitemID := TV_GetParent(itemID)
ppitemID := TV_GetParent(pitemID)

if ppitemID = 0
	if  pitemID = 0
		isCountry := true
	else
		isYear := true
else
	isMonth := true

if A_GuiEvent = RightClick
{
	Menu,tvmenu,add,Load,menuhandler
	Menu,tvmenu,add,Search,menuhandler
	Menu,tvmenu,add,Refresh,menuhandler
	if isMonth = 1
	{
		Menu,tvmenu,add,
		Menu,tvmenu,add,Add batch,menuhandler
	}
	Menu,tvmenu,show
}

if isMonth
{
	TV_GetText(tv_month,itemID)
	TV_GetText(tv_year,pitemID)
	TV_GetText(tv_country,ppitemID)
	tv_month := ccase(SubStr(tv_month,1,3))
	tv_country := ccase(tv_country)
	guicontrol,,selectedInfo, % tv_country " " tv_month " " tv_year
	SB_SetText(tv_country " " tv_month " " tv_year,2)
}
if isYear
{
	TV_GetText(tv_year,itemID)
	TV_GetText(tv_country,pitemID)
	tv_country := ccase(tv_country)
	guicontrol,,selectedInfo, % tv_country " " tv_year
	SB_SetText(tv_country " " tv_year,2)
}
if isCountry
{
	TV_GetText(tv_country,itemID)
	tv_country := ccase(tv_country)
	guicontrol,,selectedInfo, % tv_country
	SB_SetText(tv_country,2)
}
return

MenuFileOpen:
MenuHandler:
return

ccase(str){
	loop,parse,str,%a_space%
	{
		word := A_LoopField
		n := StrLen(word)
		StringMid,fchar,word,1,1
		ochars := SubStr(word,2,(n - 1))
		StringUpper,fchar,fchar
		StringLower,ochars,ochars
		new_str := (new_str = "" ? fchar ochars : new_str " " fchar ochars)
	}
	return new_str
}