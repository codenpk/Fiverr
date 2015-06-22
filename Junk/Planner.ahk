#SingleInstance, force
#Persistent
#NoEnv

;create UI
Gui, Add, GroupBox, x2 y0 w320 h370 , Current Tasks
Gui, Add, ListView, x12 y20 w300 h340 , ListView
Gui, Add, GroupBox, x332 y0 w230 h360 , Control
Gui, Add, Text, x342 y20 w60 h20 , Task
Gui, Add, Edit, x402 y20 w150 h20 , Edit
Gui, Add, Text, x342 y50 w60 h20 , Description
Gui, Add, Edit, x402 y50 w150 h160 , Edit
Gui, Add, Text, x342 y220 w60 h20 , Due time
Gui, Add, Edit, x402 y220 w150 h20 , Edit
Gui, Add, Text, x342 y250 w60 h20 , Due Date
Gui, Add, DateTime, x402 y250 w150 h20 , 
Gui, Add, Button, x342 y320 w100 h30 , Update
Gui, Add, Button, x452 y320 w100 h30 , New
Gui, Show, w575 h379, Planner
return

GuiClose:
ExitApp