/*
	Form Builder Tool
	Copyright (c) 2015 DAVEMILLEROT
	Created By Martin Thuku http://fiverr.com/martinthuku
*/

#SingleInstance, force
#Persistent
#NoEnv
;#NoTrayIcon

SendMode Input
SetWorkingDir %A_ScriptDir%
DetectHiddenWindows, On
app = ListForms.com - CoffeeCup Extentions
helpLink = http://www.google.com


^!L:: 
SetTitleMatchMode, 2
IfWinNotExist, CoffeeCup Web Form
{
	MsgBox, 262144, ListForms.com - CoffeeCup Extentions, Please open CoffeeCup form builder in order to continue
	return
}

WinGet, winid, id, CoffeeCup Web Form
;;since you requested for logo support, you should know that autohotkey does not support transparency of .png images
;;as a result, we will use GDIP library to render logo. This should not worry you, the library has been taken care of
;logo support
If !pToken := Gdip_Startup()
{
	MsgBox, 262144, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
	ExitApp
}
OnExit, Exit
pBitmap := Gdip_CreateBitmapFromFile("res/logo2.png") ;I have placed the logo in the folder res/logo2.png - you can replace this
Width := Gdip_GetImageWidth(pBitmap)
Height := Gdip_GetImageHeight(pBitmap)
hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
Gui, Add, Picture, x12 y10 w%Width% h%Height% 0xE vMyPicture
GuiControlGet, hwnd, hwnd, MyPicture
SetImage(hwnd, hBitmap)
;end of logo support

;;we add the help menu
Menu, helpmenu, add, Help Topics, help ;calls the help sub
Menu, help, add, Help, :helpmenu
Gui, Menu, help
Gui, +alwaysontop
Gui, Add, GroupBox, x12 y110 w290 h60 , Hide Element
Gui, Add, Button, x22 y130 w130 h30 gbeginHide vbeginHideBtn, Begin Hide
Gui, Add, Button, x162 y130 w130 h30  gendHide vendHideBtn, End Hide
Gui, Add, Button, x12 y180 w290 h30 ghideButton vhideButtonBtn, Hide Submit Button
Gui, Add, GroupBox, x12 y220 w290 h100 , Add Onload SQL Links
Gui, Add, Text, x22 y240 w90 h30 , Enter SQL name from Listform:
Gui, Add, Edit, x112 y240 w180 h20 vSQLName,
Gui, Add, Button, x112 y270 w180 h30 gaddOnloadSQL vaddOnloadSQLbtn, Add SQL Onload
Gui, Show, w321 h331, %app%
return

GuiClose:
Exit:
Gdip_Shutdown(pToken) ;shutdown GDIP lib on close
ExitApp

help:
Run, % helpLink
return

beginHide:
GuiControl, disable, beginHideBtn
addHTML("<div id='HideStart'></div>")
GuiControl, enable, beginHideBtn
return

endHide:
GuiControl, disable, endHideBtn
addHTML("<div id='HideStop'></div>")
GuiControl, enable, endHideBtn
return

hideButton:
GuiControl, disable, hideButtonBtn
addHTML("<style>#fb-submit-button{display:none;}</style>")
GuiControl, enable, hideButtonBtn
return

addOnloadSQL:
Gui, submit, nohide
SQLName = %SQLName%
if SQLName =
	return
GuiControl, disable, addOnloadSQLBtn
SetTitleMatchMode, 2
try {
	page := GrabWidget() ;Important get the main control control_properties_set
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
		GuiControl, Enable, addOnloadSQLBtn
		return
	}
	page.Document.getElementById("formproperties").click() ;click form properties
	page.Document.getElementById("formproperties").focus() ;focus form properties
	ControlSend,,{Tab}{ShiftDown}{End}{ShiftUp}, CoffeeCup Web Form ;scroll
	page.Document.getElementById("addhiddenitem").click() ;click the plus button
	sleep, 100 ;logical delay
	if controlType contains %_options% ;check if we need to send _options
		ControlSend,,%controlName%_options{tab}%SQLName%,CoffeeCup Web Form
	else
		ControlSend,,%controlName%_value{tab}%SQLName%,CoffeeCup Web Form
	GuiControl,,SQLName,
} catch e {
	MsgBox,262144,%app%, There was an error sending the SQL function
}
GuiControl, enable, addOnloadSQLBtn
return

;;main functions
addHTML(html){
	SetTitleMatchMode, 2
	global app
	try {
		page := GrabWidget() ;get the main control
		page.Document.getElementById("elements").click() ;click elements tab
		sleep, 100
		page.Document.getElementById("tool_html").click() ;click HTML element
		sleep, 100 ;logical wait
		page.Document.getElementById("objectproperties").click() ;click properties to view code - this also enforces the changes
		sleep, 100 ;logical wait
		page.Document.getElementById("fb-html-content-textarea").value := html ;set text to the properties editor
		page.Document.getElementById("fb-html-content-textarea").focus() ;focus on the textarea so that we can press keyboard for the hack implementation
		ControlSend,,{CtrlDown}{end}{Ctrlup}{space}, CoffeeCup Web Form ;hack to make sure the changes have been implemented
		sleep, 100
		page.Document.getElementById("objectproperties").click() ;click properties again - this also enforces the changes
	} catch e {
		MsgBox,262144,%app%,There was a problem adding HTML element 
	}
}

;IMPORTANT - I have placed the library code in a file called lib.ahk for cleaner code.
#Include res/lib.ahk ;we load the library containing crucial functions