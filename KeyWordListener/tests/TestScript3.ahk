#SingleInstance, force
#Persistent
Gui, +alwaysontop
Gui, Font, S9 CDefault, Consolas
Gui, Add, Edit, x2 y0 w360 cblue h240 vout,
Gui, Show, w368 h245, Test
SetTimer, mouselistener, 30
return

GuiClose:
ExitApp

mouselistener:
MouseGetPos,x,y,win,control
WinGetTitle, title, ahk_id %win%
WinGet, ppath, ProcessPath , ahk_id %win%
ControlGet, ListData, List,, %control%, ahk_id %win%
if ListData=
	ListData = No list data on this control
txt = MouseCoordinates (%x%,%y%)`nWindow ID (%win%)`nWin Title (%title%)`nControl (%control%)`nPath (%ppath%)`n`nDATA:`n%ListData%
GuiControl,,out,% txt
return
