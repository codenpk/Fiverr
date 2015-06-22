#SingleInstance, force
#Persistent

#!T::
WinGetActiveTitle, win
InputBox, trans, Set Transparency,,,200,100
WinSet, trans, %trans%, %win%
return