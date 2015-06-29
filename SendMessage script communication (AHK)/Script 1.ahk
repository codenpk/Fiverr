#SingleInstance,force
#Persistent

/*
	This is a simple application that will communicate with two scripts.
	For this to work properly, please run script 1 and script 2
	
	There are two ways I know to link up two scripts.
	You can use #include to add a script to another script. Please check the help files for that.
	
	In this example, we will use OnMessage and SendMessage to allow scripts to send strings to each other.
	You can program the scripts to intepret strings the way you want (Thats how I manage to run functions between scripts. I will show you how to get creative
*/

;am using a GUI example to test this
;Generated using SmartGUI Creator for SciTE
Gui, Add, GroupBox, x12 y10 w300 h300 , Testing Sending Strings ;draw a group box in the GUI
Gui, Add, Text, x22 y40 w200 h20 , Send String to the other script ;draw a text in the GUI
Gui, Add, Edit, x22 y60 w280 h70 vsampletext, ;draw an edit box in the GUI with name "sampletext" 
Gui, Add, Button, x22 y140 w100 h30 gsend, Send ;draw a button that calls the subroutine "send" named as "gsend"
Gui, Add, Text, x22 y190 w200 h20 , Received String from the other script ;draw a text in the GUI
Gui, Add, Edit, x22 y210 w280 h90 ReadOnly voutput, ;draw an edit box that is readonly and is named "output" as "voutput"
Gui, Add, Button, x332 y20 w220 h30 , Test a function in script 2 ;draw a button that calls the subroutine "test_function" as "gtest_function"
Gui, Add, Button, x332 y60 w220 h30 , Test a function with parameters in script 2 ;draw a button that calls the subroutine "test_function_2" as "gtest_function_2"
Gui, Show, w571 h324,Script 1 ;we show the user interface then
OnMessage(0x4a, "RECEIVED_STRING") ;this is called so that we can detect when we receive string from other script. It calls a function called RECEIVED_STRING
return ;this prevents the script from jumping to the subroutines below

GuiClose: ;close the script when you explicitly close the GUI
GuiEscape: ;close the script when you hit the escape button on this GUI
ExitApp

send: ;called by our send button
Gui, submit, nohide ;we submit every data on this GUI but we keep it with the nohide
StringToSend = %sampletext% ;we trim the data from sampletext so we can send it
TargetScriptTitle = Script 2 ;we name the script window. NB: IF THE SCRIPT HAS NO WINDOW USE "Receiver.ahk ahk_class AutoHotkey"
if SEND_STRING(StringToSend, TargetScriptTitle) ;We send the string
	MsgBox Completed sending string to script 2 ;we prompt of on success
else 
	MsgBox We failed to send the string to script 2 ;we prompt if we failed
return

test_function:
StringToSend := "CallFunction,function_in_script1"
TargetScriptTitle = Script 2 ;we name the script window. NB: IF THE SCRIPT HAS NO WINDOW USE "Receiver.ahk ahk_class AutoHotkey"
if POST_STRING(StringToSend, TargetScriptTitle) ;We send the string
	MsgBox Completed sending string to script 2 ;we prompt of on success
else 
	MsgBox We failed to send the string to script 2 ;we prompt if we failed
return

test_function_2:
StringToSend := "CallFunction,function_in_script1_add,2,5" ;should add 2 + 5
TargetScriptTitle = Script 2 ;we name the script window. NB: IF THE SCRIPT HAS NO WINDOW USE "Receiver.ahk ahk_class AutoHotkey"
if SEND_STRING(StringToSend, TargetScriptTitle) ;We send the string
	MsgBox Completed sending string to script 2 ;we prompt of on success
else 
	MsgBox We failed to send the string to script 2 ;we prompt if we failed
return

SEND_STRING(ByRef StringToSend, ByRef TargetScriptTitle)  ; ByRef saves a little memory in this case. ;Copied from examples
; This function sends the specified string to the specified window and returns the reply.
; The reply is 1 if the target window processed the message, or 0 if it ignored it.
{
    VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)  ; Set up the structure's memory area.
    ; First set the structure's cbData member to the size of the string, including its zero terminator:
    SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
    NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)  ; OS requires that this be done.
    NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)  ; Set lpData to point to the string itself.
    Prev_DetectHiddenWindows := A_DetectHiddenWindows
    Prev_TitleMatchMode := A_TitleMatchMode
    DetectHiddenWindows On
    SetTitleMatchMode 2
    SendMessage, 0x4a, 0, &CopyDataStruct,, %TargetScriptTitle%  ; 0x4a is WM_COPYDATA. Must use Send not Post.
    DetectHiddenWindows %Prev_DetectHiddenWindows%  ; Restore original setting for the caller.
    SetTitleMatchMode %Prev_TitleMatchMode%         ; Same.
    return ErrorLevel  ; Return SendMessage's reply back to our caller.
}

POST_STRING(ByRef StringToSend, ByRef TargetScriptTitle)  ; ByRef saves a little memory in this case. ;Copied from examples
; This function sends the specified string to the specified window and returns the reply.
; The reply is 1 if the target window processed the message, or 0 if it ignored it.
{
    VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)  ; Set up the structure's memory area.
    ; First set the structure's cbData member to the size of the string, including its zero terminator:
    SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
    NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)  ; OS requires that this be done.
    NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)  ; Set lpData to point to the string itself.
    Prev_DetectHiddenWindows := A_DetectHiddenWindows
    Prev_TitleMatchMode := A_TitleMatchMode
    DetectHiddenWindows On
    SetTitleMatchMode 2
    PostMessage, 0x4a, 0, &CopyDataStruct,, %TargetScriptTitle%  ; 0x4a is WM_COPYDATA.
    DetectHiddenWindows %Prev_DetectHiddenWindows%  ; Restore original setting for the caller.
    SetTitleMatchMode %Prev_TitleMatchMode%         ; Same.
}
	
RECEIVED_STRING(wParam, lParam) ;copied from examples
{
    StringAddress := NumGet(lParam + 2*A_PtrSize)  ; Retrieves the CopyDataStruct's lpData member.
    StringReceived := StrGet(StringAddress)  ; Copy the string out of the structure.
	
	;we get creative with the received string
	;e.g. We can structure a simple string to mean we are calling a function. in this example, am structuring this function to treat strings that contain the word CallFunction as a command to call a function after the comma and the parameters after the second comma and so on. If the string does not contain the word CallFunction, we can assume its a simple string and we can just output it in the received string
	
	if StringReceived contains CallFunction
	{
		;using the explanation above, we have received a command to call a function. The string should be in the format:
		;CallFunction,fnctionName,param1,param2...
		;so if we parse the script, we will check if the command includes the paramenters or not so we can include them if they exist
		loop,parse,StringReceived,`, ;we loop through the command String - remember this is just getting creative. You can of course make the string mean anything
			number_of_items_btn_commas := A_Index ;we store the number of items between commas in our command string
		if number_of_items_btn_commas = 4 ;this means the string is a command to the function that has parameters :)
		{
			loop,parse,StringReceived,`,
			{
				if a_index = 2
					function := A_LoopField ;function name
				if a_index = 3
					a := A_LoopField ;param1
				if a_index = 4
					a := A_LoopField ;param2
			}
			%function%(%a%,%b%) ;yes, you can call a function dynamically. Please read the help file for this and more
		}
		else {
			if number_of_items_btn_commas = 2 ;we assume we are calling a function with no paramenters
			{
				loop,parse,StringReceived,`,
				{
					if a_index = 2
						function := A_LoopField ;function name
				}
				%function%()
			}
		}
	}
	else {
		;this means that this is a normal string and we just need to output it
		GuiControl,,output, %StringReceived%
	}
    return true
}


;these functions we need to cal using script 2
function_in_script1(){
	MsgBox,0,Script 1,This has been generated by a function in script 1
}

function_in_script1_add(a,b){
	c := a + b
	MsgBox,0,Script 1,This has been generated by a function in script 1`n`nThe answer for %a% + %b% = %c%
}

