#SingleInstance, force
#Persistent

Menu, tray, nodefault
Menu, tray, nostandard
Menu, tray, add, Quit, guiclose
Gui, +alwaysontop +toolwindow -Border
Gui, color, 0579C9
Gui, Font, S15 CDefault, Verdana
Gui, Add, Text, x12 y10 w250 h30 cWhite vcol,
Gui, Font, S8 CDefault, Verdana
Gui, Add, Text, x12 y40 w250 h20 cWhite, Press Ctrl + Right click to copy color
Gui, Show, w275 h71 x1000 y-10,Watch Mouse - 02348923489234
WinSet, region, 4-8 w250 h60, Watch Mouse - 02348923489234
SetTimer, watchMouse, 10
return

GuiClose:
ExitApp

watchMouse:
MouseGetPos, x, y
PixelGetColor, col, %x%, %y%, RGB
Gui, font, c%col% S15, Verdana
StringReplace,col,col, 0x, #, all
GuiControl, font, col
GuiControl,,col, % col
return

^RButton::
MouseGetPos, x, y
PixelGetColor, col, %x%, %y%, RGB
StringReplace,col,col, 0x, #, all
Clipboard := col
TrayTip, %col%, Copied to clipboard
return