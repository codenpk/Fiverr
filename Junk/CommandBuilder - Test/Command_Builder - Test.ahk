;  SwiftWire - EMR Automation Software
;  Copyright 2015, Fluent Systems, Corp.

;preliminaries
#SingleInstance,force
#Persistent
#NoTrayIcon ;to remove the icon from the tray
#NoEnv
SetTitleMatchMode, 2

;Beta Expiration Code
;set expiration to Jan 1, 2016
ENDTIME:=20160101
FormatTime,NOW,,yyyymmdd
IF (NOW >= ENDTIME)
{
	MsgBox,,SwiftWire  (Beta)  ,% "SwiftWire (Beta) has expired."
    ExitApp
}

Menu, Tray, Icon, %A_ScriptDir%\CommandBuilder\forklift.ico ;CHANGES TRAY ICON 


;get working directory -- the folder that contains users
SplitPath,a_scriptdir,,loc
D = %loc%\users\user1 ;this is where we can change the directory according to the user
;GDC edit after moving main app script - 121414
D = %A_ScriptDir%\users\user1

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
Gui, Add, TreeView, x12 y90 w260 h500 gmyTV vmyTV AltSubmit ImageList%imgList%,

;COMMAND CONTENT
Gui, Add, Edit, x282 y90 w430 h500 WantTab vcommand Disabled,
Gui, Add, Button, x340 y600 w100 h30 disabled vsave gsave, Save
Gui, Add, Button, x+5 y600 w100 h30 disabled vcancel gcancel, Cancel
Gui, Add, Button, x+5 y600 w100 h30 disabled gwysiwyg vwysiwyg, WYSIGYG

;QUICK REFERENCE
Gui, Add, Edit, x723 y90 w290 h500 ReadOnly,%quick_reference%
Gui, Font, S10 Bold CDefault, Verdana
Gui, Add, Text, x435 y55 w230 h20 , Command Content
Gui, Add, Text, x820 y55 w140 h20 , Building Blocks
Gui, Show, w1024 h640, Command Builder - SwiftWire
loadtree(D)
TV_Modify(TV_GetNext(),"Select")
return


;Attempt at the GUI BLOCKLY Editor
wysiwyg:
wb := ComObjCreate("InternetExplorer.Application")
htmlPage := "file:\\" A_ScriptDir "\html\commandBuilder.html"
wb.navigate(htmlPage)
wb.toolbar := false
wb.width := 1000
wb.height := 500
while, wb.busy
	Sleep, 10
wb.visible := true
SetTimer, listener, 10
return

listener:
try {
	while, wb.busy
		Sleep, 10
	command := wb.document.getElementById("save").innerText
	command = %command%
	if command !=
	{
		SetTimer, listener, off
		if  command contains Save
		{
			commands := wb.document.getElementById("ahk").value
			commands = %commands%
			StringReplace,commands,commands,\r\n,`n,all
			wb.quit()
			Gui, 1: Default
			GuiControl,,command, % commands
		}
		else
		if command contains Preview
		{
			commands := wb.document.getElementById("ahk").value
			commands = %commands%
			StringReplace,command,command,\r\n,`n,all
			MsgBox, 64, Code Builder, % commands
			wb.document.getElementById("save").innerText := ""
			SetTimer, listener, 10
		}
		else
		{
			wb.quit()
			MsgBox, 64, Code Builder, Cancelled!
		}
	}
} catch e {
	SetTimer, listener, off
}
return

GuiClose:
ExitApp

REFRESHALL:
Run, Command_Builder.exe
return

save:
Gui, +OwnDialogs
Gui,submit,nohide
;added script - 
if !_validate(command)
{
	MsgBox, 8240, Command Builder, Please make sure each line starts with: send`, sleep`, or click`, and try saving again. 
	return
}
FileDelete,%item%
FileAppend,%command%,%item%
prepare_commands_dat() ;;reload commands
MsgBox,0,SwiftWire,Command Updated Successfully
Gui, -OwnDialogs

Run, %A_ScriptDir%\Booster.exe Bar.dec
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
		if not ItemID
			break
		TV_GetText(ItemText, ItemID)
		GuiControl, -Redraw, myTV
		loop,%D%\%ItemText%\*.*,,1
		{
			SplitPath,A_LoopFileFullPath,,,,fname
			TV_Add(fname,ItemID,Sort)
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
		GuiControl,Enable,wysiwyg
	}
	else
	{
		GuiControl,,command,
		GuiControl,Disable,command
		GuiControl,Disable,save
		GuiControl,Disable,cancel
		GuiControl,Disable,wysiwyg
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

Run, %A_ScriptDir%\Booster.exe Bar.dec
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

Run, %A_ScriptDir%\Booster.exe Bar.dec
return

delete_file:
Gui,+OwnDialogs
MsgBox, 52, Delete file, Are you sure you want to delete this file?
IfMsgBox,No
	return
FileRecycle,%item%.od1
TV_Delete(itemID)
TV_Modify(parentID,"Select")
GuiControl,Disable,command
GuiControl,Disable,save
GuiControl,Disable,cancel
prepare_commands_dat()
Gui, -OwnDialogs

Run, %A_ScriptDir%\Booster.exe Bar.dec
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

Run, %A_ScriptDir%\Booster.exe Bar.dec
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
SplitPath,command_file,,,,command_name
command_sub := MD5(command_name)
FileAppend,
(
`n`n%command_sub%:
IfWinExist Hyperspace
{
	WinActivate
}
Click right 62, 39 ;activate EMR with R click
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

;function to validate commands before save - modified
_validate(com){ ;we get the commands typed by the user
	;we remove the tabs and spaces before we check if each line starts with send, sleep, or click
	;StringReplace,com,com,%a_space%,,all
	StringReplace,com,com,%a_tab%,,all
	StringReplace,com,com,`,,%A_Space%,all
	comment_block := 0
	loop,parse,com,`n ;we go through the lines testing if they are send, , sleep, or click,
	{
		string = %A_LoopField%
		if string !=
		{
			stringArr := StrSplit(string,a_space,",")
			first_word := stringArr[1]
			first_word = %first_word%
			StringMid,test_comment,string,1,1
			if (comment_block == 0) AND (string == "/*")
				comment_block = 1
			if (string == "*/")
				comment_block --
			
			if (comment_block = 0) AND (string != "*/")
			{
				if test_comment != `;
				{
					if first_word not in sleep,click,send,run
					{
						MsgBox,1,Error!,Error at line %a_index% - %first_word%
						return false
					}
				}
			}
			if comment_block < 0
			{
				MsgBox,1,Error!,Error at line %a_index%
				return false
			}
		}
	}
	if comment_block = 1
	{
		MsgBox,1,Error!,Unexpected end of comment block
		return false
	}
	return true
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