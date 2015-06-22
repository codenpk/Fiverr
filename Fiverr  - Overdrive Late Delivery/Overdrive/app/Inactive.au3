;  Overdrive - EMR Automation Software
;  Copyright 2014, Fluent Technology, LLC


#SingleInstance, force

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode, 2 ;WinTitle anywhere in title
SetDefaultMouseSpeed, 0
CoordMode, Mouse, Relative ; set mouse clicks to relative

;create the tray menu
Menu,TRAY,NoStandard
Menu,TRAY,Add,Reload OVERDRIVE,RELOAD
Menu, Tray, Add
Menu,Tray,Add,Command Builder,COMMANDBUILDER 
Menu, TRAY, Add
Menu,TRAY,Add,E&xit,EXIT
Menu,Tray,Tip,Overdrive

Gosub,TRAYMENU ;CUSTOMIZE TRAY MENU


Menu, Tray, Icon, %A_ScriptDir%\resources\images\overdrive_icons.ico ;CHANGES TRAY ICON 

SysGet, work_area_1, MonitorWorkArea, 1 ;gets data excluding registered toolbars
tool_bar_width := work_area_1Right ;define tool bar width
tool_bar_height = 18 ;19 if pinstripe
;min_close_position := tool_bar_width - 128 ;define placement of "active" (was shifter_mini)
inactive_x_location := tool_bar_width - 195

Gui +AlwaysOnTop ; TESTING ALWAYS ON TOP 101914
Gui, Color, 18282f ; SET GUI TO "OVERDRIVE GREEN"
Gui, -Caption ; HIDE DEFAULT WINDOWS BORDER AND BUTTONS
Gui, Margin, X0, Y0 
Gui, font, s8, Arial ; Preferred font
Gui -DPIScale ;disable 1.25x DPI scaling - needed in AHK_L (not basic)


gui, font, cd3d3d3 norm
gui, add, text,x16 -gINACTIVATE, Inactive
					

;####################




Gui, Show, x%inactive_x_location% y0 w71 h%tool_bar_height%, Overdrive




Return
;END OF GUI DISPLAY CODE
;#######################

;#######################
;START OF COMMAND CODE


;TRAY MENU CUSTOMIZATION GUIDE
TRAYMENU:
Menu,TRAY,NoStandard 
Menu,TRAY,DeleteAll 
Menu,TRAY,Add,Reload OVERDRIVE, RELOAD ; DISABLED 101914
menu,tray,add
Menu,TRAY,Add,Command Builder, COMMANDBUILDER
;Menu,TRAY,Add,Mouse Locator, MOUSE_POSITION
Menu, TRAY, Add
Menu,TRAY,Add,E&xit,EXIT
Menu,Tray,Tip,Overdrive
Return

RELOAD:

Run AHK_U.exe overdrive_app_master.au3

return

COMMANDBUILDER:
Run AHK_U.exe %A_ScriptDir%\CommandBuilder\Command_Builder.ahk
return




INACTIVATE:
Winactivate, Hyperspace
Run AHK_U.exe overdrive_app_master.au3
ExitApp
return

EXIT:
ExitAPP
return

;;;;;;;;;; TESTING AREA ;;;;;;;;;;

#+1::
IfWinExist Hyperspace
{
	WinActivate
}
Click right 46, 38 ;activate EMR with R click
Send, {CTRLDOWN}{SHIFTDOWN}n{SHIFTUP}{CTRLUP}
Sleep, 3000
Send, {CTRLDOWN}o{CTRLUP}
Sleep, 1800
Send, {ALTDOWN}v{ALTUP}99214
Sleep, 100
Send, {CTRLDOWN}{SHIFTDOWN}n{SHIFTUP}{CTRLUP}
Sleep, 1200
Send, .gcest{ENTER}
Send, {F2}{F2}{BACKSPACE}
return

F12::
send ^c
sleep, 20
winactivate, DragonBar
sleep, 20
send !w
sleep, 20
send n
sleep, 500
send ^v
return

#p::
MouseClick, right
Send {up}{enter}
Send !p	
return

;include custom command scripts
#Include users\user1\custom_commands.dat

;;;;;;;;; TESTING AREA ;;;;;;;;;;

GuiClose: