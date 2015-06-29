#SingleInstance, force
#Persistent

;This script uses youtube-dl to download youtube videos and playlists
IfNotExist, %a_mydocuments%\Youtube
	FileCreateDir, %a_mydocuments%\Youtube
FileInstall, C:\Youtube\youtube-dl.exe, %a_mydocuments%\Youtube\youtube-dl.exe
temp = %A_Temp%\comdump.dl
Gui, +alwaysontop
Gui, Add, Text, x12 y10 w150 h20 , Youtube Link (Video/Playlist)
Gui, Add, Edit, x172 y10 w280 h20 vurl gurl,
Gui, Add, GroupBox, x12 y40 w440 h40 vinfo,
Gui, Add, Progress, x22 y60 w420 h10 -smooth vprog, 25
Gui, Add, Button, x12 y90 w100 h30 vbtn gbtn Disabled, Start Download
Gui, Show, w468 h131,Youtube-dl downloader
return

GuiClose:
ExitApp

btn:
Gui, submit, nohide
Gui, 1: +OwnDialogs
url = %url%
FileSelectFolder, fol, %a_desktop%,1,Select output folder
if errorlevel
	return
if fol=
	return
if url contains playlist
	cmd = youtube-dl  -c -t -i --no-part --console-title -o "%fol%\`%(title)s.`%(ext)s" %url% 
else
	cmd = youtube-dl  -c -t -i --no-part --console-title -o "%fol%\`%(title)s.`%(ext)s" %url% 
MsgBox % cmd
Clipboard := cmd
Run, %cmd%
return

url:
Gui, submit, nohide
if isyoutubelink(url)
	GuiControl, enable, btn
else
	GuiControl, disable, btn
return

isyoutubelink(url){
	return RegExMatch(url, "^(https?://|www.)(www.youtube.com|youtube.com)/(watch\?v=|playlist\?list=)(\w+)$")
}