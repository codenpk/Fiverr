#SingleInstance,force
#Persistent

Gui, Add, GroupBox, x2 y0 w320 h90, ;the round box for grouping
Gui, Add, Text, x12 y20 w110 h20 , Select Month ;text
;this is our dropdown it chooses A_MM by default which is the current month in two digits ie. 03 for MARCH
;AltSubmit allows us to get the position of the selected item on the dropdown during guicontrolget
Gui, Add, DropDownList, x132 y20 w180 h260 Choose%A_MM% AltSubmit vMonthList,January|February|March|April|May|June|July|August|September|October|November|December
Gui, Add, Button, x12 y50 w100 h30 g_run,Run ;this button on press calls _run subroutine
Gui, Show, w328 h99, Run ;the window shown
return

GuiEscape: ;closes the window on ESC button press
GuiClose:
ExitApp

_run: ;called by the button
GuiControlGet,monthNN,,MonthList ;get the selected month in digit (1-12)
monthNN := (monthNN < 10 ? "0" monthNN : monthNN) ;adds 0 to the digits less than 10 so 2 becomes 02.
firstDate := monthNN "-01-" A_YYYY ;we use the current year right? get the first date of selected month
lastDate := monthNN "-" month_days(monthNN) "-" A_YYYY ;get last date of selected month
WinClose,Untitled - Notepad ;am thinking we should close all Untitled - Notepad windows before we open a new one
Run, Notepad.exe ;we open Notepad
WinWait,Untitled - Notepad ;we wait till Untitled - Notepad window opens, doesnt have to be active
ControlSend,Edit1,%firstDate%`n%lastDate%,Untitled - Notepad ;we send the first date, return, last date
return

/*
	month_days by Martinthuku
	returns number of days in a month
*/

month_days(m = "",Year = ""){
	if m =
		m := A_MM
	if Year =
		Year := A_Year
	30s=04,06,09,11
	31s=01,03,05,07,08,10,12
	if 30s contains %m%
		return 30
	if 31s contains %m%
		return 31
	else
		return (!Mod(Year, 100) && !Mod(Year, 400) && !Mod(Year, 4)?29:28)
}