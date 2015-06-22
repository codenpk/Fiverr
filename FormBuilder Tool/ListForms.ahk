#SingleInstance, force
#Persistent
#NoEnv

;created by MartinThuku - http://fiverr.com/martinthuku

SendMode Input
SetWorkingDir %A_ScriptDir%
DetectHiddenWindows, On
app = ListForms Form Builder Tools
helpLink = http://www.google.com
fontSizeDefault = 16

;creating the GUI menu - At the top
Menu, helpmenu, Add, Help Topics`tF1, subHelp
Menu, helpmenu, Add, About, subAbout
Menu, filemenu, Add, Reload, subReload
Menu, filemenu, Add, Close`tCtrl+Alt+Q, subClose
Menu, transp, Add, Transparency 50, trans50
Menu, transp, Add, Transparency 100, trans100
Menu, transp, Add, Transparency 150, trans150
Menu, transp, Add, Transparency Off, trans255
Menu, guiMenu, Add, File, :filemenu
Menu, guiMenu, Add, Help, :helpmenu
Menu, guiMenu, Add, Transparency, :transp

;tray icon menu
Menu, tray, nodefault
Menu, tray, nostandard
menu, tray, add, About, subAbout
menu, tray, add,
menu, tray, add, Reload, subReload
Menu, tray, add, Exit, subClose
return

^!L:: ;ctrl+alt+l - combination to launch the main user interface
Gui, destroy
Gui, Menu, guiMenu
;end of menu creation


;creating logo and using GDIP library to support PNG logo
If !pToken := Gdip_Startup()
{
	MsgBox, 262144, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
	ExitApp
}
OnExit, Exit
pBitmap := Gdip_CreateBitmapFromFile("res/listformsformbuilder.png")
Width := Gdip_GetImageWidth(pBitmap)
Height := Gdip_GetImageHeight(pBitmap)
hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
Gui, Add, Picture, x12 y10 w%Width% h%Height% 0xE vMyPicture
GuiControlGet, hwnd, hwnd, MyPicture
SetImage(hwnd, hBitmap)
;end of logo creation - see onExit for terminating GDIP

Gui, +alwaysontop -0x30000
Gui, Add, Tab2, x12 y80 w340 h430 , Actions|Add Hard Link|Add Other Links (SQL)|Display

Gui, Tab, Actions
Gui, Add, GroupBox, x22 y120 w320 h140 , Actions
Gui, Add, Button, x32 y140 w140 h30 gsubBeginHide vbeginHide, Begin Hide
Gui, Add, Button, x182 y140 w140 h30 gsubEndHide vendHide, End Hide
Gui, Add, Button, x32 y180 w140 h30 gstartRepeating vstartRepeating, Start Repeating List
Gui, Add, Button, x182 y180 w140 h30 gendRepeating vendRepeating, End Repeating List
Gui, Add, Button, x32 y220 w140 h30 ghideSButton vendHideSButton, Hide Submit Button
Gui, Add, GroupBox, x22 y270 w320 h230 , Show Items
Gui, Add, Button, x32 y290 w80 h30 gshowHiddenFields vshowHiddenFields, Show Fields
Gui, Add, Edit, x122 y290 w210 h20 vDrop ReadOnly,
Gui, Add, Button, x32 y330 w80 h30 gshowHiddenFields1 vshowHiddenFields1, Show Hidden
Gui, Add, Edit, x122 y330 w210 h160 vDrop1 -Wrap ReadOnly WantTab,

Gui, Tab, Add Hard Link
Gui, Add, GroupBox, x22 y120 w320 h130 , Add Hard Web Link
Gui, Add, Text, x32 y150 w90 h20 , Display Name
Gui, Add, Edit, x132 y150 w200 h20 vlinkDisplayName,
Gui, Add, Text, x32 y180 w90 h20 , URL (Web Link)
Gui, Add, Edit, x132 y180 w200 h20 vwebLink,
Gui, Add, Text, x32 y210 w90 h20 , Font Size
Gui, Add, Edit, x132 y210 w80 h20 vhfontSize,
Gui, Add, Button, x22 y260 w170 h30 gcreateHardLink vcreateHardLink, Create Hard Link
Gui, Add, Button, x22 y300 w170 h30 gcreateHardLink2 vcreateHardLink2, Create Hard Link (New Tab) ;TODO

Gui, Tab, Add Other Links (SQL)
Gui, Add, GroupBox, x22 y120 w320 h200 , Add Web Link From SQL
Gui, Add, Text, x32 y140 w80 h20 , Field Name
Gui, Add, Edit, x122 y140 w210 h20 vfieldName,
Gui, Add, Text, x32 y170 w80 h20 , Font Size
Gui, Add, Edit, x122 y170 w80 h20 vfontSize,
Gui, Add, Text, x32 y200 w80 h20 , SQL Name
Gui, Add, Edit, x122 y200 w210 h20 vSQLName,
Gui, Add, Text, x32 y230 w80 h40 , Fields To Pass (Separate with commas)
Gui, Add, Edit, x122 y230 w210 h40 vfieldsToPass,
Gui, Add, Button, x32 y280 w150 h30 gaddWebLink vaddWebLink, Add Web Link
Gui, Add, GroupBox, x22 y330 w320 h140 , Add OnLoad SQL Links
Gui, Add, Text, x32 y350 w80 h20 , SQL Name
Gui, Add, Edit, x122 y350 w210 h20 vOnLoadSQLname,
Gui, Add, Text, x32 y380 w80 h40 , Fields To Pass (Separate with commas)
Gui, Add, Edit, x122 y380 w210 h40 vOnLoadfieldstopass,
Gui, Add, Button, x32 y430 w150 h30 gaddSQLOnload vaddSQLOnload, Add SQL OnLoad

Gui, Tab, Display
Gui, Add, GroupBox, x22 y120 w320 h210 , Display Multiple Rows
Gui, Add, Text, x32 y140 w90 h20 , List Name
Gui, Add, Edit, x132 y140 w200 h20 vdispListName,
Gui, Add, Text, x32 y170 w90 h20 , SQL Name
Gui, Add, Edit, x132 y170 w200 h20 vdispSQLName,
Gui, Add, Text, x32 y200 w90 h40 , Fields To Pass (Separate with commas)
Gui, Add, Edit, x132 y200 w200 h40 vdispFieldsToPass,
Gui, Add, Button, x32 y250 w150 h30 gaddDispMultipleRows vaddDispMultipleRows, Add (Display Multiple Rows) ;TODO
Gui, Add, Button, x32 y290 w150 h30 gaddDispTable vaddDispTable, Add (Display Table) ;TODO
Gui, Show, w365 h525, %app%
return

;end of main UI
addDispMultipleRows:
	Gui, submit, nohide
	dispListName = %dispListName%
	dispSQLName = %dispSQLName%
	dispFieldsToPass = %dispFieldsToPass%
	if dispListName =
	{
		MsgBox, 262192, %app%, Please add List Name
		return
	}
	if dispSQLName =
	{
		MsgBox, 262192, %app%, Please add SQL Name
		return
	}
	gosub, disableControls
	addHTML("<div class='CustomList' id='" dispListName "' ></div>")
	try {
		hiddenFieldName = %dispListName%_options
		if dispFieldsToPass =
			addHiddenField(hiddenFieldName,dispSQLName)
		else
		{
			_items=
			loop, parse, dispFieldsToPass, `,
			{
				item = %A_LoopField%
				_items .= (_items = "" ? "[" item "]" : ",[" item "]")
			}
			addHiddenField(hiddenFieldName,dispSQLName "(" _items ")")
		}
	} catch e {
		MsgBox,262144,%app%, There was an error sending the SQL function
	}
	GuiControl,,dispListName,
	GuiControl,,dispSQLName,
	GuiControl,,dispFieldsToPass,
	gosub, enableControls
return

addDispTable:
	Gui, submit, nohide
	dispListName = %dispListName%
	dispSQLName = %dispSQLName%
	dispFieldsToPass = %dispFieldsToPass%
	if dispListName =
	{
		MsgBox, 262192, %app%, Please add List Name
		return
	}
	if dispSQLName =
	{
		MsgBox, 262192, %app%, Please add SQL Name
		return
	}
	gosub, disableControls
	addHTML("<div class='CustomList' id='" dispListName "' layout='table'></div>")
	try {
		hiddenFieldName = %dispListName%_options
		if dispFieldsToPass =
			addHiddenField(hiddenFieldName,dispSQLName)
		else
		{
			_items=
			loop, parse, dispFieldsToPass, `,
			{
				item = %A_LoopField%
				_items .= (_items = "" ? "[" item "]" : ",[" item "]")
			}
			addHiddenField(hiddenFieldName,dispSQLName "(" _items ")")
		}
	} catch e {
		MsgBox,262144,%app%, There was an error sending the SQL function
	}
	GuiControl,,dispListName,
	GuiControl,,dispSQLName,
	GuiControl,,dispFieldsToPass,
	gosub, enableControls
return

createHardLink2:
Gui, submit, nohide
linkDisplayName = %linkDisplayName%
webLink = %webLink%
hfontSize = %hfontSize%
if linkDisplayName =
{
	MsgBox, 262192, %app%, Please add a link display name
	return
}
if webLink =
{
	MsgBox, 262192, %app%, Please add a web link
	return
}
StringReplace,hfontSize,hfontSize,px,,all
StringReplace,hfontSize,hfontSize,pt,,all
if hfontSize !=
	hardLink = <a href='%weblink%' style='font-size:%hfontSize%pt;' target='_blank'>%linkDisplayName%</a>
else
	hardLink = <a href='%weblink%' style='font-size:%fontSizeDefault%pt;' target='_blank'>%linkDisplayName%</a>
gosub, disableControls
addHTML(hardLink)
GuiControl,,linkDisplayName,
GuiControl,,webLink,
GuiControl,,hfontSize,
gosub, enableControls
return

showHiddenFields1:
	gosub, disableControls
	in := 0
	iv := 0
	items =
	itemName := Object()
	itemValue := Object()
	try {
		page := GrabWidget()
		page.Document.getElementById("formproperties").click()
		els := page.Document.getElementById("form_properties_controls").getElementsByTagName("input").length
		loop, % els
		{
			try {
				thisel := page.Document.getElementById("form_properties_controls").getElementsByTagName("input")[A_Index].className
				if thisel contains hidden_input_attr_name
				{
					in ++
					itemName[in] := page.Document.getElementById("form_properties_controls").getElementsByTagName("input")[A_Index].title
				}
				if thisel contains hidden_input_attr_value
				{
					iv ++
					itemValue[iv] := page.Document.getElementById("form_properties_controls").getElementsByTagName("input")[A_Index].title
				}
			} catch e{
				;ignore error
			}
		}
		
		if in != 0
			if in = %iv%
				loop, % in
					items .= (items = "" ? itemName[A_Index] "`t" itemValue[A_Index] : "`n" itemName[A_Index] "`t" itemValue[A_Index])
	} catch e {
		MsgBox,262144,FormBuilderTool, There was an error`n %e%
	}
	GuiControl,,Drop1, % items
	gosub, enableControls
return

showHiddenFields:
	gosub, disableControls
	items =
	try {
		page := GrabWidget()
		e := page.Document.getElementById("docContainer").getElementsByTagName("div").length
		loop, % e
		{
			try {
				n := A_Index
				elength := page.Document.getElementById("docContainer").getElementsByTagName("div")[n].children.length
				loop, % elength
				{
					ename := page.Document.getElementById("docContainer").getElementsByTagName("div")[n].children[0].name
					ename = %ename%
					if ename !=
						items .= (items = "" ? ename : " | " ename)
				}
			} catch e {
				;ignore
			}
		}
	} catch e {
		MsgBox,262144,FormBuilderTool, There was an error`n %e%
	}
	GuiControl,,Drop, % items
	gosub, enableControls
return

GuiClose:
Gui, destroy
return

Exit:
Gdip_Shutdown(pToken) ;shutdown GDIP lib on close
ExitApp

subHelp:
Run, % helpLink
return

subAbout:
MsgBox, 262208, %app%, Form Builder Tool`nCopyright (c) 2015 DAVEMILLEROT
return

subReload:
Reload
return

subClose:
goto, Exit

disableControls:
controls =beginHide|endHide|endHideSButton|createHardLink|addWebLink|addSQLOnload|showHiddenFields|endRepeating|startRepeating|showHiddenFields1|addDispMultipleRows|addDispTable|createHardLink2
loop, parse, controls, `|
	GuiControl,Disable, % a_loopfield
return

enableControls:
controls =beginHide|endHide|endHideSButton|createHardLink|addWebLink|addSQLOnload|showHiddenFields|endRepeating|startRepeating|showHiddenFields1|addDispMultipleRows|addDispTable|createHardLink2
loop, parse, controls, `|
	GuiControl,Enable, % a_loopfield
return

addSQLOnload:
	Gui, submit, nohide
	OnLoadSQLname = %OnLoadSQLname%
	OnLoadfieldstopass = %OnLoadfieldstopass%
	if OnLoadSQLname =
	{
		MsgBox, 262192, %app%, Please add SQL Name
		return
	}
	gosub, disableControls
	try {
		page := GrabWidget()
		page.Document.getElementById("objectproperties").click()
		controlType := page.Document.getElementById("control_properties_set").getElementsByTagName("legend")[0].innerText
		controlName := page.Document.getElementById("fb-pp-input-name").value
		controlName = %controlName%
		if controlName =
			controlName := page.Document.getElementById("fb-pp-input-radiogroup").value
		controlName = %controlName%
		if controlName =
		{
			MsgBox,262144,%app%,We cant set SQL properties for this control, please select a valid form control
			gosub, enableControls
			return
		}
		if controlName contains text
			hiddenFieldName = %controlName%_value
		else
			hiddenFieldName = %controlName%_options
		if OnLoadfieldstopass =
			addHiddenField(hiddenFieldName,OnLoadSQLname)
		else
		{
			_items=
			loop, parse, OnLoadfieldstopass, `,
			{
				item = %A_LoopField%
				_items .= (_items = "" ? "[" item "]" : ",[" item "]")
			}
			addHiddenField(hiddenFieldName,OnLoadSQLname "(" _items ")")
		}
	} catch e {
		MsgBox,262144,%app%, There was an error sending the SQL function
	}
	GuiControl,,OnLoadSQLname,
	GuiControl,,OnLoadfieldstopass,
	gosub, enableControls
return

addWebLink:
Gui, submit, nohide
fieldName = %fieldName%
fontSize = %fontSize%
SQLName = %SQLName%
fieldsToPass = %fieldsToPass%
if fieldName =
{
	MsgBox, 262192, %app%, Please add a field name
	return
}
if fontSize =
	fontSize = %defaultFontSize%
if SQLName =
{
	MsgBox, 262192, %app%, Please add SQL Name
	return
}
if fieldsToPass =
{
	MsgBox, 262192, %app%, Please add fields to pass separated with commas.
	return
}
weblinksql = <div class='CustomUrls' id='%fieldName%' style='font-size: %fontSize%pt;'></div>
hiddenFieldName = %fieldName%_options
ftpass =
loop,parse,fieldsToPass, `,
{
	value = %A_LoopField%
	ftpass .= (ftpass=""?"[" value "]" : ",[" value "]")
}
hiddenFieldValue = %SQLName%(%ftpass%)
gosub, disableControls
addHTML(weblinksql)
sleep, 500 ;logical delay
addHiddenField(hiddenFieldName,hiddenFieldValue)
GuiControl,,fieldName,
GuiControl,,fontSize,
GuiControl,,SQLName,
GuiControl,,fieldsToPass,
gosub, enableControls
return

createHardLink:
Gui, submit, nohide
linkDisplayName = %linkDisplayName%
webLink = %webLink%
hfontSize = %hfontSize%
if linkDisplayName =
{
	MsgBox, 262192, %app%, Please add a link display name
	return
}
if webLink =
{
	MsgBox, 262192, %app%, Please add a web link
	return
}
StringReplace,hfontSize,hfontSize,px,,all
StringReplace,hfontSize,hfontSize,pt,,all
if hfontSize !=
	hardLink = <a href='%weblink%' style='font-size:%hfontSize%pt;'>%linkDisplayName%</a>
else
	hardLink = <a href='%weblink%' style='font-size:%fontSizeDefault%pt;'>%linkDisplayName%</a>
gosub, disableControls
addHTML(hardLink)
GuiControl,,linkDisplayName,
GuiControl,,webLink,
GuiControl,,hfontSize,
gosub, enableControls
return

endRepeating:
gosub, disableControls
addHTML("<div id='RepeatingFieldsStop'></div>")
gosub, enableControls
return

startRepeating:
gosub, disableControls
addHTML("<div id='RepeatingFieldsStart'></div>")
gosub, enableControls
return

hideSButton:
gosub, disableControls
addHTML("<style>#fb-submit-button{display:none;}</style>")
gosub, enableControls
return

subEndHide:
gosub, disableControls
addHTML("<div id='HideStop'></div>")
gosub, enableControls
return

subBeginHide:
gosub, disableControls
addHTML("<div id='HideStart'></div>")
gosub, enableControls
return

trans100:
WinSet, trans, 100, %app%
return

trans50:
WinSet, trans, 50, %app%
return

trans150:
WinSet, trans, 150, %app%
return

trans255:
WinSet, trans, 255, %app%
return

;important - loading the functions in use
#Include res/functions.ahk