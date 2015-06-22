;  Overdrive - EMR Automation Software
;  Copyright 2014, Fluent Technology, LLC

;preliminaries
#SingleInstance,force
#Persistent
#NoTrayIcon ;to remove the icon from the tray
#NoEnv

Menu, Tray, Icon, %A_ScriptDir%\CommandBuilder\forklift.ico ;CHANGES TRAY ICON 

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

D = %A_ScriptDir%\users\%lastusername% ;this is where we can change the directory according to the user
;GDC edit after moving main app script - 121414

;FileReadLine,user_names,%D%\user_settings.dat,1 ;get the user names from the "user_settings.dat" should be on the first line at all times.
FileReadLine,user_names,%D%\user_settings.dat,1 ;get the user names from the "user_settings.dat" should be on the first line at all times.

/*
	Our working directory is now called "D"
	you havent cleared about this user thing but I will enquire and make a revision about this so the working folder is hardcoded to TestUser
	I have also joined the Test User to TestUser because of the fileread exception on the space.
*/

FileRead,quick_reference,%A_ScriptDir%\CommandBuilder\quickreference.txt ;I have put the quick reference on the quickreference.txt You can comment this and uncoment the line below to hardcode it.
;quick_reference=""

;make the context menu
Menu, rmenu, Add, Rename, rename
Menu, rmenu, Add, Delete, delete

;make the user interface.

Gui, Add, Picture, x0 y0 -gREFRESHALL,%A_ScriptDir%\CommandBuilder\CommandBuilderLogo2.bmp

;Gui, Add, Text, x-8 y0 w900 h40 CBlack 0x7, ;this is a line
;Gui, Font, S15 CDefault, Verdana
;Gui, Add, Text, x32 y10 w330 h25 , Command Builder ;big text


Gui, Font, S8 CDefault, Verdana
Gui, Add, Button, x12 y50 w130 h30 gnew_command, Add New Command
Gui, Add, Button, x142 y50 w130 h30 gnew_category, Add New Category
imgList := IL_Create(10)
Loop 10
    IL_Add(imgList, "shell32.dll", A_Index)
IL_Add(imgList, "shell32.dll", A_Index)
Gui, Add, TreeView, x12 y90 w260 h390 gmyTV vmyTV AltSubmit ImageList%imgList%,
Gui, Add, Edit, x282 y90 w340 h390 WantTab vcommand Disabled,
Gui, Add, Button, x342 y490 w100 h30 disabled vsave gsave, Save
Gui, Add, Button, x452 y490 w100 h30 disabled vcancel gcancel, Cancel
Gui, Add, Edit, x633 y90 w245 h390 ReadOnly,%quick_reference%
Gui, Font, S10 Bold CDefault, Verdana
Gui, Add, Text, x386 y55 w230 h20 , Command Content
Gui, Add, Text, x700 y55 w140 h20 , Quick Reference
Gui, Show, w888 h536, Command Builder - Overdrive
loadtree(D)
TV_Modify(TV_GetNext(),"Select")
return

GuiClose:
ExitApp

REFRESHALL:
Run, AHK_U.exe Command_Builder.au3
return

save:
Gui, +OwnDialogs
Gui,submit,nohide
FileDelete,%item%
FileAppend,%command%,%item%
prepare_commands_dat() ;;reload commands
MsgBox,0,Overdrive,Command Updated Successfully
Gui, -OwnDialogs

Run, AHK_U.exe overdrive_app_master.au3
return

cancel:
TV_Modify(parentID,"Select")
return

new_category:
Gui, +OwnDialogs
InputBox,category,New category,Type the new category name,,200,125
if errorlevel
	return
if category=
{
	MsgBox,0,New category,Sorry you have typed an invalid category name
	return
}
if category contains `\,`/,`:,`*,`?,`",`<,`>,`|
{
	MsgBox,0,New category,Sorry you have typed an invalid category name
	return
}
cat = %D%\%category%
IfExist,%cat%
{
	MsgBox,0,New category,Sorry the category already exists.
	return
}
FileCreateDir,%cat%
FileAppend,
(
[commands]
),%cat%\Usage.ini
TV_Add(category,0,"Icon4")
TV_Modify(0,"Sort")
prepare_commands_dat()
return

new_command:
Gui, +OwnDialogs
itemID := TV_GetSelection()
parentID := TV_GetParent(itemID)
TV_GetText(item,itemID)
TV_GetText(itemParent,parentID)
InputBox,command,New command,Type the new command name,,200,125
if errorlevel
	return
if command=
{
	MsgBox,0,New command,Sorry you have typed an invalid command name
	return
}
if command contains `\,`/,`:,`*,`?,`",`<,`>,`|
{
	MsgBox,0,New command,Sorry you have typed an invalid command name
	return
}
if parentID=0
	com=%D%\%item%\%command%.od1
else
	com=%D%\%itemParent%\%command%.od1
IfExist,%com%
{
	MsgBox,0,New command,Sorry a file with the same command name exists!
	return
}
FileAppend,,%com%
prepare_commands_dat() ;;reload commands
if parentID=0
{
	TV_Add(command,itemID)
	TV_Modify(itemID,"Expand")
	TV_Modify(itemID,"Sort")
}
else
{
	TV_Add(command,parentID)
	TV_Modify(parentID,"Expand")
	TV_Modify(parentID,"Sort")
}
return

addFols(D, paID = 0)
{
    Loop %D%\*.*,2
        addFols(A_LoopFileFullPath, TV_Add(A_LoopFileName, paID, "Icon4" Sort))
}

loadtree(D){
	TV_Delete()
	addFols(D, paID = 0)
	Loop
	{
		ItemID := TV_GetNext(ItemID, "Full")
		ItemPID := TV_GetParent(ItemID)
		if not ItemID
			break
		TV_GetText(ItemText, ItemID)
		GuiControl, -Redraw, myTV
		if ItemPID = 0
		{
			loop,%D%\%ItemText%\*.od1,,1
			{
				SplitPath,A_LoopFileFullPath,,,,fname
				TV_Add(fname,ItemID,Sort)
			}
		}
		GuiControl, +Redraw, myTV
	}
}

myTV:
if a_guievent = RightClick
{
	TV_Modify(a_eventinfo,"Select")
	Menu,rmenu, Show
}
if a_guievent = S
{
	TV_Modify(a_eventinfo,"Select")
	itemID := TV_GetSelection()
	parentID := TV_GetParent(itemID)
	TV_GetText(item,itemID)
	TV_GetText(itemParent,parentID)
	if parentID != 0
		item = %D%\%itemParent%\%item%.od1
	else
		item= %D%\%item%.od1
	if parentID != 0
	{
		FileRead,commands,%item%
		GuiControl,,command,%commands%
		GuiControl,Enable,command
		GuiControl,Enable,save
		GuiControl,Enable,cancel
	}
	else
	{
		GuiControl,,command,
		GuiControl,Disable,command
		GuiControl,Disable,save
		GuiControl,Disable,cancel
	}
}
return


rename:
itemID := TV_GetSelection()
parentID := TV_GetParent(itemID)
TV_GetText(item,itemID)
TV_GetText(itemParent,parentID)
if parentID != 0
{
	item = %D%\%itemParent%\%item%
	goto,rename_file
}
item= %D%\%item%
goto,rename_folder
return

delete:
itemID := TV_GetSelection()
parentID := TV_GetParent(itemID)
TV_GetText(item,itemID)
TV_GetText(itemParent,parentID)
if parentID != 0
{
	item = %D%\%itemParent%\%item%
	goto,delete_file
}
item= %D%\%item%
goto,delete_folder
return

rename_file:
Gui, +OwnDialogs
InputBox,newname,Rename File,Type the new name,,200,125
if errorlevel
	return
if newname=
{
	MsgBox,0,Rename Failed,Sorry you have typed an invalid file name
	return
}
if newname contains `\,`/,`:,`*,`?,`",`<,`>,`|
{
	MsgBox,0,Rename Failed,Sorry you have typed an invalid file name
	return
}
item = %item%.od1
SplitPath,item,,location
newfile=%location%\%newname%.od1
IfExist,%newfile%
{
	MsgBox,0,Rename Failed,Sorry a file exists with the same name.
	return
}
MsgBox,4,Rename file,Are you sure you want to rename this file?
IfMsgBox,no
	return
TV_Modify(itemID,,newname)
FileMove,%item%,%newfile%,1
if errorlevel > 0
{
	MsgBox,0,Rename Failed,There was an error renaming the file.
	return
}
prepare_commands_dat()
Gui, -OwnDialogs

Run, AHK_U.exe overdrive_app_master.au3
return

rename_folder:
Gui, +OwnDialogs
InputBox,newname,Rename Folder,Type the new name,,200,125
if errorlevel
	return
if newname=
{
	MsgBox,0,Rename Failed,Sorry you have typed an invalid folder name
	return
}
if newname contains `\,`/,`:,`*,`?,`",`<,`>,`|
{
	MsgBox,0,Rename Failed,Sorry you have typed an invalid folder name
	return
}
SplitPath,item,,location
newfolder=%location%\%newname%
IfExist,%newfolder%
{
	MsgBox,0,Rename Failed,Sorry a folder exists with the same name.
	return
}
MsgBox,4,Rename folder,Are you sure you want to rename this folder?
IfMsgBox,no
	return
TV_Modify(itemID,,newname)
FileMoveDir,%item%,%newfolder%,R
if errorlevel > 0
{
	MsgBox,0,Rename Failed,There was an error renaming the folder.
	return
}
prepare_commands_dat()
Gui, -OwnDialogs

Run, AHK_U.exe overdrive_app_master.au3
return

delete_file:
Gui,+OwnDialogs
MsgBox, 52, Delete file, Are you sure you want to delete this file?
IfMsgBox,No
	return
SplitPath,item,xcmdx,xdirx
command_subx := MD5(xcmdx)
IniDelete,%xdirx%\Usage.ini,commands,%command_subx%
FileRecycle,%item%.od1
TV_Delete(itemID)
TV_Modify(parentID,"Select")
GuiControl,Disable,command
GuiControl,Disable,save
GuiControl,Disable,cancel
prepare_commands_dat()
Gui, -OwnDialogs

Run, AHK_U.exe overdrive_app_master.au3
return

delete_folder:
Gui,+OwnDialogs
MsgBox, 52, Delete folder, Are you sure you want to delete this folder and all its files?
IfMsgBox,No
	return
FileRecycle,%item%
prepare_commands_dat()
TV_Delete(itemID)
Gui, -OwnDialogs

Run, AHK_U.exe overdrive_app_master.au3
return


/*
	created the function below to prepare the commands.dat file everytime the command is saved
*/
prepare_commands_dat(){
global D
SplitPath,D,,dlocation ;users
SplitPath,dlocation,,app ;app
FileDelete,%app%\active_commands\commands.dat
loop,%D%\*.od1,,1
{
command_file := A_LoopFileFullPath
FileRead,command_file_contents,%command_file%
SplitPath,command_file,,xdir,,command_name
command_sub := MD5(command_name)
FileAppend,
(
`n`n%command_sub%:
IfWinExist Hyperspace
{
	WinActivate
}
Click right 62, 39 ;activate EMR with R click
IniRead,n,%xdir%\Usage.ini,commands,%command_sub%
n=`%n`%
n++
IniWrite,`%n`%,%xdir%\Usage.ini,commands,%command_sub%
;##### COMMAND GOES HERE #####

%command_file_contents%

;#############################
;DO NOT DELETE BELOW THIS LINE
return
),%app%\active_commands\commands.dat
}

loop,%D%\*.*,2
{
_category = %A_LoopFileFullPath%
SplitPath,_category,_category
_category_sub := MD5("Cat" _category)
FileAppend,
(
`n`n%_category_sub%:
MouseGetPos,mx,my,mw,mcontrol
ControlGetPos, X, Y, Width, Height,`%mcontrol`%,A
Y := Y + 17
Menu,%_category_sub%,show, `%X`%,`%Y`%
return
),%app%\active_commands\commands.dat
}
}

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