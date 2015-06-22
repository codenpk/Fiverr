#SingleInstance,force
#Persistent
#MaxThreadsPerHotkey, 1

doStitch := false
myClip =
app = StitchClip

Menu, tray, nodefault
Menu, tray, nostandard
Menu, tray, add, Start`tCtrl+Shift+S, start
Menu, tray, add, Stop `tCtrl+Shift+H, stop
Menu, tray, add
Menu, tray, add, Restart
Menu, tray, add, Quit
TrayTip,%app%, Welcome!
return

;stitch up text only (not files or other data)
OnClipboardChange: ;fired on clipboard change
if a_eventinfo = 1
{
	if doStitch = 1
	{
		newData := Clipboard
		Clipboard =
		myClip .= (myClip = "" ? newData : "`n" newData)
		Clipboard := myClip
		TrayTip,%app%, Clipboard has been changed!
	}
}
return

^+s::
start:
doStitch := true
TrayTip,%app%, Stitching clipboard text has been started
return

^+h::
stop:
doStitch := false
Clipboard =
myClip =
sleep, 100
TrayTip,%app%, Stitching clipboard text has been stopped!
return

restart:
Reload
return

quit:
ExitApp