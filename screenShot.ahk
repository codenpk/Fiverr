#SingleInstance, force

#T::
WinGetActiveTitle,win
WinGetPos,x,y,w,h,% win
TrayTip,Screenshot,Screenshotting...
file:= A_Desktop "\joe.jpg"
IfExist,% file
	FileDelete, % file
/*
nl:=100
nt:=100
nw:=200
nh:=200
*/
pToken:=Gdip_Startup()
pBitmap:=Gdip_BitmapFromScreen(x "|" y "|" w "|" h) ;x|y|w|h 
;pBitmap:=Gdip_BitmapFromScreen(nL "|" nT "|" nW "|" nH) ;x|y|w|h 
Gdip_SaveBitmapToFile(pBitmap, file, 100)
Gdip_Shutdown(pToken)
while NOT FileExist(file)
   Sleep, 10
MsgBox Done!
ExitApp

#Include GDIP.ahk
