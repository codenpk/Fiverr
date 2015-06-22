;we force the app to run on a single instance
#SingleInstance,force
#Persistent


;we add a listener for the keys to ensure their states are not pressed so that we can keep the mic off
SetTimer,mic_check,1
return

mic_check:
;add keys to monitor for push to talk
GetKeyState,state1,RAlt 
GetKeyState,state2,XButton1
GetKeyState,state3,2Joy9 ;i dont know about this key never used a joystick before test if its working
pressedKeys = %state1%`,%state2%`,%state3%`,%state4%
if pressedKeys contains D ;meas one of the states is pressed "D" for down
{
	;this means the either of the above keys is pressed and the mic should be ON
	SoundSet, 0, MICROPHONE, MUTE, 4
}
else ;else we keep the mic OFF
	SoundSet, 1, MICROPHONE, MUTE, 4
return
