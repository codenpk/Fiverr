#SingleInstance, Force
#NoEnv
SetBatchLines, -1
 
; Uncomment if Gdip.ahk is not in your standard library
#Include lib.ahk
 
; Start gdi+
If !pToken := Gdip_Startup()
{
	MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
	ExitApp
}
OnExit, Exit
 
 
pBitmap := Gdip_CreateBitmapFromFile("logo2.png")
Width := Gdip_GetImageWidth(pBitmap)
Height := Gdip_GetImageHeight(pBitmap)
hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
Gui, 1: Add, Picture, x10 y+30 w%Width% h%Height% 0xE vMyPicture
GuiControlGet, hwnd, hwnd, MyPicture
SetImage(hwnd, hBitmap)
Gui, 1: Show, AutoSize,  gdi+ picture in GUI
return
 
GuiClose:
Exit:
; gdi+ may now be shutdown on exiting the program
Gdip_Shutdown(pToken)
ExitApp
Return