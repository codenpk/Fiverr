/* 
	Library contains functions being used by the KeywordListener. Note that they cannot work outside the script
	I made them in a separate file for cleaner code
*/

takeScreenShotOfWindow(window, screenshotimagepath){
	;takes the screenshot - uses GDIP library
	global pToken
	WinGetPos,x,y,w,h,% window
	file := screenshotimagepath
	IfExist,% file
		FileDelete, % file
	pToken:=Gdip_Startup()
	pBitmap:=Gdip_BitmapFromScreen(x "|" y "|" w "|" h) ;take a screenshot of only the window
	Gdip_SaveBitmapToFile(pBitmap, file, 100)
	Gdip_Shutdown(pToken)
	while NOT FileExist(file)
		Sleep, 10
}

SendScreenShotTo(to, pathofattachment){
	;emailing script found in the autohotkey forums
	;forum link := http://www.autohotkey.com/board/topic/81162-simplest-way-for-ahk-to-send-email-from-gmailcom/
	global smtpserver
	global smtpserverport
	global smtpusessl
	global sendusing
	global smtpauthenticate
	global sendusername
	global sendpassword
	global smtpconnectiontimeout
	global schema
	
	global keywords

	pmsg 			:= ComObjCreate("CDO.Message")
	pmsg.From 		:= "KeywordListener <" sendusername ">"
	pmsg.To 		:= to
	;pmsg.BCC 		:= ""   ; Blind Carbon Copy, Invisable for all, same syntax as CC
	;pmsg.CC 		:= "Somebody@somewhere.com, Other-somebody@somewhere.com"
	pmsg.Subject 	:= "KeywordListener found keywords " keywords

	;You can use either Text or HTML body like
	pmsg.TextBody 	:= "See attached screenshot for more information"
	;pmsg.HtmlBody := "<html><head><title>Hello</title></head><body><h2>Hello</h2><p>Testing!</p></body></html>"
	sAttach   		:=  pathofattachment ;"Path_Of_Attachment" ; can add multiple attachments, the delimiter is |

	fields := Object()
	fields.smtpserver   	:= smtpserver ; specify your SMTP server
	fields.smtpserverport	:= smtpserverport ;465  25
	fields.smtpusessl      	:= smtpusessl ; True False
	fields.sendusing     	:=  sendusing ;2   ; cdoSendUsingPort
	fields.smtpauthenticate     :=  smtpauthenticate ;1   ; cdoBasic
	fields.sendusername := sendusername
	fields.sendpassword := sendpassword
	fields.smtpconnectiontimeout := smtpconnectiontimeout ;60
	schema := schema ;"http://schemas.microsoft.com/cdo/configuration/"

	pfld :=   pmsg.Configuration.Fields
	For field,value in fields
		pfld.Item(schema . field) := value
	pfld.Update()
	
	Loop, Parse, sAttach, |, %A_Space%%A_Tab%
	  pmsg.AddAttachment(A_LoopField)
	pmsg.Send() ;we attempt to send the email - if you get too many errors with this send me a screenshot and email
}