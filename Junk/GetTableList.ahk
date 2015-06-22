#SingleInstance, force
#Persistent
list =  BATCH|CLAIM NO|INVOICE|INVOICE DATE|DATE RECEIVED|TREATMENT DATE|TREATMENT-INVOICE|TREATMENT-RECEIVED|MEMBER NO|NAME|POLICY HOLDER|COMPANY|PLAN FUND NAME|CLAIM NATURE|MSP|DIAGNOSIS|SERVICE TYPE|CPT|QTY|CAPTURED BY|CAPTURE DATE|INVOICE AMT|APPROVED AMT|REJECTED AMT|DEFERED AMT|INVOICE AMT1|APPROVED AMT1|REJECTED AMT1|DEFERED AMT1|REASON|PAY FROM REMARKS|ASSESSOR|CHEQUE NO|REMARKS|POLICY START DATE|POLICY END DATE|APPROVED DATE|PAYMENT DATE|CURRENCY|STATUS|SID|ID
code=
loop, parse, list, `|
{
	v := toVar(A_LoopField)
	c = <TableColumn text="%A_LoopField%"><cellValueFactory><PropertyValueFactory property="%v%" /></cellValueFactory></TableColumn>
	code .= (code=""? c : "`n" c)
}
MsgBox complete!
Clipboard := code
ExitApp
	
toVar(str){
	StringLower,str,str
	StringReplace,str,str,%a_space%,_,all
	StringReplace,str,str,`-,_,all
	return str
}