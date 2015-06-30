#SingleInstance, force
#Persistent

exe=SocialMultiplier.exe ;this is the name of the exe
window=ahk_exe %exe% ;we use this to get the window
SetTimer, listener, 500 ;we use a listener to wait for the window to load if its not already running
return

listener:
SetTimer, listener, off
Process, exist, %exe% ;check if the app is already running
if errorlevel = 0
	isrunning := false
else
{
	isrunning := true
	SetTimer, listener, 500 ;resume listening
}

if isrunning ;if its already running, we do nothing
	return
;else we wait for the window before sending keys
WinWait, % window ;wait for window to exist
WinWaitActive, % window ;wait for window to get active
WinActivate, % window ;force activate window so it has keyboard focus
Send, {tab 2}{enter} ;send two tabs and enter when the window loads
SetTimer, listener, 500 ;resume listening - incase the app is closed again
return
