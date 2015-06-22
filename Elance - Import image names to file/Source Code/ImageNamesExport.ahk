#SingleInstance,force
#Persistent
#NoTrayIcon
#NoEnv

Gui, Font, S12 CDefault, Verdana
Gui, Add, Text, x12 y10 w300 h20 , Export image names
Gui, Font, S8 CDefault, Verdana
Gui, Add, GroupBox, x12 y40 w300 h90 , Select Images folder
Gui, Add, Edit, x22 y60 w280 h20 ReadOnly vfolder,
Gui, Add, Button, x202 y90 w100 h30 gselectFolder, Select Folder
Gui, Add, GroupBox, x12 y140 w300 h60 , Name of output file
Gui, Add, Edit, x22 y160 w180 h20 voutput,
Gui, Add, DropDownList, x212 y160 w90 h100 vformat choose1, *.txt|*.csv
Gui, Add, Button, x12 y210 w100 h30 gexport Default, Export Names
Gui, Add, Button, x122 y210 w100 h30 gClose, Close
Gui, Show, w328 h253, Image Names Export
return

Close:
GuiEscape:
GuiClose:
ExitApp

selectFolder:
FileSelectFolder,fol,%a_desktop%,1,Select folder containing the images
if errorlevel
	return
if fol=
	return
GuiControl,,folder,% fol
return

export:
Gui, submit, nohide
if folder=
{
	MsgBox, 8240, Error, Please select the folder containing images
	return
}
output = %output%
if output contains `\,`/,`*,`?,`",`>,`<,`|
{
	MsgBox, 8240, Error, Sorry invalid output name
	return
}

if output =
{
	MsgBox, 8240, Error, Sorry invalid output name
	return
}

FileSelectFolder,exportFolder,%a_desktop%,1,Select folder to put the output file
if errorlevel
	return
if exportFolder =
	return
StringReplace,format,format,*.,,all
outputFile = %exportFolder%\%output%.%format%
FileDelete, % outputFile
enames=
subs=
loop,%folder%\*.*,0,1
{
	file = %A_LoopFileFullPath%
	SplitPath,file,fname,dir,ext,sname
	if ext contains jpg,png,ico,gif
	{
		if isSubfolder(dir)
		{
			StringReplace,sub,dir,%folder%,,all
			sub = Subfolder: %sub%
			if !used(sub)
				enames := (enames=""?sub:enames "`n`n" sub)
			subs .= (subs = ""?sub:"," sub)
		}
		
		fname = %fname%
		enames := (enames=""?fname:enames "`n" fname)
	}
}
FileAppend,%enames%,%outputFile%
MsgBox, 8260, Done!, Export complete. Do you want to open the output file?
IfMsgBox,Yes
	Run, % outputFile
return

isSubfolder(d){
	global folder
	StringReplace,d,d,%folder%,,all
	d = %d%
	if d =
		return false
	return true
}

used(s){
global subs
loop,parse,subs,`,
	if a_loopfield = %s%
		return true
return false
}
