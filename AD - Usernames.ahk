#SingleInstance, force
#Persistent

#include COM.ahk

COM_CoInitialize()
oInfo:=COM_CreateObject("ADSystemInfo")
LDAPUsr:=COM_GetObject("LDAP://" UserName:=COM_Invoke(oInfo,A_UserName))
MsgBox	%	COM_Invoke(LDAPUsr,"physicalDeliveryOfficeName")
MsgBox	%	COM_Invoke(LDAPUsr,"sAMAccountName")
MsgBox	%	COM_Invoke(LDAPUsr,"department")
MsgBox	%	COM_Invoke(LDAPUsr,"mail")
MsgBox	%	UserName
COM_CoUninitialize()
ExitApp