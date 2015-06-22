#SingleInstance,force
#Persistent
menu, tray, DeleteAll
menu, tray, NoDefault
menu, tray, NoStandard
menu, tray, add, Settings
menu, tray, add, Reload
menu, tray, add,
menu, tray, add, Exit

main_ini = %A_ScriptDir%\RepricerConfig.ini
IfNotExist, % main_ini
{
FileAppend,
(
[main]
watchdir=%A_Desktop%
), %main_ini%
}
IniRead,watchdir,%main_ini%,main,watchdir
if watchdir = error
{
	FileDelete, %main_ini%
	Reload
	return
}
gosub,startwatch
settings:
Gui, destroy
Gui, Add, Text, x12 y10 w130 h20 , Watching this folder:
Gui, Add, Edit, x142 y10 w220 h20 vwatchdirx ReadOnly,%watchdir%
Gui, Add, Button, x142 y40 w100 h30 gchange, Change
Gui, Show, w372 h82,Repricer
return

Reload:
Reload
return

Exit:
MsgBox,4,Repricer,Close... Are you sure?
IfMsgBox,No
	return
ExitApp
return

change:
FileSelectFolder,watchdirx,%a_desktop%,1,Select folder to watch
if errorlevel
	return
watchdirx = %watchdirx%
if watchdirx =
	return
IniWrite,%watchdirx%,%main_ini%,main,watchdir
GuiControl,,watchdirx,%watchdirx%
TrayTip,Repricer,Watch folder changed
watchdir = %watchdirx%
gosub, startwatch
return

GuiEscape:
GuiClose:
Gui, destroy
TrayTip,Repricer,Right click here to close or open
return


startwatch:
SetTimer,watch,off
current_files=
loop,%watchdir%\*.csv,,1
	current_files .= (current_files=""?A_LoopFileFullPath:"," A_LoopFileFullPath)
SetTimer,watch,100
return

Watch:
SetTimer,watch,off
loop,%watchdir%\*.csv,,1
{
	file = %A_LoopFileFullPath%
	if file not in %current_files%
		gosub, do
}
SetTimer,watch,100
return

do:
new_file := file
file=
FileReadLine,first_line,%new_file%,1
if first_line contains MSKU,Title,FNSKU,ASIN
	gosub, generate_outputs
current_files .= (current_files=""?new_file:"," new_file)
return

generate_outputs:
FileRead,csv,%new_file%
loop,parse,csv,`n
{
	lineDetails := A_LoopField
	if a_index = 2
	{
		loop,parse,lineDetails,CSV
		{
			if a_index = 1
				sku = %A_LoopField%
			if a_index = 6
				cost = %A_LoopField%
			if a_index = 5
				price = %A_LoopField%
		}
		gosub, create_files
	}
}
return

create_files:
output1 = %watchdir%\output file 1.amazon.txt
output2 = %watchdir%\output file 2.bQool.tsv
FileDelete,% output1
FileDelete,% output2
FileAppend,
(
sku	price	minimum-seller-allowed-price	maximum-seller-allowed-price	quantity	leadtime-to-ship	fulfillment-channel
%sku%		%cost%				
						
						
						
notes: do not include in output file						
						
MSKU field from input file		Purchased Price field from input file
),%output1%
FileAppend,
(
"FileType = repricing,  Version = 1.2.0 (Please do not edit this line or this will result in error when uploading)"						
Channel	SellerSKU	Cost	Rule Name	Min Price	Max Price	add-delete
Amazon US	%sku%	%cost%	Get Buy Box	%price%	155.98	a
						
						
notes: do not include in outfiles						
						
Always occupy with 'Amazon US'	MSKU Field from Input File	Purchased Price Field from Input File	Always occupy with 'Get Buy Box'	Purchase Price Field from Input File	Multiply Price Field from input file x 2.0	Always occupy with 'a'
),%output2%
TrayTip,Repricer,Files created!!
return