/*
	Source code made with love by Fiverr - martinthuku
*/
#SingleInstance,force
#Persistent
#NoTrayIcon

screen_width := A_ScreenWidth
s := (screen_width / 2) - (137/2)
Gui, +alwaysontop +toolwindow 
Gui, Font, S12 CDefault, Verdana
Gui, Add, Text, x12 y10 w110 h70,Drop CSV
Gui, Show, w137 h36 x%s% y0,Repricer
return

GuiEscape:
GuiClose:
ExitApp

GuiDropFiles:
files := A_GuiEvent
loop,parse,files,`n
{
file := A_LoopField
SplitPath,file,,dir,ext,file_name
bQool = %dir%\%file_name%.bQool.output.tsv.txt
amazon = %dir%\%file_name%.Amazon.output.tsv
if ext = csv
{
FileDelete,% amazon
FileDelete,% bQool
FileAppend,
(
FileType = repricing,  Version = 1.2.0 (Please do not edit this line or this will result in error when uploading)						
Channel	SellerSKU	Cost	Rule Name	Min Price	Max Price	add-delete
),%bQool%
FileAppend,
(
sku	price	minimum-seller-allowed-price	maximum-seller-allowed-price	quantity	leadtime-to-ship	fulfillment-channel
),%amazon%
add_content(file,bQool,amazon)
}
}
return

add_content(file,bQool,amazon){
	GuiControl,,info,Please wait
	FileRead,csv,%file%
	loop,parse,csv,`n
	{
		lineDetails := A_LoopField
		lineDetails = %lineDetails%
		if lineDetails !=
		{
			if a_index > 1
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
				add_line(sku,cost,price,bQool,amazon)
			}
		}
	}
}

add_line(sku,cost,price,bQool,amazon){
	SetFormat,float,10.2
	cost2 := cost * 1
	price2 := price * 1
	price3 := price * 2
	FileAppend,`n%sku%%A_Tab%%cost2%%A_Tab%%A_Tab%%A_Tab%%A_Tab%,%amazon%
	FileAppend,`nAmazon US%A_Tab%%sku%%A_Tab%%cost2%%A_Tab%Get Buy Box%A_Tab%%price2%%A_Tab%%price3%%A_Tab%a,%bQool%
}