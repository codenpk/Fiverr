#SingleInstance,force
#Persistent

URL := "https://affiliate-api.flipkart.net/affiliate/product/json?id="
ID := "flipkarto15"
TOKEN := "efdc2ea0394b4585a5854704b22b788a"
dataString := "No data yet"
dataJSON := "{}"

Gui, Add, GroupBox, x12 y10 w320 h90 , Product
Gui, Add, Text, x22 y30 w60 h20 , Product ID
Gui, Add, Edit, x82 y30 w240 h20 vpid, ;REMOVE THIS TO PREVENT IT FROM SHOWING ON START
Gui, Add, Button, x222 y60 w100 h30 vbtn ggetProduct, Load Product
Gui, Add, ListView, x12 y110 w660 h250 +Grid -Multi vlistview glistview AltSubmit,Field|Details
Gui, Add, Button, x12 y+5 w100 h30 ggetString Default, Get String
Gui, Add, Button, x+12 w100 h30 ggetJson, Get JSON
Gui, Font, S15 CDefault, Verdana
Gui, Add, Text, x392 y30 w240 h30 vinfo cred,
Gui, Show, w688 h400,FlipCart Get Product
Menu, listmenu, add, View, viewrow
Menu, listmenu, add, Copy, copyrow
return

^!p:: ;Ctrl+Alt+P
clipData := Clipboard
clipData = %clipData% ;trim
GuiControl,,pid,% clipData
gosub, getProduct
MsgBox,0,FlipCart Get Product,Product details have been fetched! You can press Ctrl+Alt+G to get string on Clipboard. Note. This replaces the Clipboard data
return

^!g::
goto, getString

GuiClose:
ExitApp

viewrow:
LV_GetText(field,n,1)
LV_GetText(details,n,2)
MsgBox, 64, %field%, %details%
return

copyrow:
LV_GetText(field,n,1)
LV_GetText(details,n,2)
Clipboard =  %field%: %details%
MsgBox, 64, %field%, Copied!
return

listview:
n := LV_GetNext()
if n = 0
	return
if a_guievent = DoubleClick
{
	LV_GetText(field,n,1)
	LV_GetText(details,n,2)
	MsgBox, 64, %field%, %details%
}
if a_guievent = RightClick
	Menu, listmenu, show
return

getString:
Clipboard := dataString
MsgBox, 64,Get String, Copied!
return

getJSON:
Clipboard := dataJSON
MsgBox, 64,Get JSON, Copied!
return

getProduct:
Gui, submit, nohide
pid = %pid%
if pid=
{
	MsgBox, 48, %app%, Invalid Product ID
	return
}
GuiControl,disable,btn
GuiControl,disable,pid
GuiControl,,info,Please wait...
request := ComObjCreate("WinHttp.WinHttpRequest.5.1")
request.Open("GET", URL pid, False)
request.SetRequestHeader("Fk-Affiliate-Id", ID)
request.SetRequestHeader("Fk-Affiliate-Token", TOKEN)
request.SetRequestHeader("User-Agent", "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)")
request.SetRequestHeader("Referer", URL)
;request.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
request.Send()
data := request.ResponseText
dataJSON = %data%
data = %data%
if data =
{
	MsgBox, 48, %app%, Failed to get product details
	GuiControl,enable,btn
	GuiControl,enable,pid
	GuiControl,,info,
	return
}
ShippingInfo := json(data,"productShippingBaseInfo.shippingOptions")
offset := json(data,"offset")
productID := json(data,"productBaseInfo.productIdentifier.productId")
categories=
loop
{
	n := A_Index
	cat := json(data,"productBaseInfo.productIdentifier.categoryPaths.categoryPath[" n "]")
	if cat =
		break
	loop
	{
		tit := json(data,"productBaseInfo.productIdentifier.categoryPaths.categoryPath[" n "][" A_Index "].title")
		if tit =
			break
		categories .= (categories = "" ? tit : ", " tit)
	}
}
title := json(data,"productBaseInfo.productAttributes.title")
descr := json(data,"productBaseInfo.productAttributes.productDescription")
imageUrls := json(data,"productBaseInfo.productAttributes.imageUrls")
maximumRetailPriceAmt := json(data,"productBaseInfo.productAttributes.maximumRetailPrice.amount")
maximumRetailPricecurr := json(data,"productBaseInfo.productAttributes.maximumRetailPrice.currency")
sellingPriceAmt := json(data,"productBaseInfo.productAttributes.sellingPrice.amount")
sellingPricecurr := json(data,"productBaseInfo.productAttributes.sellingPrice.currency")
productUrl := json(data,"productBaseInfo.productAttributes.productUrl")
productBrand := json(data,"productBaseInfo.productAttributes.productBrand")
inStock := (json(data,"productBaseInfo.productAttributes.inStock")? "True" : "False")
codAvailable := (json(data,"productBaseInfo.productAttributes.codAvailable")? "True" : "False")
emiAvailable := (json(data,"productBaseInfo.productAttributes.emiAvailable")? "True" : "False")
discountPercentage := json(data,"productBaseInfo.productAttributes.discountPercentage")
cashBack := json(data,"productBaseInfo.productAttributes.cashBack")
offers=
loop
{
	off := productBaseInfo.productAttributes.offers[A_Index].title
	if off =
		break
	offers .= (offers = "" ? off : ", " off)
}
size := json(data,"productBaseInfo.productAttributes.size")
color := json(data,"productBaseInfo.productAttributes.color")
sizeUnit := json(data,"productBaseInfo.productAttributes.sizeUnit")
sizeVariants := json(data,"productBaseInfo.productAttributes.sizeVariants")
colorVariants := json(data,"productBaseInfo.productAttributes.colorVariants")
styleCode := json(data,"productBaseInfo.productAttributes.styleCode")

;generate string ready for paste
dataString = Product ID: %productID%`nCategories: %categories%`nTitle: %title%`nDescription: %descr%`nImage URLs: %imageUrls%`nMax Retail Price Amount: %maximumRetailPriceAmt%`nMax Retail Price Currency: %maximumRetailPricecurr%`nSelling Price Amount: %sellingPriceAmt%`nSelling Price Currency: %sellingPricecurr%`nProduct URL: %productUrl%`nProduct Brand: %productBrand%`nIn Stock: %inStock%`nCOD Available: %codAvailable%`nEMI Available: %emiAvailable%`nDiscount Percentage: %discountPercentage%`nCash Back: %cashBack%`nOffers: %offers%`nSize: %size%`nColor: %color%`nSize Unit: %sizeUnit%`nSize Variants: %sizeVariants%`nColor Variants: %colorVariants%`nStyle Code: %styleCode%`nShipping Info: %ShippingInfo%`nOffset: %offset%

;update GUI
GuiControl,-redraw,listview
LV_Delete()
LV_Add("","Product ID",productID)
LV_Add("","Categories",categories)
LV_Add("","Title",title)
LV_Add("","Description",descr)
LV_Add("","Image URLs",imageUrls)
LV_Add("","Max Retail Price Amount",maximumRetailPriceAmt)
LV_Add("","Max Retail Price Currency",maximumRetailPricecurr)
LV_Add("","Selling Price Amount",sellingPriceAmt)
LV_Add("","Selling Price Currency",sellingPricecurr)
LV_Add("","Product URL",productUrl)
LV_Add("","Product Brand",productBrand)
LV_Add("","In Stock",inStock)
LV_Add("","COD Available",codAvailable)
LV_Add("","EMI Available",emiAvailable)
LV_Add("","Discount Percentage",discountPercentage)
LV_Add("","Cash Back",cashBack)
LV_Add("","Offers",offers)
LV_Add("","Size",size)
LV_Add("","Color",color)
LV_Add("","Size Unit",sizeUnit)
LV_Add("","Size Variants",sizeVariants)
LV_Add("","Color Variants",colorVariants)
LV_Add("","Style Code",styleCode)
LV_Add("","Shipping Info",ShippingInfo)
LV_Add("","Offset",offset)
Loop, % LV_GetCount("Col")
	LV_ModifyCol(a_index,"AutoHdr")
GuiControl,+redraw,listview
GuiControl,enable,btn
GuiControl,enable,pid
GuiControl,,info,
return

;important
json(ByRef js, s, v = "") {
	j = %js%
	Loop, Parse, s, .
	{
		p = 2
		RegExMatch(A_LoopField, "([+\-]?)([^[]+)((?:\[\d+\])*)", q)
		Loop {
			If (!p := RegExMatch(j, "(?<!\\)(""|')([^\1]+?)(?<!\\)(?-1)\s*:\s*((\{(?:[^{}]++|(?-1))*\})|(\[(?:[^[\]]++|(?-1))*\])|"
				. "(?<!\\)(""|')[^\7]*?(?<!\\)(?-1)|[+\-]?\d+(?:\.\d*)?|true|false|null?)\s*(?:,|$|\})", x, p))
				Return
			Else If (x2 == q2 or q2 == "*") {
				j = %x3%
				z += p + StrLen(x2) - 2
				If (q3 != "" and InStr(j, "[") == 1) {
					StringTrimRight, q3, q3, 1
					Loop, Parse, q3, ], [
					{
						z += 1 + RegExMatch(SubStr(j, 2, -1), "^(?:\s*((\[(?:[^[\]]++|(?-1))*\])|(\{(?:[^{\}]++|(?-1))*\})|[^,]*?)\s*(?:,|$)){" . SubStr(A_LoopField, 1) + 1 . "}", x)
						j = %x1%
					}
				}
				Break
			}
			Else p += StrLen(x)
		}
	}
	If v !=
	{
		vs = "
		If (RegExMatch(v, "^\s*(?:""|')*\s*([+\-]?\d+(?:\.\d*)?|true|false|null?)\s*(?:""|')*\s*$", vx)
			and (vx1 + 0 or vx1 == 0 or vx1 == "true" or vx1 == "false" or vx1 == "null" or vx1 == "nul"))
			vs := "", v := vx1
		StringReplace, v, v, ", \", All
		js := SubStr(js, 1, z := RegExMatch(js, ":\s*", zx, z) + StrLen(zx) - 1) . vs . v . vs . SubStr(js, z + StrLen(x3) + 1)
	}
	Return, j == "false" ? 0 : j == "true" ? 1 : j == "null" or j == "nul"
		? "" : SubStr(j, 1, 1) == """" ? SubStr(j, 2, -1) : j
}
