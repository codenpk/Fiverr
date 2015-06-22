#SingleInstance,force
#Persistent

menu, tray, DeleteAll
menu, tray, NoDefault
menu, tray, NoStandard
menu, tray, add, Settings
menu, tray, add, Reload
menu, tray, add,
menu, tray, add, Exit


app_location := "S:\users\" A_UserName "\profile\CryptoTerm\armor.ct"
;app_location := "C:\Program Files (x86)\CryptoTerm.com\CryptoTerm 1.6\CryptoTerm\Cryptoterm.exe"
username := "LEVEL1"
pass := "SHIELDS"


config := A_MyDocuments "\AppLauncherConfig.ini" ;stores the config file
IfNotExist, % config
	goto, Settings

IniRead,hh,%config%,main,HH
IniRead,mm,%config%,main,Min
IniRead,skip,%config%,main,Skip

testRead = %hh%, %mm%, %skip%
if testRead contains ERROR
{
	FileDelete, %config%
	Reload
}

SetTimer,checkTime,100
TrayTip,AppLauncher,RightClick this for more options
return


checkTime:
SetTimer,checkTime,Off
currentHour := A_Hour
currentMin := A_Min
currentSec := A_Sec
currentDay := A_DDDD

if currentDay not in %skip%
	if currentHour = %hh%
		if currentMin = %mm%
			if currentSec = 01
				goto, startApp ;time to launch CryptoTerm is now ie. 07:00:01 

SetTimer,checkTime,100
return

Settings:
IfNotExist, % config
	gosub, default

IniRead,hh,%config%,main,HH
IniRead,mm,%config%,main,Min
IniRead,skip,%config%,main,Skip

testRead = %hh%, %mm%, %skip%
if testRead contains ERROR
{
	FileDelete, %config%
	Reload
}

Gui, destroy
Gui, +toolwindow
Gui, Add, Text, x12 y10 w80 h20 , Hour (24Hrs)
Gui, Add, Edit, x92 y10 w140 h20 number vhhx,%hh%
Gui, Add, Text, x12 y40 w80 h20 , Minute
Gui, Add, Edit, x92 y40 w140 h20 number vmmx,%mm%
Gui, Add, Text, x12 y70 w220 h20 , Skip days (Separate them somehow)
Gui, Add, Edit, x12 y90 w220 h50 vskipx,%skip%
Gui, Add, Button, x12 y150 w100 h30 gsave,Save
Gui, Show, w248 h190,AppLauncher Settings
return

GuiEscape:
GuiClose:
Gui, destroy
return

Exit:
MsgBox,4,AppLauncher,Are you sure you want to close this app?
IfMsgBox,Yes
	ExitApp
return

Reload:
Reload
return

save:
Gui, submit, nohide
IniWrite,%hhx%,%config%,main,HH
IniWrite,%mmx%,%config%,main,Min
IniWrite,%skipx%,%config%,main,Skip
MsgBox,0,Settings,Your preferences have been saved :)
Reload
return

default:
FileDelete, % config
FileAppend,
(
[main]
HH=07
Min=00
Skip=Sunday
), % config
return

startApp:
SetTitleMatchMode, 2
win = CryptoTerm
TrayTip,AppLauncher,Starting the CryptoTerm...
Run, % app_location
WinWait, %win%
WinActivate, %win%
WinWaitActive, %win%
sleep(12000) ;logical delay
WinActivate, %win%
TrayTip,AppLauncher,Sending input to CryptoTerm
ControlSend,,1 {enter},CryptoTerm ;---- Step 1 Enter 1
sleep(3000) ;logical delay
ControlSendRaw,,%username% {enter},CryptoTerm ;---- Step 2 Enter User name
ControlSend,,{enter},CryptoTerm ;---- Step 2 Enter User name
Sleep(3000) ;logical delay
ControlSendRaw,,%pass%,CryptoTerm ;---- Step 3 Enter Password
ControlSend,,{enter},CryptoTerm ;---- Step 3 Enter Password
Sleep(3000) ;logical delay
ControlSend,,{space},CryptoTerm ;---- Step 4 Spacebar is pressed, and PS4 is entered.
ControlSendRaw,,PS4,CryptoTerm ;---- Step 4 Spacebar is pressed, and PS4 is entered.
ControlSend,,{enter},CryptoTerm ;---- Step 4 Spacebar is pressed, and PS4 is entered.
TrayTip,AppLauncher,Done! Sleeping now
return

;some function to show fancy sleep
sleep(time){
	SetFormat,float,10.0
	intervals := time / 1000
	n := intervals
	n = %n%
	loop,% intervals
	{
		TrayTip,AppLauncher,Waiting for %n% seconds
		Sleep,1000
		n--
	}
}