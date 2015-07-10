#SingleInstance, force
#Persistent

if a_hour < 12
	msg = Good morning
if (a_hour >= 12 And a_hour < 18)
	msg = Good afternoon
if (a_hour >= 18 And a_hour < 24)
	msg = Good night

cu := ComObjCreate("ADSystemInfo")
userdetails := cu.UserName ;load of string info
usernames := getValue("CN",userdetails) ;Martin Thuku
loop, parse, usernames, %a_space%
	if a_index = 1
		firstname = %A_LoopField% ;Martin
MsgBox % msg " " firstname
ExitApp

getValue(key,str){
	value=
	loop, parse, str, `,
	{
		loop, parse, a_loopfield, `=
		{
			if a_index = 1
				key2= %A_LoopField%
			if a_index = 2
				value = %A_LoopField%
		}
		if key2 = %key%
			break
	}
	return value
}