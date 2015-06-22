;--- example Youtube play
;--- needs com.ahk
;--- http://www.autohotkey.com/forum/topic34972.html
;--- %A_programfiles%\AutoHotkey\Lib\com.ahk ---

ytcd=IHzIItZKmD8   ;Ye Lai Xiang
url=http://www.youtube.com/v/%ytcd%&autoplay=1

code =
(
<HTML><HEAD><TITLE></TITLE></HEAD><BODY topMargin=0 leftMargin=0 scroll=no>
<OBJECT width="100`%" height="100`%"><param name="movie" value="%url%"></param>
<param name="allowFullScreen" value="true" />
<EMBED width="100`%" height="100`%" src="%url%" type="application/x-shockwave-flash" allowfullscreen="true">
</EMBED></OBJECT></BODY></HTML>
)

COM_AtlAxWinInit()
Gui,2: +LastFound +Resize
gui,2: add, picture, HwndVideo x70 y10 w720 h480
pwb := COM_AtlAxCreateControl( Video, "Shell.Explorer")
;pwb := COM_AtlAxCreateControl( WinExist(), "Shell.Explorer")
COM_Invoke(pwb, "Navigate", "about:blank")
Gui,2:Add,Button,x5 y10  gTEST1,Youtube
Gui,2:Show, w800 h500, Youtube - %url%
COM_Invoke(pwb, "document.write", code)
return

TEST1:
;run,http://www.youtube.com/watch?v=IHzIItZKmD8
run,http://www.youtube.com/profile?user=zoundcracker#grid/uploads
return

2GuiClose:
Gui,2: Destroy
COM_Release(pwb)
COM_AtlAxWinTerm()
ExitApp

#Include COM.ahk