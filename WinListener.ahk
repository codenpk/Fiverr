; WinEventHook Messages v0.3 by Serenity 
; http://www.autohotkey.com/forum/viewtopic.php?t=35659
#SingleInstance Force
#Persistent
SetBatchLines,-1
; Process, Priority,, High
ExcludeScriptMessages = 1 ; 0 to include
Title := "WinEventHook Messages", Filters := "", Pause := 0
FilterMenu(), Gui()
ahk := WinExist(), WM_VSCROLL := 0x115, SB_BOTTOM := 7
HookProcAdr := RegisterCallback( "HookProc", "F" )
dwFlags := ( ExcludeScriptMessages = 1 ? 0x1 : 0x0 )
hWinEventHook := SetWinEventHook( 0x1, 0x17, 0, HookProcAdr, 0, 0, 0 )
Return

FilterMenu()
{
	Global FilterList
	Menu, Filter, Add, Filter &All, FilterAll
	Menu, Filter, Add, Filter &None, FilterNone
	Menu, Filter, Add
	FilterList = SOUND,ALERT,FOREGROUND,MENUSTART,MENUEND,MENUPOPUPSTART,MENUPOPUPEND
	,CAPTURESTART,CAPTUREEND,MOVESIZESTART,MOVESIZEEND,CONTEXTHELPSTART
	,CONTEXTHELPEND,DRAGDROPSTART,DRAGDROPEND,DIALOGSTART,DIALOGEND,SCROLLINGSTART
	,SCROLLINGEND,SWITCHSTART,SWITCHEND,MINIMIZESTART,MINIMIZEEND
	
	Loop, Parse, FilterList, `,
	{
		If A_Loopfield	
			Menu, Filter, Add, %A_Loopfield%, SetFilter
	}
	Menu, FilterMenu, Add, Message &Filter, :Filter
	Gui, Menu, FilterMenu
}

Gui()
{
	Global
	Gui, +LastFound +AlwaysOnTop +Resize ; +ToolWindow
	Gui, Margin, 0, 0
	Gui, Font, s8, Microsoft Sans Serif
	Gui, Color,, DEDEDE
	Gui, Add, ListView, w600 r10 vData +Grid +NoSort, Hwnd|idObject|idChild|Title|Class|Event|Message
	LV_ModifyCol( 1, 60 ), LV_ModifyCol( 2, 40), LV_ModifyCol( 3, 40)
	LV_ModifyCol( 4, 100 ), LV_ModifyCol( 5, 100 ), LV_ModifyCol( 7, 190 )
	Gui, Show,, %Title%
}

HookProc( hWinEventHook, Event, hWnd, idObject, idChild, dwEventThread, dwmsEventTime )
{
	Global Pause,WM_VSCROLL,SB_BOTTOM,ahk,Filters
	
	SetFormat, Integer, Dec
	Event += 0

	if Event = 1
		Message = EVENT_SYSTEM_SOUND
	else if Event = 2 
		Message = EVENT_SYSTEM_ALERT
	else if Event = 3
		Message = EVENT_SYSTEM_FOREGROUND
	else if Event = 4
		Message = EVENT_SYSTEM_MENUSTART		
	else if Event = 5
		Message = EVENT_SYSTEM_MENUEND
	else if Event = 6
		Message = EVENT_SYSTEM_MENUPOPUPSTART
	else if Event = 7
		Message = EVENT_SYSTEM_MENUPOPUPEND
	else if Event = 8
		Message = EVENT_SYSTEM_CAPTURESTART
	else if Event = 9
		Message = EVENT_SYSTEM_CAPTUREEND
	else if Event = 10
		Message = EVENT_SYSTEM_MOVESIZESTART
	else if Event = 11
		Message = EVENT_SYSTEM_MOVESIZEEND 
	else if Event = 12
		Message = EVENT_SYSTEM_CONTEXTHELPSTART
	else if Event = 13
		Message = EVENT_SYSTEM_CONTEXTHELPEND
	else if Event = 14
		Message = EVENT_SYSTEM_DRAGDROPSTART
	else if Event = 15
		Message = EVENT_SYSTEM_DRAGDROPEND
	else if Event = 16
		Message = EVENT_SYSTEM_DIALOGSTART
	else if Event = 17
		Message = EVENT_SYSTEM_DIALOGEND
	else if Event = 18
		Message = EVENT_SYSTEM_SCROLLINGSTART
	else if Event = 19
		Message = EVENT_SYSTEM_SCROLLINGEND
	else if Event = 20
		Message = EVENT_SYSTEM_SWITCHSTART
	else if Event = 21	
		Message = EVENT_SYSTEM_SWITCHEND
	else if Event = 22
		Message = EVENT_SYSTEM_MINIMIZESTART
	else if Event = 23
		Message = EVENT_SYSTEM_MINIMIZEEND
	
	Sleep, 50 ; give a little time for WinGetTitle/WinGetActiveTitle functions, otherwise they return blank
	
	EventHex := Event
	SetFormat, Integer, Hex
	EventHex += 0, hWnd += 0, idObject += 0, idChild += 0 

	If Event not in %Filters%
	{
		If ( Pause = 0 )
		{
			LV_Add( "", hWnd, idObject, idChild, WinGetTitle(hWnd), WinGetClass(hWnd), EventHex, Message )		
		}
		SendMessage, WM_VSCROLL, SB_BOTTOM, 0, SysListView321, ahk_id %ahk%
	}	
}

SetFilter:
Menu, Filter, ToggleCheck, %A_ThisMenuItem%
Loop, Parse, FilterList, `,
{
	If ( A_ThisMenuItem = A_Loopfield )
	{
		If A_Index in %Filters% ; remove from filter
		{		
			Filter := A_Index
			Loop, Parse, Filters, `,
			{
				If ( A_Loopfield != Filter )
					NewFilters .= A_Loopfield . ( A_Loopfield != "" ? "`," : "" ) 
			}
			Filters := NewFilters, NewFilters := ""
		}	
		Else ; add to filter
		{
			Filters .= A_Index . ","
		}	
	}	
}
Return

FilterAll:
Filters =
Loop, Parse, FilterList, `,
{	
	Menu, Filter, Check, %A_Loopfield%
	Filters .= A_Index . ( A_Index != 23 ? "," : "" ) 
}
Return

FilterNone:
Loop, Parse, FilterList, `,
{
	Menu, Filter, UnCheck, %A_Loopfield%
	Filters = 
}
Return

WinGetTitle( hwnd )
{
	WinGetTitle, wtitle, ahk_id %hwnd%
	Return wtitle
}

WinGetClass( hwnd )
{
	WinGetClass, wclass, ahk_id %hwnd%
	Return wclass
}

SetWinEventHook(eventMin, eventMax, hmodWinEventProc, lpfnWinEventProc, idProcess, idThread, dwFlags) 
{
	DllCall("CoInitialize", Uint, 0)
	return DllCall("SetWinEventHook"
	, Uint,eventMin	
	, Uint,eventMax	
	, Uint,hmodWinEventProc
	, Uint,lpfnWinEventProc
	, Uint,idProcess
	, Uint,idThread
	, Uint,dwFlags)	
}

NewHook()
{
	Global
	
	If HookSelected = 1
	{
		LV_GetText( SelHwnd, LV_GetNext(0, "Focused") )
		WinGet, idProcess, PID, ahk_id %SelHwnd% 
		If idProcess =
		{
			Menu, Ctx, ToggleCheck, &Receive events from this process only
			HookSelected := !HookSelected
			Return
		}
	}
	Else
	{
		idProcess = 0 ; hook all
	}
	UnhookWinEvent() 
	HookProcAdr := RegisterCallback( "HookProc", "F" ) ; new hook 
	hWinEventHook := SetWinEventHook( 0x1, 0x17, 0, HookProcAdr, idProcess, 0, dwFlags )	
}

UnhookWinEvent()
{
	Global
	DllCall( "UnhookWinEvent", Uint,hWinEventHook )
	DllCall( "GlobalFree", UInt,&HookProcAdr ) ; free up allocated memory for RegisterCallback
}

GuiContextMenu:
Menu, Ctx, Add, &Receive events from this process only, HookMode
Menu, Ctx, Show
Return

HookMode:
Menu, Ctx, ToggleCheck, &Receive events from this process only
HookSelected := !HookSelected
NewHook()
Return

GuiSize:
GuiControl, Move, Data, w%A_GuiWidth% h%A_GuiHeight%
SendMessage, WM_VSCROLL, SB_BOTTOM, 0, SysListView321, ahk_id %ahk%
Return

GuiClose:
GuiEscape:
ExitApp
Return

#IfWinActive WinEventHook Messages
	C::LV_Delete()
	
	P::
	Pause :=! Pause, WinTitle := ( Pause = 0 ? Title : Title . " (Paused)" )
	WinSetTitle %WinTitle%
	Return
	
	R::Reload
	X::ExitApp	
	
	^C::
	Clipboard = 
	Loop, % LV_GetCount("Col")
	{
		LV_GetText( lv%A_Index%, LV_GetNext(0, "Focused"), A_Index ) 
		Clipboard .= lv%A_Index% . ( A_Index != LV_GetCount("Col") ? "|" : "" )
	}
	Return
#IfWinActive

; Event Constants
EVENT_SYSTEM_SOUND = 0x1
EVENT_SYSTEM_ALERT = 0x2
EVENT_SYSTEM_FOREGROUND = 0x3
EVENT_SYSTEM_MENUSTART = 0x4 
EVENT_SYSTEM_MENUEND = 0x5
EVENT_SYSTEM_MENUPOPUPSTART = 0x6
EVENT_SYSTEM_MENUPOPUPEND = 0x7
EVENT_SYSTEM_CAPTURESTART = 0x8
EVENT_SYSTEM_CAPTUREEND = 0x9
EVENT_SYSTEM_MOVESIZESTART = 0xa
EVENT_SYSTEM_MOVESIZEEND = 0xb
EVENT_SYSTEM_CONTEXTHELPSTART = 0xc
EVENT_SYSTEM_CONTEXTHELPEND = 0xd
EVENT_SYSTEM_DRAGDROPSTART = 0xe
EVENT_SYSTEM_DRAGDROPEND = 0xf
EVENT_SYSTEM_DIALOGSTART = 0x10
EVENT_SYSTEM_DIALOGEND = 0x11
EVENT_SYSTEM_SCROLLINGSTART = 0x12
EVENT_SYSTEM_SCROLLINGEND = 0x13
EVENT_SYSTEM_SWITCHSTART = 0x14
EVENT_SYSTEM_SWITCHEND = 0x15
EVENT_SYSTEM_MINIMIZESTART = 0x16
EVENT_SYSTEM_MINIMIZEEND = 0x17