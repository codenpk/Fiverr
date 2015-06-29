#SingleInstance,force
#Persistent
;#NoTrayIcon ;uncomment this if you want to remove the tray icon

SetTitleMatchMode,2 ;this makes sure what when we want to search for a window title, it searches for the title that contains the words we want
#IfWinActive,Word ;you can comment this out but this ensures that we disable the backspace to only windows with the word "Word" in the title. See line 16

BackSpace::

ToolTip,BackSpace Disabled ;you can comment this (up to line 12) out if you dont want to show the tooltip saying backspace disabled
sleep,200
ToolTip

return

#IfWinActive ;we release the backspace so it can work on other windows - comment this out if you didnt want it


/*
Basically the sub 

backspace:
return

disabled the backspace on all windows I just made sire that it can work on other windows except where the window contains the word "Word" in its title
*/