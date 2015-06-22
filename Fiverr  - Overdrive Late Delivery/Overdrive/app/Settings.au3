#SingleInstance, force
#Persistent
#NoEnv

load:
main_ini = %A_ScriptDir%\resources\Config.ini
default_backup = %A_ScriptDir%\resources\backups
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
lastbackup = %lastbackup%
if lastbackup !=
{
	FormatTime,lastbackup,%lastbackup%,dd/MM/yyyy HH:mm:ss
	lastbackup = %lastbackup% Hrs
}
else
{
	lastbackup = No backup done
}

gui:
Gui, Add, Tab2, x12 y10 w850 h510 , Users|Analytics|Backup|Restore|Custom Scripting

Gui, Tab, Users
Gui, Add, ListView, x32 y60 w810 h400 vList_users +Grid -Multi -LV0x10,Username|Name|Disk Utilization|Commands|Path
Gui, Add, Button, x32 y470 w120 h30 gadd_user, Add New User +
Gui, Add, Button, x162 y470 w120 h30 grename_selected, Rename Selected
Gui, Add, Button, x292 y470 w120 h30 gdelete_selected, Delete Selected

Gui, Tab, Analytics
Gui, Add, ListView, x32 y60 w810 h420 vList_analytics +Grid -Multi -LV0x10,Username|Command Name|Times used

Gui, Tab, Backup
Gui, Add, GroupBox, x32 y50 w810 h100 , Backup Location:
Gui, Add, Edit, x42 y80 w570 h20 ReadOnly vbackuplocation,%backuplocation%
Gui, Add, Button, x42 y110 w150 h30 gsetbackuplocation, Set Backup Location
Gui, Add, GroupBox, x32 y160 w310 h60 , Last Backup
Gui, Add, Text, x52 y180 w250 h30 vlastbackup, %lastbackup%
Gui, Add, Button, x32 y230 w190 h40 gcreatebackup,Backup Now

Gui, Tab, Restore
Gui, Add, GroupBox, x32 y50 w810 h390 , Restore Point(s):
Gui, Add, ListView, x62 y80 w750 h330 vList_restore +Grid -Multi -LV0x10,File|Restore Date/Time
Gui, Add, Button, x32 y450 w160 h30 grestorebackup, Restore

Gui, Tab, Custom Scripting
Gui, Add, Edit, x32 y60 w810 h380 vccode +WantTab,
Gui, Add, Button, x32 y450 w130 h30 gsavecode, Save
;Gui, Add, Button, x172 y450 w140 h30 , Cancel
;Gui, Add, Button, x702 y450 w140 h30 , Run

Gui, Show, w882 h530,Settings
populateItems() ;this populates all items for the settings
resizeLists() ;autofit columns
return

GuiClose:
ExitApp

add_user:
InputBox,_name,New user,Enter name,,200,140
if errorlevel
	return
_name = %_name%
if _name =
	return
newuser = %_name%
newuserMD5 := MD5(newuser)
IfExist,%A_ScriptDir%\users\%newuserMD5%
{
	MsgBox,0,Settings,A user with the same name already exists!
	return
}
FileCreateDir,%A_ScriptDir%\users\%newuserMD5%
FileAppend,%newuser%,%A_ScriptDir%\users\%newuserMD5%\user_settings.dat
populateItems() ;refresh data
Run, AHK_U.exe overdrive_app_master.au3 ;reload main
MsgBox,0,Settings,User created!
return

rename_selected:
Gui, listview,List_users
s := LV_GetNext()
LV_GetText(dir,s,5)
FileReadLine,username,%dir%\user_settings.dat,1
InputBox,_name,Rename,Enter new name for "%username%".,,200,140
if errorlevel
	return
_name = %_name%
if _name =
	return
nameMD5 := MD5(_name)
newdir =%A_ScriptDir%\users\%nameMD5%
IfExist,% newdir
{
	MsgBox,0,Settings,A user with the same name already exists!
	return
}
MsgBox,4,Settings,Are you sure you want to change the name to %_name%?
IfMsgBox,No
	return
FileMoveDir,%dir%,%newdir%,R
FileDelete,%newdir%\user_settings.dat
FileAppend,%_name%,%newdir%\user_settings.dat
populateItems() ;refresh data
Run, AHK_U.exe overdrive_app_master.au3 ;reload main
MsgBox,0,Settings,Renamed!
return

delete_selected:
Gui, listview,List_users
s := LV_GetNext()
LV_GetText(dir,s,5)
FileReadLine,username,%dir%\user_settings.dat,1
username = %username%
MsgBox,4,Settings,Are you sure you want to delete "%username%" and all their commands? This cannot be undone.
IfMsgBox,No
	return
FileRemoveDir,%dir%,1
populateItems() ;refresh data
Run, AHK_U.exe overdrive_app_master.au3 ;reload main
MsgBox,0,Settings,User removed!
return

setbackuplocation:
FileSelectFolder,newbackuplocation,%A_Desktop%,1,Select new backup folder
if errorlevel
	return
IfNotExist,% newbackuplocation
	return
newbackuplocation = %newbackuplocation%
if newbackuplocation =
	return
IniWrite,%newbackuplocation%,%main_ini%,main,backuplocation
GuiControl,,backuplocation,%newbackuplocation%
populateItems() ;refresh data
Run, AHK_U.exe overdrive_app_master.au3 ;reload main
MsgBox,0,Settings,Backup location has been changed!
return

createbackup:
Gui, submit,nohide
MsgBox,4,Settings,This will backup all user commands. Continue?
IfMsgBox,No
	return
users_loc = %A_ScriptDir%\users
timestamp := A_Now
gosub, backupanimation
backup(users_loc,timestamp)
IniWrite,%timestamp%,%main_ini%,main,lastbackup
lastbackup = %timestamp%
FormatTime,lastbackup,%lastbackup%,dd/MM/yyyy HH:mm:ss
lastbackup = %lastbackup% Hrs
GuiControl,,lastbackup,%lastbackup%
Gui, ba: destroy
populateItems() ;refresh data
Run, AHK_U.exe overdrive_app_master.au3 ;reload main
MsgBox,0,Settings,Backup complete!
return

restorebackup:
Gui, listview,List_restore
r := LV_GetNext()
if r=0
	return
LV_GetText(selected_backup,r,1)
MsgBox, 8468, Overdrive, "%selected_backup%"`n`nAre you sure you want to restore this backup? All current users and commands will be overwriten
IfMsgBox,No
	return
users_dir=%A_ScriptDir%\users
FileRemoveDir,%users_dir%
gosub, backupanimation
restore(selected_backup,users_dir)
populateItems() ;refresh data
Run, AHK_U.exe overdrive_app_master.au3 ;reload main
Gui, ba: destroy
MsgBox,0,Settings,Backup restored!
return

backupanimation:
Gui, ba: destroy
Gui, ba:+alwaysontop +toolwindow -border
Gui, ba:Add, Text, x12 y10 w160 h20 vbainfo, Backup (0 `%)
Gui, ba:Add, Progress, x12 y40 w160 h10 vbaprog Range0-100,0
Gui, ba:Show, w188 h71,Please wait
return

baGuiEscape:
Gui,ba: destroy
return

savecode:
return


populateItems(){
	global backuplocation
	users_loc = %A_ScriptDir%\users
	delete_all_lists()
	;populating the users listview
	Gui, listview,List_users
	loop,%users_loc%\*.*,2
	{
		name = %A_LoopFileName%
		dir = %A_LoopFileFullPath%
		FileReadLine,username,%dir%\user_settings.dat,1
		username = %username%
		size := size(dir)
		commands := commands(dir)
		LV_Add("",name,username,size,commands,dir)
	}
	
	;populating the analytics listview
	Gui, listview,List_analytics
	loop,%users_loc%\*.od1,,1
	{
		command = %A_LoopFileFullPath%
		SplitPath,command,,cat,,cmd
		SplitPath,cat,,userloc
		SplitPath,userloc,user
		xcmd_sub := MD5(cmd)
		IniRead,commandUsage,%cat%\Usage.ini,commands,%xcmd_sub%
		commandUsage = %commandUsage%
		if commandUsage contains Error
			commandUsage := 0
		LV_Add("",user,cmd,commandUsage)
	}
	
	;populating restore listview
	Gui, listview,List_restore
	x = %backuplocation%
	Loop, %x%\*.bak,,1
	{
		backf = %A_LoopFileFullPath%
		SplitPath,backf,,,,backTime
		backTime = %backTime%
		FormatTime,backTime,%backTime%,dd/MM/yyyy HH:mm
		LV_Add("",backf,backTime "Hrs")
	}
}

delete_all_lists(){
	Gui, listview,List_users
	LV_Delete()
	Gui, listview,List_analytics
	LV_Delete()
	Gui, listview,List_restore
	LV_Delete()
}


;some functions
size(d){
	SetFormat,float,10.4
	size := 0
	loop, %d%\*.*,,1
	{
		s := A_LoopFileSize / 1000
		s = %s%
		size += s
	}
	return size " KBs"
}

commands(d){
	n := 0
	loop, %d%\*.od1,,1
		n++
	return n
}

getCommandsUsage(command,cmd){
	return 0
}

resizeLists(){
	Gui, listview,List_users
	loop, % LV_GetCount("Col")
		LV_ModifyCol(a_index,"AutoHdr")
	Gui, listview,List_analytics
	loop, % LV_GetCount("Col")
		LV_ModifyCol(a_index,"AutoHdr")
	Gui, listview,List_restore
	loop, % LV_GetCount("Col")
		LV_ModifyCol(a_index,"AutoHdr")
}

backup(dir,timestamp){
	global backuplocation
	sZip := backuplocation . "\" timestamp ".zip"
	cdir = %dir%\
	Zip(cdir,sZip)
	FileMove,%sZip%,%backuplocation%\%timestamp%.bak,1 ;you can change the ext here,1
}

restore(bak,to){
	SplitPath,bak,,loc,,name
	temp=%loc%\%name%.zip
	FileCopy,%bak%,%temp%,1 ;rename a temp back to zip
	Unz(temp,to)
	FileDelete,%temp%
}

MD5(text){
StringLower,text,text
text := RegExReplace(text, "i)[^a-zA-Z\d]","_")
text := RegExReplace(text, "i)[^a-zA-Z_\d]")
return text
}

Zip(FilesToZip,sZip)
{
If Not FileExist(sZip)
	CreateZipFile(sZip)
psh := ComObjCreate( "Shell.Application" )
pzip := psh.Namespace( sZip )
if InStr(FileExist(FilesToZip), "D")
	FilesToZip .= SubStr(FilesToZip,0)="\" ? "*.*" : "\*.*"
xn := 0
loop,%FilesToZip%,1
	xn ++
loop,%FilesToZip%,1
{
	zipped++
	sxn := A_Index
	SetFormat,float,10.0
	per := sxn / xn * 100
	per=%per%
	Gui, ba:default
	GuiControl,,baprog,%per%
	GuiControl,,bainfo,Backup (%per% `%)
	;ToolTip Zipping %A_LoopFileName% ..
	pzip.CopyHere( A_LoopFileLongPath, 4|16 )
	Loop
	{
		done := pzip.items().count
		if done = %zipped%
			break
	}
	done := -1
}
ToolTip
}

CreateZipFile(sZip)
{
	Header1 := "PK" . Chr(5) . Chr(6)
	VarSetCapacity(Header2, 18, 0)
	file := FileOpen(sZip,"w")
	file.Write(Header1)
	file.RawWrite(Header2,18)
	file.close()
}

Unz(sZip,sUnz)
{
    fso := ComObjCreate("Scripting.FileSystemObject")
    If Not fso.FolderExists(sUnz)  ;http://www.autohotkey.com/forum/viewtopic.php?p=402574
       fso.CreateFolder(sUnz)
    psh  := ComObjCreate("Shell.Application")
    zippedItems := psh.Namespace( sZip ).items().count
    psh.Namespace( sUnz ).CopyHere( psh.Namespace( sZip ).items, 4|16 )
    Loop {
        sleep 50
        unzippedItems := psh.Namespace( sUnz ).items().count
		SetFormat,float,20.0
        perdone := unzippedItems / zippedItems * 100
		perdone=%perdone%
		Gui, ba:default
		GuiControl,,baprog,%perdone%
		GuiControl,,bainfo,Restoring (%perdone% `%)
        IfEqual,zippedItems,%unzippedItems%
            break
    }
}