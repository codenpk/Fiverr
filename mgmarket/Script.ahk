#SingleInstance, force
#Persistent

listeningFolder := A_ScriptDir "\listening"
output := A_ScriptDir "\FlatFileInventoryLoader.txt"

IfNotExist, % listeningFolder
	FileCreateDir, % listeningFolder

Menu, tray, nostandard
menu, tray, nodefault
Menu, tray, add, Reload
Menu, tray, add, Exit

Gui, +alwaysontop -border +ToolWindow
Gui, color, 000000
Gui, Font, S10 CDefault, Consolas
Gui, Add, Text, x12 y10 w190 h20 cLime vinfo,Drop files here
Gui, Show, w205 h39 x700 y-10,xdropfileshere
WinSet, region, 4-4 w180 h30,xdropfileshere
return

GuiDropFiles:
in1=
in2=
in3=
loop, parse, a_guievent, `n
{
	file = %A_LoopField%
	SplitPath,file,fname
	if fname = Active Listings Report.txt
		in1 := file
	if fname = Manage FBA Inventory.txt
		in2 := file
	if testReg(fname,"[\w-\s]+CustomTransaction.csv")
		in3 := file
}
if in1 !=
	if in2 !=
		if in3 !=
			goto, generateOutput ;generate output if there is all the files
MsgBox, 48, Error, You have supplied invalid files. Please ensure you have files with the following names`n`nActive Listings Report.txt`nManage FBA Inventory.txt`n*CustomTransaction.csv`n`nEnsure you drop all of them at once`n`n
return

Reload:
Reload
return

Exit:
ExitApp

generateOutput:
GuiControl,,info,Processing...
IfExist, % output
	FileDelete, % output
today := A_YYYY A_MM A_DD
_skus=

;STEP 1 ==========================
FileRead,input1, % in1
loop, parse, input1, `n
{
	row := A_LoopField
	loop, parse, row, `t
	{
		if a_index = 4
			xsku = %A_LoopField% 
		if a_index = 7
			xopendate = %A_LoopField%
	}
	
	if xopendate !=
	{
		if xopendate != open-date ;2015-03-30 12:00:28 PDT
		{
			xopendate = %xopendate%
			StringMid,xopendate_1,xopendate,1,4 ;2015
			StringMid,xopendate_2,xopendate,6,2 ;03
			StringMid,xopendate_3,xopendate,9,2 ;30
			xopendate := xopendate_1 xopendate_2 xopendate_3		
			ldays := getDays(xopendate,today)
			if ldays > 30
				_skus .= (_skus = "" ? xsku : "`n" xsku) ;get skus that open-date > 30 days from today
		}
	}
	xopendate=
	xsku=
	row=
}
input1=
;STEP 2 ==============================================
_skus2=
FileRead, input2, % in2
loop, parse, input2, `n
{
	row := A_LoopField
	loop, parse, row, `t
	{
		if a_index = 1
			xsku = %A_LoopField%
		if a_index = 12
			sqty = %A_LoopField%
	}
	sqty = %sqty%
	StringReplace,sqty,sqty,%a_space%,,all
	StringReplace,sqty,sqty,`n,,all
	StringReplace,sqty,sqty,`r,,all
	StringReplace,sqty,sqty,`t,,all
	if sqty != afn-total-quantity
	{
		if _skus contains %xsku%
			if sqty = 0
				_skus2 .= (_skus2 = "" ? xsku : "`n" xsku) ;get skus that open-date > 30days from today and afn-total-quantity = 0
	}
	xsku=
	sqty=
	row=
}
input2=
;STEP 3 =============================================================
_skus3=
FileRead, input3, % in3
loop, parse, input3, `n
{
	row := A_LoopField
	loop, parse, row, CSV
	{
		if a_index = 5
			xsku = %A_LoopField%
	}
	
	if xsku !=
	{
		if xsku != sku
			_skus3 .= (_skus3 = "" ? xsku : "`n" xsku) ;we gather all the skus in the last file .csv
	}
	xsku=
	row=
}
_skus4=
loop, parse, _skus2, `n ;go through the list that passed step 1 and 2
{
	if _skus3 not contains %a_loopfield% ;check if step3 does bit have any sku from step2 and step1
		_skus4 .= (_skus4 = "" ? A_LoopField : "`n" A_LoopField) ;get all skus that passed all tests (it has passes 1,2 and is NOT in the final file)
}
input3=
;=========================================================================

;GENERATE OUTPUT FILE
line=sku	product-id	product-id-type	price	minimum-seller-allowed-price	maximum-seller-allowed-price	item-condition	quantity	add-delete	will-ship-internationally	expedited-shipping	standard-plus	item-note	fulfillment-center-id	product-tax-code	leadtime-to-ship	merchant_shipping_group_name
loop, parse, _skus4,`n
	line .= "`n" A_LoopField A_Tab A_Tab A_Tab A_Tab A_Tab A_Tab A_Tab A_Tab "x"
IfExist, % line
	FileDelete, % line
FileAppend,%line%,%output%
MsgBox,0,Script,Output file has been created on %output%
GuiControl,,info,Drop files here
return

testReg(str,r){
	return RegExMatch(str, r)
}

getDays(small,large){
	EnvSub,large,%small%,days
	return large
}