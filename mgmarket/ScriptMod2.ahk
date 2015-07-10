/*
Created By Martinthuku
Copyright (c) mgmarket

*********************************************
HOW TO USE
********************************************
You will need files that have the following in their names
1. A file containing "Active" and is tab delimited i.e. Active Listings Report.txt
2. A file containing "FBA" and is tab delimited i.e. Manage FBA Inventory.txt
3. A file containing "CustomTransactio" and is comma delimited (*.csv) i.e. 2015May252015Jun24 CustomTransaction.csv

Select all three files and drpo them to the window saying "Drop Files Here".
You will get a notification that an output file has been created and where it has been stored.
*/

#SingleInstance, force
#Persistent

output := A_ScriptDir "\FlatFileInventoryLoader.txt"

Menu, tray, nodefault
menu, tray, nostandard
menu, tray, add, Exit
menu, tray, add, Restart

Gui, +alwaysontop +toolwindow -border
Gui, color, 000000
Gui, Add, Text, x12 y4 w120 h20 vinfo cLime, Drop Files Here
Gui, Show, w143 h25 x500 y0,xxxDropFiles
return

Exit:
GuiClose:
GuiEscape:
ExitApp

Restart:
Reload
return

GuiDropFiles:
Gui, 1: +OwnDialogs
n := A_EventInfo
if n != 3
{
	MsgBox,0,Error,Please drop the three input files. You have provided %n% instead.
	return
}
GuiControl,,info,Processing...
loop, parse, a_guievent, `n
{
	file := A_LoopField
	if file contains Active
		above30 := getAbove30(file)
	if file contains FBA
		qty0 := getAFHQTY0(file)
	if file contains CustomTransactio
		orders := getOrderSKU(file)
}
s=
above30 = %above30%
if above30 !=
{
	loop, parse, above30, `•
	{
		sku = %A_LoopField% ;has 30 days or more from today
		loop, parse, qty0, `•
		{
			if sku = %a_loopfield%
			{
				isin := false
				loop, parse, orders, `•
				{
					if sku = %a_loopfield%
						isin := true
				}
				if !isin
					s .= (s = "" ? sku : "•" sku) ;store this sku that passed all rules
			}
		}
	}
}
if s !=
{
	str=sku%a_tab%product-id%a_tab%product-id-type%a_tab%price%a_tab%minimum-seller-allowed-price%a_tab%maximum-seller-allowed-price%a_tab%item-condition%a_tab%quantity%a_tab%add-delete%a_tab%will-ship-internationally%a_tab%expedited-shipping%a_tab%standard-plus%a_tab%item-note%a_tab%fulfillment-center-id%a_tab%product-tax-code%a_tab%leadtime-to-ship%a_tab%merchant_shipping_group_name
	loop, parse, s, `•
		str .= "`n" A_LoopField A_Tab A_Tab A_Tab A_Tab A_Tab A_Tab A_Tab A_Tab "x"
	FileAppend,%str%,%output%
	MsgBox,4,Output,Your output file has been generated to %output%`n`nOpen it?
	IfMsgBox,Yes
		Run, % output
}
else {
	MsgBox,0,Error,No data was created. Maybe you did not drop the correct files.
}
GuiControl,,info,Drop Files Here
return

;;;core functions=============================================
getAbove30(file){
	s=
	FileRead, contents, % file
	loop, parse, contents, `n
	{
		row = %A_LoopField%
		nopendate=
		loop, parse, row, %a_tab%
		{
			if a_loopfield = seller-sku
				nsku = %A_Index%
			if a_loopfield = open-date
				nopendate = %a_index%
		}
		if nopendate !=
			break
	}
	loop, parse, contents, `n
	{
		row = %A_LoopField%
		loop, parse, row, %a_tab%
		{
			if a_index = %nsku%
				sku = %A_LoopField%
			if a_index = %nopendate%
				opendate = %A_LoopField%
		}
		opendate := RegExReplace(opendate,"[a-zA-Z_:-\s]+","")
		sku = %sku%
		if sku !=
		{
			if sku != seller-sku
			{
				if opendate !=
				{
					FormatTime,opendate, %opendate%,dd/MM/yyyy
					dd := DateParse(opendate)
					today := A_YYYY A_Mon A_DD
					ddd := getDays(dd,today)
					if ddd > 30
						s .= (s = "" ? sku : "•" sku)
				}
			}
		}
	}
	return s
}			

getAFHQTY0(file){
	s=
	FileRead, contents, %file%
	loop, parse, contents, `n
	{
		row = %A_LoopField%
		nqty=
		loop, parse, row, %a_tab%
		{
			if a_loopfield = sku
				nsku = %a_index%
			if a_loopfield = afn-total-quantity
				nqty = %A_Index%
		}
		if nqty !=
			break
	}
	loop, parse, contents, `n
	{
		row = %A_LoopField%
		loop, parse, row, %a_tab%
		{
			if a_index = %nsku%
				sku = %A_LoopField%
			if a_index = %nqty%
				qty = %A_LoopField%
		}
		sku = %sku%
		qty = %qty%
		if sku !=
		{
			if sku != sku
			{
				if qty !=
				{
					if qty is number
					{
						if qty = 0
							s .= (s = "" ? sku : "•" sku)
					}
				}
			}
		}
	}
	return s
}

getOrderSKU(file){
	s=
	FileRead, contents, %file%
	loop, parse, contents, `n
	{
		row = %A_LoopField%
		ntype=
		nsku=
		loop, parse, row, CSV
		{
			if a_loopfield = sku
				nsku = %A_Index%
			if a_loopfield = type
				ntype = %A_Index%
		}
		if nsku !=
			if ntype !=
				break
	}
	loop, parse, contents, `n
	{
		row = %A_LoopField%
		loop, parse, row, CSV
		{
			if a_index = %nsku%
				sku = %A_LoopField%
			if a_index = %ntype%
				type = %A_LoopField%
		}
		sku = %sku%
		if sku !=
		{
			if sku != sku
			{
				if type = Order
					s .= (s = "" ? sku : "•" sku)
			}
		}
	}
	return s
}

getDays(small,large){
	EnvSub,large,%small%,days
	return large
}

DateParse(str){
	static e1 = "i)(\d{1,2})\s*:\s*(\d{1,2})(?:\s*(\d{1,2}))?\s*([ap]m)"
		, e2 = "i)(?:(\d{1,2}+)[\s\.\-\/,]+)?(\d{1,2}|(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\w*)[\s\.\-\/,]+(\d{2,4})"
	str := RegExReplace(str, "((?:" . SubStr(e2, 42, 47) . ")\w*)(\s*)(\d{1,2})\b", "$3$2$1", "", 1)
	If RegExMatch(str, "i)^\s*(?:(\d{4})([\s\-:\/])(\d{1,2})\2(\d{1,2}))?"
		. "(?:\s*[T\s](\d{1,2})([\s\-:\/])(\d{1,2})(?:\6(\d{1,2})\s*(?:(Z)|(\+|\-)?"
		. "(\d{1,2})\6(\d{1,2})(?:\6(\d{1,2}))?)?)?)?\s*$", i)
		d3 := i1, d2 := i3, d1 := i4, t1 := i5, t2 := i7, t3 := i8
	Else If !RegExMatch(str, "^\W*(\d{1,2}+)(\d{2})\W*$", t)
		RegExMatch(str, e1, t), RegExMatch(str, e2, d)
	f = %A_FormatInteger%
	SetFormat, Float, 02.0
	d := (d3 ? (StrLen(d3) = 2 ? 20 : "") . d3 : A_YYYY)
		. ((d2 := d2 + 0 ? d2 : (InStr(e2, SubStr(d2, 1, 3)) - 40) // 4 + 1.0) > 0 ? d2 + 0.0 : A_MM)
		. ((d1 += 0.0) ? d1 : A_DD) . t1 + (t4 = "pm" ? 12.0 : 0.0) . t2 + 0.0 . t3 + 0.0
	SetFormat, Float, %f%
	Return, d
}













