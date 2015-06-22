;  Overdrive - EMR Automation Software
;  Copyright 2014, Fluent Technology, LLC

#SingleInstance,force
#Persistent

;prepare global settings
load:
main_ini = %A_ScriptDir%\resources\Config.ini
IfNotExist, % main_ini
{
FileAppend,
(
[main]
backuplocation=%default_backup%
lastbackup=
lastusername=
), % main_ini
}

main:
IniRead,backuplocation,%main_ini%,main,backuplocation
IniRead,lastbackup,%main_ini%,main,lastbackup
IniRead,lastusername,%main_ini%,main,lastusername
test = %lastbackup% %backuplocation% %lastusername%
if test contains Error
{
	FileDelete,% main_ini
	goto, load
}

app = Overdrive
current_user := lastusername
current_user_files = %A_ScriptDir%\users\%current_user%
current_user_settings = %current_user_files%\user_settings.dat

IfNotExist,%current_user_settings%
{
    MsgBox,0,%app%,Could not find user settings!`n`nMake sure you have the "user_settings.dat" in the user's folder.
    ExitApp
}
FileReadLine,username,%current_user_settings%,1
username = %username% ;trim
if username =
{
    MsgBox,0,%app%,Could not find user's name in the "user_settings.dat". Make sure it is in the first line.
    ExitApp
}

SendMode Input
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2
SetDefaultMouseSpeed, 0
CoordMode, Mouse, Relative

;create "user" menu
Gosub,USERMENU

;create the tray menu
Menu,TRAY,NoStandard
Menu,TRAY,Add,Reload OVERDRIVE,RELOAD
Menu, Tray, Add
Menu,Tray,Add,Command Builder,COMMANDBUILDER 
Menu, TRAY, Add
Menu,TRAY,Add,E&xit,EXIT
Menu,Tray,Tip,Overdrive




;draw interface
Menu, Tray, Icon, %A_ScriptDir%\resources\images\overdrive_icons.ico
SysGet, work_area_1, MonitorWorkArea, 1
tool_bar_width := work_area_1Right
tool_bar_height = 19
min_close_position := tool_bar_width - 128

Gui +AlwaysOnTop -Caption -DPIScale
Gui, Color, 18282f
Gui, Margin, X0, Y0
Gui, Font, s9, Arial
Gui, Font, cacabab bold ;italic
Gui, Add,text,x8 y1 -gUSERMENU_SHOW,%username%					
Gui, Font, cd3d3d3 norm

;LOAD THE COMMANDS AND PREPARE THE COMMANDS.DAT FILE
Gui, Font, s8 bold, Aria
loop,%current_user_files%\*.*,2
{
    _category = %A_LoopFileFullPath%
    SplitPath,_category,cat
    _category_sub := MD5("Cat" cat)
    Gui, Add, Text, x+20 y2 g%_category_sub%,%cat%
    n := 0
    loop,%_category%\*.od1,,1
        n:=A_Index
    if n=0
        Menu,%_category_sub%,Add,No commands yet,MenuHandler
    loop,%_category%\*.od1,,1
    {
        command_file := A_LoopFileFullPath
        SplitPath,command_file,,command_dir,,command_name
        command_sub := MD5(command_name)
        Menu,%_category_sub%,Add,%command_name%,%command_sub%
    }
}

;add right bar content
Gui, Add, Picture, x%min_close_position% y0 -gINACTIVATE , %A_ScriptDir%\resources\images\od_logo_mini_1b.bmp
Gui, Add, Picture, x+20 y0 -gINACTIVATE , %A_ScriptDir%\resources\images\min_up_2.png
Gui, Add, Picture, x+5 -gCloseOverdrive , %A_ScriptDir%\resources\images\x_up_2.png

;display the UI
Gui, Show, x0 y0 w%tool_bar_width% h%tool_bar_height%, Overdrive
return

;INCLUDE THE COMMANDS FILE
#Include %A_ScriptDir%\active_commands\commands.dat

;BUTTONS HANDLERS
MinimizeOverdrive:
WinMinimize, %app%
return

;CLOSE BUTTION FUNCTIONALITY
CloseOverdrive:
ExitApp
return

RELOAD:
Run AHK_U.exe overdrive_app_master.au3
return

COMMANDBUILDER:
Run AHK_U.exe Command_Builder.au3
return

EXIT:
ExitApp
return

CHECKID:
msgbox, %UniqueID%
return


MOUSE_POSITION:
Run, Coordinates.exe
return


INACTIVATE:
Run AHK_U.exe Inactive.au3
ExitApp
return

;create "user" menu
USERMENU:
users_folder=%A_ScriptDir%\users
Loop,%users_folder%\*.*,2
    Menu, user, Add, %A_LoopFileName%, __SelectUser
menu,USERMENU,add,Switch User,:user
menu,USERMENU,add
menu,USERMENU,add,Build Commands ...,COMMANDBUILDER
menu,USERMENU,add,Find Mouse Coordinates,MOUSE_POSITION
menu,USERMENU,add

menu,USERMENU,add,Overdrive Settings,__Settings
menu,USERMENU,add,Help,HELP
return

__SelectUser:
selected_user := A_ThisMenuItem
IniWrite,%selected_user%,%main_ini%,main,lastusername
winclose, Command Builder - Overdrive
goto, RELOAD

__Settings:
Run AHK_U.exe Settings.au3
return

;load help file in IE
HELP:
Run, iexplore.exe file:///%__CD__%help\help.htm
return

;show "user" menu
USERMENU_SHOW:
menu,USERMENU,show,0,19
return

;Postpone BONUS command!
#p::
MouseClick, right
Send {up}{enter}
Send !p	
return

;include custom command scripts
#Include %a_scriptdir%\users\user1\custom_commands.dat

MenuHandler:
return


/*
	**********************************************************************************************************************************
	this is the MD5 generator by jNizM
	I will use this to give the categories unique sub names
	Please do not tamper with the code below.
	**********************************************************************************************************************************
*/
MD5(text){
StringLower,text,text
text := RegExReplace(text, "i)[^a-zA-Z\d]","_")
text := RegExReplace(text, "i)[^a-zA-Z_\d]")
return text
}