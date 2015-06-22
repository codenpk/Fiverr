#SingleInstance, force
#Persistent

Gui Add, ActiveX, w980 h640 vWB, Shell.Explorer
WB.Navigate("C:\Users\mthuku\Downloads\Command Builder 0.0.4 (offline)\Command Builder 0.0.4 offline\commandBuilder.html")
Gui Show
return

ahkFunction(){
    msgbox Hello, world!
}