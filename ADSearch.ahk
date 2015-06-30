#SingleInstance, force
#Persistent

getUserNames(){
	cu := ComObjCreate("ADSystemInfo")
	user := cu.UserName
	MsgBox % user
}