;I have moved all functions to this single file to make my code neat and easilly understandable
addHTML(html){
	SetTitleMatchMode, 2
	global app
	try {
		page := GrabWidget()
		page.Document.getElementById("elements").click()
		sleep, 100
		page.Document.getElementById("tool_html").click()
		sleep, 100
		page.Document.getElementById("objectproperties").click()
		sleep, 100
		page.Document.getElementById("fb-html-content-textarea").value := html
		page.Document.getElementById("fb-html-content-textarea").focus()
		ControlSend,,{CtrlDown}{end}{Ctrlup}{space}, CoffeeCup Web Form
		sleep, 100
		page.Document.getElementById("objectproperties").click()
	} catch e {
		MsgBox,262144,%app%,There was a problem adding HTML element 
	}
}

addHiddenField(name,value){
	SetTitleMatchMode, 2
	global app
	try {
		page := GrabWidget()
		page.Document.getElementById("formproperties").click()
		sleep, 100
		page.Document.getElementById("formproperties").focus()
		ControlSend,,{Tab}{ShiftDown}{End}{ShiftUp}, CoffeeCup Web Form
		page.Document.getElementById("addhiddenitem").click()
		sleep, 500
		WinActivate,CoffeeCup Web Form
		;ControlSend,,{ShiftUp}%name%{tab}{ShiftUp}%value%,CoffeeCup Web Form
		Send,%name%{tab}%value%
	} catch e {
		MsgBox,262144,%app%, There was an error sending the SQL function
	}
}

;here I will include the library in use
#Include res/lib.ahk