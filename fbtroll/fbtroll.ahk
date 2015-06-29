/*
	FBTROLL SCRIPT
	
	DESCRIPTION
	------------------------------------------
	I just realized that autohotkey only supports COM interractions with Internet Explorer only. So this script will be running facebook in manipulation of the users who are logged in on facebook or have set their log-on sessions on "remember"
	-----------------------------------------
*/

#SingleInstance,force ;to enable only 1 instanced of the script at a time
#Persistent ;persistent

data_url = http://localhost/ahk/data.json ;change this to the page that will be providing the json data for the app
action_ids = ;this will store already executed actions so that we dont repeat them
delay=1000 ;add some delay 

SetTimer,check_facebook,%delay% ;run the check_facebook sub every 60000 miliseconds to know if user is loggen on facebook
return

check_facebook: ;called every 60000 miliseconds
SetTimer,check_facebook,off
pwb := ComObjCreate("InternetExplorer.Application") ;start IE
pwb.Visible := false ;run IE in hidden mode
pwb.ToolBar := false ;run IE without toolbar - loads faster
pwb.Navigate("https://www.facebook.com") ;navigate to facebook
While pwb.ReadyState != 4 ;wait till the page has loaded
	Sleep 100
trs := pwb.document.getElementsByTagName("textarea").length ;get the number if textareas on the loaded page
if trs > 0 ;if textareas are more than 0 then the user is logged on and we can manipulate the update status
	goto, action
pwb.quit() ;important we close IE if the user is not logged on to prevent memory crash
return


action: ;called when the user is logged on facebook
Sleep,1000 ;add some delay
whr := ComObjCreate("WinHttp.WinHttpRequest.5.1") ;JUST DOWNLOAD JSON DATA TO A VARIABLE
whr.Open("GET", data_url)
whr.Send()
data := whr.ResponseText
action_id := json(data, "json.action_id") ;get action id from JSON
post := json(data, "json.data") ;get new status from JSON
if action_ids contains %action_id%
{
	;seems like we have already used that action_id so no need to repeat the process
	return
}

;since we have not used the action_id we need to store it then perform the status update
action_ids := (action_ids =""?action_id:action_ids "," action_id)
sleep,1000 ;wait for it to be active
pwb.document.getElementsByTagName("textarea")[0].value := post ;type the new status to the new status box
sleep,1000 ;wait for the post to sink in
;now we look for the button containing the words "Post" for us to click it
n :=pwb.document.getElementsByTagName("button").length
loop, %n%
{
	button_text := pwb.document.getElementsByTagName("button")[A_Index].innerText
	if button_text contains Post
	{
		;we have the post button now so we click it since we already added the new status
		pwb.document.getElementsByTagName("button")[A_Index].click()
		sleep,10000 ;wait for the post to go
		break
	}
}
pwb.quit() ;we close the explorer since we are through with the task of posting the new status
return ; we close the sub to be called again later.



/*
	=======================================================
	This is a function to decode json data for us
*/
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