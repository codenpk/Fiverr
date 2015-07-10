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

getFields(){
	items =
	try {
		page := GrabWidget()
		e := page.Document.getElementById("docContainer").getElementsByTagName("div").length
		loop, % e
		{
			try {
				n := A_Index
				elength := page.Document.getElementById("docContainer").getElementsByTagName("div")[n].children.length
				loop, % elength
				{
					ename := page.Document.getElementById("docContainer").getElementsByTagName("div")[n].children[0].name
					ename = %ename%
					if ename !=
						items .= (items = "" ? ename : "`n" ename)
					ename=
				}
				elength2 := page.Document.getElementById("column1").getElementsByTagName("div").length
				loop, % elength2
				{
					n := A_Index
					eidClass := page.Document.getElementById("column1").getElementsByTagName("div")[n].className
					test=fb-item
					if eidClass not contains %test%
						eid := page.Document.getElementById("column1").getElementsByTagName("div")[n].id
					if eid !=
						if eid not contains item
							items .= (items = "" ? eid : "`n" eid)
					eid=
				}
			} catch e {
				;ignore
			}
		}
	} catch e {
		MsgBox,262144,FormBuilderTool, There was an error`n %e%
	}
	Sort,items,U D`n
	return items
}

validateFields(fields){
	av := getFields()
	if fields contains `,
	{
		loop, parse, fields, `,
		{
			if av not contains %a_loopfield%
				return a_loopfield
		}
		return 1
	}
	else
	{
		if av not contains %fields%
			return %fields%
		else
			return 1
	}
	return ""
}

;here I will include the library in use
#Include res/lib.ahk