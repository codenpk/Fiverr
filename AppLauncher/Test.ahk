#SingleInstance,force
sleep(4000)
ControlSendRaw,,THIS IS ME,A
ExitApp

sleep(time){
	SetFormat,float,10.0
	intervals := time / 1000
	n := intervals
	n = %n%
	loop,% intervals
	{
		TrayTip,AppLauncher,Waiting for %n% seconds
		Sleep,1000
		n--
	}
}