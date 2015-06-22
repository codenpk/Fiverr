#SingleInstance, force
#Persistent
OnExit, exiting
wb := ComObjCreate("InternetExplorer.Application")
wb.Visible := false
wb.Toolbar := false
wb.Silent := true


/*
	This fetches for the product prices on the following websites
	Amazon.in
	shopclues.com
	flipkart.com
	Please note that it must be a valid product URL and please wait till the transparent floating window says Done!
*/


^!U:: ;press CTRL+ALT+U to fetch link product price once you have copied it on the clipboard
clip = %Clipboard%
Gui, color,000000
Gui, -border +AlwaysOnTop +ToolWindow
Gui, Add, Text, x12 y10 w140 h20 cWhite vinfo, Fetching Product Price...
Gui, Show, w172 h42,pdfetch00001
WinSet, region, 4-4 w170 h30,pdfetch00001
WinSet, Trans, 90, pdfetch00001
if clip =
{
	Gui, destroy
	return
}
try{
	GuiControl,,info,Please wait...
	links := getLinks(clip)
	Sort,link,U D`n
	loop,parse, links, `n
	{
		link = %A_LoopField%
		wb.Navigate(link)
		while wb.busy or wb.ReadyState != 4
			sleep, 30
		p = Not Found
		if link contains amazon
		{
			;we fetch in amazon
			p := wb.Document.getElementById("priceblock_ourprice").innerText
		}
		if link contains flipkart
		{
			;we fetch in flipkart
			n := wb.Document.getElementsByTagName("span").length
			loop, % n
			{
				try
				{
					itemCC := wb.Document.getElementsByTagName("span")[A_Index].className
				} catch e {
					itemCC =
				}
				if itemCC contains selling-price
					p := wb.Document.getElementsByTagName("span")[A_Index].innerText
			}
		}
		if link contains shopclues
		{
			;we fetch in shopclues selling-price
			n := wb.Document.getElementsByTagName("div").length
			loop, % n
			{
				try
				{
					itemCC := wb.Document.getElementsByTagName("div")[A_Index].className
				} catch e {
					itemCC =
				}
				if itemCC contains price
				{
					p := wb.Document.getElementsByTagName("div")[A_Index].innerText
					break
				}
			}
		}
		p = %p%
		newlink := link " at " p
		StringReplace,clip,clip,%link%,%newlink%,all
	}
	Clipboard := clip
	GuiControl,,info,Done!
	sleep, 1000
} catch e {
	MsgBox,0,Fetching Product Price,There was a problem fetching the link in the clipboard:`n`n%link%`n`nIt might not be a valid product link.
}
Gui, destroy
return

exiting:
try{
	;attempt to terminate the wb
	wb.Quit()
} catch e{
	;do nothing
}
ExitApp

getLinks(text){
	while pos := RegExMatch(text, "(https?:|.)\/\/[^\s]+", m, A_Index=1?1:pos+StrLen(m))
		res .= (res=""?m:"`n" m)
	res = %res%
	return res
}