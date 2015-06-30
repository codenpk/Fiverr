#SingleInstance, force
#Persistent
SetFormat, float, 20.2

n := %0%
MsgBox % n

Gui, destroy
Gui, +alwaysontop -border +toolwindow
Gui, color, 000000
Gui, Font, S10 CDefault, Consolas
Gui, Add, Text, x12 y10 w160 h20 cLime vinfo, Processing file
Gui, Add, Progress, x12 y40 w160 h5 vp1 cRed Background888888,
Gui, Add, Progress, x12 y60 w160 h10 vp2 cLime Background888888,
Gui, Show, w189 h88,Crypt0154
return

F7::
GuiClose:
GuiEscape:
ExitApp

GuiDropFiles:
n := A_EventInfo
loop, parse, a_guievent, `n
{
	f := A_LoopField
	p := a_index / n * 100
	p = %p%
	GuiControl,,p1,% p
	
	
return

