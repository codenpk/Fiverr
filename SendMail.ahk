#SingleInstance, force
#Persistent

TrayTip,SendMail,Sending email...
pmsg 			:= ComObjCreate("CDO.Message")
pmsg.From 		:= "xthukuh@gmail.com"
pmsg.To 		:= "mthuku@resolution.co.ke"
;pmsg.BCC 		:= ""   ; Blind Carbon Copy, Invisable for all, same syntax as CC
;pmsg.CC 		:= "Somebody@somewhere.com, Other-somebody@somewhere.com"
pmsg.Subject 	:= "Testing STMP AutoHotKey"

;You can use either Text or HTML body like
pmsg.TextBody 	:= "Test Successiful"
;OR
;pmsg.HtmlBody := "<html><head><title>Hello</title></head><body><h2>Hello</h2><p>Testing!</p></body></html>"


sAttach   		:= A_Desktop "\web.jpg"  ;"Path_Of_Attachment" ; can add multiple attachments, the delimiter is |

fields := Object()
fields.smtpserver   := "smtp.gmail.com" ; specify your SMTP server
fields.smtpserverport     := 465 ; 25
fields.smtpusessl      := True ; False
fields.sendusing     := 2   ; cdoSendUsingPort
fields.smtpauthenticate     := 1   ; cdoBasic
fields.sendusername := "xthukuh@gmail.com"
fields.sendpassword := "Moonchild1"
fields.smtpconnectiontimeout := 60
schema := "http://schemas.microsoft.com/cdo/configuration/"


pfld :=   pmsg.Configuration.Fields

For field,value in fields
	pfld.Item(schema . field) := value
pfld.Update()

Loop, Parse, sAttach, |, %A_Space%%A_Tab%
  pmsg.AddAttachment(A_LoopField)
pmsg.Send()
TrayTip,SendMail,Test sending complete!