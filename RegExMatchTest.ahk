#SingleInstance, force
#Persistent
Gui, +alwaysontop
Gui, Font, S20 CDefault, Consolas
Gui, Add, Text, x12 y10 w440 h40 , RegExMatch
Gui, Font, S10 CDefault, Consolas
Gui, Add, GroupBox, x12 y50 w440 h130, Haystack
Gui, Add, Edit, x22 y70 w420 h100 cblue vin gregmatch wanttab -wrap,
Gui, Add, Text, x12 y190 w60 h20 , REGEX
Gui, Add, Edit, x72 y190 w380 h20 vregex gregmatch,
Gui, Add, GroupBox, x12 y210 w440 h130 , Needle
Gui, Add, Edit, x22 y230 w420 h100 ReadOnly vout cred,
Gui, Show, w469 h351,RegExMatch Test
return

GuiClose:
ExitApp

regmatch:
Gui, submit, nohide
if regex=
	return
p := RegExMatch(in, regex,needle)
if errorlevel = 0
	GuiControl,,out, % "Found at: " (p = 0 ? "No Matches" : p) "`n`nNeedle:`n" (needle=""? "No Matches" : needle)
else
	GuiControl,,out, % "There was an error`n`n" errorlevel
return