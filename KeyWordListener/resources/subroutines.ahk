; This contains the subroutines being used by KeywordListener.ahk

if app =
	ExitApp ;this prevents directly accessing this script - its supposed to be loaded by ../KeywordListenet.ahk

;these are the subroutines called from the main script
reload:
Reload
return

exit:
ExitApp

F6:: ;you can press F6 to open the settings window as well
config: ;called from the tray menu - Settings
;we create the user interface for the settings - I will not explain the GUI elements (You may refer to it on https://www.autohotkey.com/docs/commands/Gui.htm)
Gui, +Alwaysontop ;make the window always ontop
Gui, Add, GroupBox, x12 y10 w290 h140 , Main Configurations
Gui, Add, Text, x22 y30 w110 h20 , Application Title
Gui, Add, Edit, x132 y30 w160 h20 v__applicationtitle, %applicationtitle%
Gui, Add, Text, x22 y60 w110 h20 , Application control
Gui, Add, Edit, x132 y60 w160 h20 v__applicationcontrol, %applicationcontrol%
Gui, Add, Text, x22 y90 w110 h20 , Keywords
Gui, Add, Edit, x132 y90 w160 h20 v__keywords, %keywords%
Gui, Add, Text, x22 y120 w110 h20 , Sleep
Gui, Add, Edit, x132 y120 w160 h20 v__sleep, %sleep%
Gui, Add, GroupBox, x12 y160 w290 h290 , SMTP settings (For emailing)
Gui, Add, Text, x22 y180 w110 h20 , SMTP Server
Gui, Add, Edit, x132 y180 w160 h20 v__smtpserver, %smtpserver%
Gui, Add, Text, x22 y210 w110 h20 , SMTP Server Port
Gui, Add, Edit, x132 y210 w160 h20 v__smtpserverport, %smtpserverport%
if smtpusessl
	_smtpusessl := 1
else
	_smtpusessl := 0
Gui, Add, CheckBox, x22 y240 w270 h20 v__smtpusessl Checked%_smtpusessl%, SMTP use SSL
Gui, Add, Text, x22 y270 w110 h20 , Send Using
Gui, Add, Edit, x132 y270 w160 h20 v__sendusing , %sendusing%
Gui, Add, CheckBox, x22 y300 w270 h20 v__smtpauthenticate Checked%smtpauthenticate%, SMTP authenticate
Gui, Add, Text, x22 y330 w110 h20 , Username (email)
Gui, Add, Edit, x132 y330 w160 h20 v__sendusername, %sendusername%
Gui, Add, Text, x22 y360 w110 h20 , Password
Gui, Add, Edit, x132 y360 w160 h20 Password v__sendpassword, %sendpassword%
Gui, Add, Text, x22 y390 w140 h20 , STMP connection timeout
Gui, Add, Edit, x162 y390 w130 h20 v__smtpconnectiontimeout, %smtpconnectiontimeout%
Gui, Add, Text, x22 y420 w70 h20 , Schema
Gui, Add, Edit, x92 y420 w200 h20 v__schema, %schema%
Gui, Add, Button, x12 y460 w110 h30 gsaveNewSettings, Save ;when you press the save button, it calls the saveNewSettings subroutines
Gui, Add, Text, x132 y460 w170 h20 , Copyright (c) 2015 pumilamac
Gui, Show, w319 h500, %app%
return

GuiEscape:
GuiClose:
Gui, destroy
return

isclosing: ;called whenever the script is closing
try {
	;attempt releasing resources
	Gdip_Shutdown(pToken)
} catch e{
	;ignore if the script throws errors since we are exitting
}
ExitApp


/*
	VERY IMPORTANT - THE LISTENER
	++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/

listen: ;called every 30 milliseconds
SetTimer, listen, off ;we switch off the listener when we are doing long functions
win := applicationtitle ;we get the window name from the config
ctrl := applicationcontrol ;we get the control name from the config
ControlGet, ListData, List,, %ctrl%, %win% ;dump all control data to the variable ListData - On the assumption the control is a combobox, listview or dropdown list
if ListData contains %keywords% ;we check if the control contains the keywords you specified in the config
{
	;it contains the keywords so we take a screenshot
	;we create the transparent GUI showing - Restarting the application
	WinGet, ppath, ProcessPath , %win% ;get  the window application path - path to the exe
	WinGet, pid, PID , %win% ;get the process id as in the taskmanager so we can kill it
	WinGetTitle, wintit, %win% ;get the title of the window
	WinActivate, % win ;bring the window forward so we can take a screenshot
	takeScreenShotOfWindow(win,A_Desktop "\Tempscreenshot.jpg") ;this function is in the library lib.ahk
	Gui, overlay: +alwaysontop -border +toolwindow
	Gui, overlay: color, 000000
	Gui, overlay: Font, S15 CDefault, Verdana
	Gui, overlay: Add, Text, x12 y10 w380 h30 cWhite vbigtext,RESTARTING. Please wait...
	Gui, overlay: Font, S8 CDefault, Verdana
	Gui, overlay: Add, Text, x12 y50 w380 h20 cWhite vinfo, Closing %wintit%
	Gui, overlay: Show, w410 h88, s7895nhksydf
	WinSet, region, 4-4 w405 h85, s7895nhksydf
	WinSet, trans, 100,s7895nhksydf
	Gui, overlay: Default
	Process, close, %pid%
	GuiControl,,info,Sending screenshot to email ;notify the user that we are sending the screenshot to the email
	SendScreenShotTo(email, A_Desktop "\Tempscreenshot.jpg") ;send the email. This function is in libray lib.ahk
	GuiControl,,info,Re-Opening the application %wintit% ;tell the user we are restarting the window
	Run, % ppath ;run the path we got above
	Gui, overlay: destroy
	sleep, %sleep% ;wait time after it has run the above path 1000 = 1 second
}
SetTimer, listen, 30 ;resume listening
return

/*
	++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/

pause:
SetTimer, listen, off
TrayTip,%app%,We have paused listening
return

resume:
SetTimer, listen, 30
TrayTip,%app%,We have resumed listening
return

saveNewSettings: ;save new settings information from the user
Gui, submit, nohide ;we get all the data from the input fields - stored in the __variables named v__variable
;Before we save any of these configurations, we will need to check if any of these input fields is blank
;1. we trim the gui data from the variables - removes trailing spaces
__schema = %__schema%
__smtpconnectiontimeout = %__smtpconnectiontimeout%
__sendpassword = %__sendpassword%
__sendusername = %__sendusername%
__smtpauthenticate = %__smtpauthenticate%
__sendusing = %__sendusing%
__smtpusessl = %__smtpusessl%
__smtpserverport = %__smtpserverport%
__smtpserver = %__smtpserver%
__sleep = %__sleep%
__keywords = %__keywords%
__applicationcontrol = %__applicationcontrol%
__applicationtitle = %__applicationtitle%

;2. we check if any of these variables is blank
if (__schema = "" || __smtpconnectiontimeout = "" || __sendpassword = "" || __sendusername = "" || __smtpauthenticate = "" || __sendusing = "" || __smtpusessl = "" || __smtpserverport = "" || __smtpserver ="" || __sleep = "" || __keywords = "" || __applicationcontrol = "" || __applicationtitle = ""){
	MsgBox, 4144, %app%, Please make sure none of the fields is blank
	return
}

;3. we save the new data to our config.ini
IniWrite,%__schema%,%config%,smtp,schema
IniWrite,%__smtpconnectiontimeout%,%config%,smtp,smtpconnectiontimeout
IniWrite,%__sendpassword%,%config%,smtp,sendpassword
IniWrite,%__sendusername%,%config%,smtp,sendusername
IniWrite,%__smtpauthenticate%,%config%,smtp,smtpauthenticate
IniWrite,%__sendusing%,%config%,smtp,sendusing
IniWrite,%__smtpusessl%,%config%,smtp,smtpusessl
IniWrite,%__smtpserverport%,%config%,smtp,smtpserverport
IniWrite,%__smtpserver%,%config%,smtp,smtpserver
IniWrite,%__sleep%,%config%,main,sleep
IniWrite,%__keywords%,%config%,main,keywords
IniWrite,%__applicationcontrol%,%config%,main,applicationcontrol
IniWrite,%__applicationtitle%,%config%,main,applicationtitle

;4. Now that we have updated the config.ini, we need to reload so that the new resources can be loaded - We shall prompt though
MsgBox, 4096, %app%, Configurations have been saved successfully
Reload
return

;we will be using GDIP and lib library for screenshots
#include resources/GDIP.ahk
#include resources/lib.ahk