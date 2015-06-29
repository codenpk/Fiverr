;Custom Calc
;Source code made with love - Fiverr martinthuku
#SingleInstance,force
#Persistent
#NoEnv
#NoTrayIcon
SetFormat,float,20.4
Gui, Add, Text, x22 y20 w100 h20 , Bill Rate
Gui, Add, Edit, x122 y20 w120 h20 vbrate gcalc,
Gui, Add, Text, x22 y50 w100 h20 , Hours Per week
Gui, Add, Edit, x122 y50 w120 h20 vhh gcalc,
Gui, Add, Text, x22 y80 w100 h20 , Number Of Weeks
Gui, Add, Edit, x122 y80 w120 h20 vww gcalc,
Gui, Add, Text, x22 y110 w100 h20 , Hourly Pay Rate
Gui, Add, Edit, x122 y110 w120 h20 vhpr gcalc,
Gui, Add, Text, x22 y140 w100 h20 , Weekly Housing
Gui, Add, Edit, x122 y140 w120 h20 vwh gcalc,
Gui, Add, Text, x22 y170 w100 h20 , Weekly Per Diem
Gui, Add, Edit, x122 y170 w120 h20 vwpd gcalc,
Gui, Add, Text, x22 y200 w100 h30 , Total Travel Allowance
Gui, Add, Edit, x122 y200 w120 h20 vtt gcalc,
Gui, Add, Text, x22 y230 w100 h30 , Total License Reimbursement
Gui, Add, Edit, x122 y230 w120 h20 vtl gcalc,
Gui, Add, Text, x22 y260 w100 h20 , Bonus
Gui, Add, Edit, x122 y260 w120 h20 vb gcalc,
Gui, Add, GroupBox, x12 y0 w240 h290 cblack, Input Fields
Gui, Add, GroupBox, x12 y300 w240 h80 cRed, Output
Gui, Add, Text, x22 y320 w100 h20  cgreen, Weekly Profit
Gui, Add, Edit, x122 y320 w120 h20 readonly vwp,
Gui, Add, Text, x22 y350 w100 h20  cgreen, Hourly Profit
Gui, Add, Edit, x122 y350 w120 h20 readonly vhp,
Gui, Show, w270 h399, Custom Calc
return

GuiEscape:
GuiClose:
ExitApp

calc:
Gui, submit, nohide
;cleaning
brate = %brate%
hh = %hh%
ww = %ww%
hpr = %hpr%
wh = %wh%
wpd = %wpd%
tt = %tt%
tl = %tl%
b = %b%
brate := (brate=""?0:brate)
hh := (hh=""?0:hh)
ww := (ww=""?0:ww)
hpr := (hpr=""?0:hpr)
wh := (wh=""?0:wh)
wpd := (wpd=""?0:wpd)
tt := (tt=""?0:tt)
tl := (tl=""?0:tl)
b := (b=""?0:b)
total_invoice := brate * hh
gross_hp := hh * hpr
bfinancing := (gross_hp*0.165)+(0.34*hh)
benefits := ((((hpr*1.165)*40)/1040)+(hpr*0.03)+2)*hh
admin_hr := 12
on_boarding := 15
total_expenses := gross_hp+bfinancing+benefits+wh+wpd+admin_hr+on_boarding+(tt/ww)+(tl/ww)+(b/ww)
SetFormat,float,20.2
calc_wp := total_invoice-total_expenses
calc_hp := calc_wp/hh
calc_wp = %calc_wp%
calc_hp = %calc_hp%
GuiControl,,wp,% calc_wp
GuiControl,,hp,% calc_hp
return