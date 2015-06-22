;==========================================================================
;	MONITORING SOFTWARE FOR KEYWORDS 
;	CREATED BY MARTINTHUKU 	http://fiverr.com/martinthuku
;	COPYRIGHT (C) 2015 pumilamac
;==========================================================================

#SingleInstance, force ;ensures that only one isntance of this script is running
#Persistent ;makes sure that the application continues running. Recommended
#NoEnv ;recommended for performance

;these are the global variables
config = %A_ScriptDir%\Config.ini ;this is our config.ini and we shall have it in the same location as the script
app = KeyWord Listener ;the name of this application
email=xthukuh@gmail.com ;email to receive the screenshot

;first we load the user settings from the config.ini
IfNotExist,% config ;we check if we have our config file
{
FileAppend, ;since there is no config file, we generate default settings and create the config.ini
(
[main]
applicationtitle=PrintQueue 1.98.4
applicationcontrol=WindowsForms10.LISTBOX.app.0.2bf8098_r11_ad11
keywords=Unable to write data to the transport connection
sleep=1000
[smtp]
smtpserver=smtp.gmail.com
smtpserverport=465
smtpusessl=True
sendusing=2
smtpauthenticate=1
sendusername=xthukuh@gmail.com
sendpassword=
smtpconnectiontimeout=60
schema=http://schemas.microsoft.com/cdo/configuration/
), %config%
}

;we attempt reading the config.ini
;get the main cofigurations
IniRead,applicationtitle,%config%,main,applicationtitle
IniRead,applicationcontrol,%config%,main,applicationcontrol
IniRead,keywords,%config%,main,keywords
IniRead,sleep,%config%,main,sleep ;see listener subroutine

;get email smtp configurations
IniRead,smtpserver,%config%,smtp,smtpserver
IniRead,smtpserverport,%config%,smtp,smtpserverport
IniRead,smtpusessl,%config%,smtp,smtpusessl
IniRead,sendusing,%config%,smtp,sendusing
IniRead,smtpauthenticate,%config%,smtp,smtpauthenticate
IniRead,sendusername,%config%,smtp,sendusername
IniRead,sendpassword,%config%,smtp,sendpassword
IniRead,smtpconnectiontimeout,%config%,smtp,smtpconnectiontimeout
IniRead,schema,%config%,smtp,schema

;we need to test the data so that we ensure we had a successiful settings read
testString := applicationtitle "," applicationcontrol "," keywords "," sleep "," smtpserver "," smtpserverport "," smtpusessl "," sendusing "," smtpauthenticate "," sendusername "," sendpassword "," smtpconnectiontimeout "," schema ;we have loaded all read data to this string. If there was an error, a variable will contain ERROR
if testString contains ERROR ;test if we have an error in any of the variables
{
	MsgBox % teststring
	MsgBox, 4112, %app%, There was a problem reading the configuration file. Please change your settings`, default settings have been loaded. ;prompt message
	FileDelete, % config ;remove the corrupt config.ini
	Reload ;reload - remember that it will create a default config file if there is no config file (we have removed it)
}


;since the script is a listener, there will be no constant window hence we use the traymenu (the bottom right corner icons on the taskbar) icons to interract with the script
;we make the traymenu right click menu options
Menu, tray, nodefault ;remove autohotkey default traymenu options
Menu, tray, nostandard ;remove autohotkey standard traymenu options
menu, tray, add, Settings, config ;settings option - calls config subroutine see subroutines.ahk in resources folder
Menu, pausemenu, add, Pause, pause ;we need to be able to pause the listener
Menu, pausemenu, add, Resume, resume ;we need to be able to resume the listener after pause
Menu, tray, add, Pause / Resume Listener, :pausemenu ;add the pause / resume menu to the tray menu
menu, tray, add, ;adds a separator
Menu, tray, add, Reload Script, reload ;reload script option - calls reload subroutine see subroutines.ahk in resources folder
Menu, tray, add, Exit Script, exit ;exit script option - calls exit subroutine see subroutines.ahk in resources folder

;since this script loads GDIP, we need to attempt to close it once we are done
;this means that we shall have to know when this script is closing and call a subroutine - isclosing
OnExit, isclosing ;calls isclosing whenever we are exiting the application  - see subroutines.ahk in resources folder
SetTimer, listen, 30 ;calls the listener every 30 milliseconds so that we can listen for the keywords - see subroutines.ahk in resources folder
return ;we are done here. All other functions are loaded and implemented on subroutines.ahk in resources folder


;files that are joined with this script
#Include resources/subroutines.ahk