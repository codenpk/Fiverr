#SingleInstance,force
#Persistent
#Include Functions.ahk ; I have added the functions we will use here. Some of these functions are not made by me.

current_date := add_days() ;we get the current date. add_day() without parameters returns the current date
run_date := add_days(current_date,-4) ;we get the run_date
run_date_month := SubStr(run_date, 4, 2) ;we get the month of the run date
run_date_year := SubStr(run_date, 7, 4) ;we get the year of the run date
s_first_day := "01/" run_date_month "/" run_date_year ;we get the Send first day - dd/MM/yyyy
s_last_day := month_days(run_date_month) "/" run_date_month "/" run_date_year ;we get the Send last day dd/MM/yyyy


;we now convert the dates we have to MM/DD/YY
current_date := DateParse(current_date) ;to change dd/MM/yyyy to yyyyMMdd
FormatTime,current_date,%current_date%,MM-dd-yy ;to change yyyy/MM/dd to MM-dd-yy

run_date := DateParse(run_date)
FormatTime,run_date,%run_date%,MM-dd-yy

s_first_day := DateParse(s_first_day)
FormatTime,s_first_day,%s_first_day%,MM-dd-yy

s_last_day := DateParse(s_last_day)
FormatTime,s_last_day,%s_last_day%,MM-dd-yy

;Now we output the results
msg =
(
Converted to MM/DD/YY :)
For example if the current date is %current_date%
Run date is %run_date%
Send first day is %s_first_day%
Send last day is %s_last_day%
)
MsgBox % msg
ExitApp ;we dont want to keep the app running since there is no way of interracting with it after the msgbox
