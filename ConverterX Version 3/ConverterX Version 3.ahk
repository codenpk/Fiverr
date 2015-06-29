/*
	Fiver assignment from mgmarket
	I appreciated a lot. DM me @martinthuku for help
*/

;begin
#SingleInstance,force
#Persistent
#MaxMem,500 ;this is the max memory for the variables am gonna define. (MBs)

;lets define the application files
app := "ConverterX" ;I decided to call it that :) You can edit of course
app_folder := A_ScriptDir ;this is the folder containing the script and its crucial files
config := app_folder "\config.ini" ;this will hold the configurations for the working folders
pdftotext := app_folder "\pdftotext.exe" ;this will do the magic of converting the pdf to text
dump := A_Temp "\dump.txt" ;for temp storage

IfNotExist,%pdftotext%
{
	MsgBox,0,%app%,Please make sure that pdftotext remains in the same folder as the script.
	ExitApp
}

IfNotExist,%config% ;if the config file doesnt exist, we make one.
{
FileAppend, ;we add default values
(
[main]
converted=
dropbox_folder=
),%config%
TrayTip,%app%,Config file has been set up.,2
}

;lets make the trayicon menu
menu, tray, NoStandard
menu, tray, add,ConvertFile
menu, tray, add,Reload
menu, tray, add,About
menu, tray, add ; separator
menu, tray, add,Quit
menu, tray, add,Reset



;lets attempt to read the config files
IniRead,converted,%config%,main,converted
IniRead,dropbox_folder,%config%,main,dropbox_folder

test_read := converted " " dropbox_folder 
if test_read contains error ;this is in order to check if the read was successiful
{
	MsgBox,4,%app%,There was an error reading the config file. Do you want to reset it and start again?
	IfMsgBox,No
		ExitApp
	FileDelete,%config%
	Reload
}

;we now check if the working folders exist and we prepare them if not.
if converted =
	goto, define_converted_folder
IfNotExist,%converted%
	goto,define_converted_folder

if dropbox_folder =
	goto,define_dropbox_folder
IfNotExist,%dropbox_folder%
	goto,define_dropbox_folder

/*
	MAIN WORK
	From here we check for new pdf files in the dropbox folder. 
	Remember to run this application at computer startup so that we can detect new pdf files that have been added.
	Use force convert to convert pdfs manually if that didnt happen automatically.
*/

;lets index the dropbox folder to account for available pdfs so that we know when there is a change.
index_dropbox:
index_list := index_dbox()
;now we set up a timer to call our routine check to see if there is a new file every five seconds
SetTimer,check_new,off
SetTimer,check_new,5000	
return

define_converted_folder: ;called to setup the converted folder
MsgBox,4,%app%,You have not set up the "Converted" folder to store the converted CSVs. Set it up? 
IfMsgBox,No
{
	MsgBox,4,%app%,This directory is needed to store your converted CSV. The app will close now. Do you want to set it up?
	IfMsgBox,No
		ExitApp
}
FileSelectFolder,cf,%a_desktop%,1,Select a place to store converted files
if errorlevel
{
	MsgBox,0,%app%,There was a problem getting the folder. Try again later, bye.
	ExitApp
}
if cf=
{
	MsgBox,0,%app%,You did not select a valid folder. Try again later, bye.
	ExitApp
}
IniWrite,%cf%,%config%,main,converted
Reload
return

define_dropbox_folder: ;called to set up the dropbox folder
MsgBox,4,%app%,You have not set up the "Dropbox". Set it up? 
IfMsgBox,No
{
	MsgBox,4,%app%,This directory is needed to check for new PDFs. The app will close now. Do you want to set it up?
	IfMsgBox,No
		ExitApp
}
FileSelectFolder,df,%a_desktop%,1,Select a place to store converted files
if errorlevel
{
	MsgBox,0,%app%,There was a problem getting the folder. Try again later, bye.
	ExitApp
}
if df=
{
	MsgBox,0,%app%,You did not select a valid folder. Try again later, bye.
	ExitApp
}
IniWrite,%df%,%config%,main,dropbox_folder
Reload
return

check_new: ;called to check if there are new files to our index
new_index := index_dbox()
old_index := index_list
index_list := new_index
newpdfs =
loop,parse,new_index,`,
	if a_loopfield !=
		if a_loopfield not in %old_index%
			newpdfs := (newpdfs != "" ? newpdfs "," A_LoopField : A_LoopField)
if newpdfs !=
{
	TrayTip,%app%,Detected new files. Starting conversion,2
	loop,parse,newpdfs,`, ;convert new aditions
		if A_LoopField !=
			convert(A_LoopField)
}
old_index =
return

ConvertFile: ;called to convert specific PDF files
	FileSelectFile,manualfile,1,%a_desktop%,Select your PDF file for convertion,PDF file(*.pdf)
	if (errorlevel or manualfile ="")
	{
		MsgBox,0,%app%,The file was not selected. Try again
		return
	}
	convert(manualfile)
return

Quit: ;close
	MsgBox,4,%app%,Are you sure you want to close? `n`nWhen you drop files to your dropbox folder`, they will not be automatically converted.
	IfMsgBox,Yes
		ExitApp
return

About:
	MsgBox,0,About %app%,Made by MartinThuku @Fiverr
return

Reload:
Reload
return

Reset:
MsgBox,20,%app% WARNING!,Resetting will delete the your preferences on both dropbox and Converted folder. You will have to set up again.`n`nDo you really want to reset?
IfMsgBox,No
	return
FileDelete,%config%
Reload
return

	
;the functions in use
index_dbox(){
	global dropbox_folder
	index_list =
	loop,%dropbox_folder%\*.pdf,0,0
		index_list := index_list "," A_LoopFileFullPath
	return index_list
}

/*
	THIS IS THE MOST IMPORTANT FUNCTION
	it converts the "file" Make sure the pdf file has the same format as the sample you sent me.
*/

convert(file){
	global pdftotext
	global dump
	global app_folder
	global converted
	global app
	
	SplitPath,file,,,,file_name
	
	FileCopy,%file%,%A_Temp%\temp.pdf,1
	file = %A_Temp%\temp.pdf
	RunWait,%pdftotext% %file% %dump% -raw,,Hide
	wait()
	FileDelete,%file%
	file_data := prepare()
	loop,parse,file_data,%a_tab%
	{
		if a_index = 1
			order_no = %A_LoopField%
		if a_index = 2
			csv_data = %A_LoopField%
	}
	StringReplace,order_no,order_no,`n,,all
	StringReplace,order_no,order_no,`r,,all
	
	d = %converted%\(%file_name%)ORDER-%order_no%.csv
	FileDelete,%d%
	FileAppend,%csv_data%,%d%
	
	TrayTip,%app%,ORDER NO: %order_no% conversion complete!,2
}

wait(){
	global dump
	global app
	xcount := 0
	wait_end := 10
	TrayTip,%app%,Converting....
	Loop
	{
		IfExist,%dump%
			break
		sleep,500
		xcount ++
		if xcount > %wait_end%
		{
			MsgBox,4,%app%,There was a problem converting a file. `nThe script will restart and you might need to convert the files manually.`n`n Do you want to wait for 30 more seconds?
			IfMsgBox,No
				Reload
			wait_end := wait_end + 60
		}
	}
}

prepare(){
global dump
FileRead,d,%dump%
FileDelete, %dump%

StringReplace,d,d,%a_space%%a_space%,%a_space%,all
StringReplace,d,d,Walmart.com order number,mxd_order,all
StringReplace,d,d,Item,mxd_start,all
StringReplace,d,d,mail.google.com,mxd_unpause,all
StringReplace,d,d,Arrives by,mxd_skip,all
StringReplace,d,d,See our Return Policy,mxd_end,all

skip =
order_no =
start_loop = 0
title_loop := 1
pause_read = 0
mycsv=
allcsv=
loop,parse,d,`n
{
	line = %A_LoopField%
	i := A_Index
	
	if line contains mxd_end
		break
	
	if line contains mxd_order
	{
		loop,parse,line,`:
			order_no := A_LoopField
	}
	
	if line contains Recommendations
		pause_read = 1
	
	if line contains mxd_unpause
	{
		pause_read = 0
		skip := (skip = "" ? i : skip "," i)
	}
	
	if line contains mxd_skip
		skip := (skip = "" ? i : skip "," i)
	
	if start_loop = 1
		if pause_read = 0 
			if i not in %skip%
			{
				if line contains $
				{
					loop,parse,line,%a_space%
						scount := A_Index
					
					if scount > 3
					{
						break_title=
						break_limit := scount - 2
						loop,parse,line,%a_space%
						{
							if a_index < %break_limit%
								break_title := (break_title = "" ? A_LoopField : break_title " " A_LoopField)
							else
							{
								qty_break := break_limit
								price_break := break_limit + 1
								total_break := break_limit + 2
								if a_index = %qty_break%
									qty := A_LoopField
								if a_index = %price_break%
									price := A_LoopField
								if a_index = %total_break%
									total := A_LoopField
							}								
						}
						
						title = %break_title%						
					}
					else
					{
						loop,parse,line,%a_space%
						{
							if a_index = 1
								qty := A_LoopField
							if a_index = 2
								price := A_LoopField
							if a_index = 3
								total := A_LoopField
						}
					}						
				}
				else 
				{
					title := title " " line
				}
				
				if total !=
				{
					StringReplace,title,title,`n,%a_space%,all
					StringReplace,title,title,`r,%a_space%,all
					StringReplace,qty,qty,`n,%a_space%,all
					StringReplace,qty,qty,`r,%a_space%,all
					StringReplace,price,price,`n,%a_space%,all
					StringReplace,price,price,`r,%a_space%,all
					StringReplace,total,total,`n,%a_space%,all
					StringReplace,total,total,`r,%a_space%,all
					
					title = %title%
					qty = %qty%
					price = %price%
					total = %total%
					
					mycsv = "%title%",%qty%,%price%,%total%
					allcsv := (allcsv = "" ? "TITLE,QTY,PRICE,TOTAL`n" mycsv : allcsv "`n" mycsv)
					title=
					qty=
					price=
					total=
				}
			}
	
	if line contains mxd_start
		start_loop = 1	
}
StringReplace,order_no,order_no,`n,,all
StringReplace,order_no,order_no,`r,,all
order_no = %order_no%

return_data = %order_no%%A_Tab%%allcsv%
return return_data
}
