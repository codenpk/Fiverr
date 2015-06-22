#SingleInstance, force
#Persistent

str = batch|claim_no|invoice|invoice_date|date_received|treatment_date|member_no|name|policy_holder|company|plan_fund_name|claim_nature|msp|diagnosis|captured_by|capture_date|assessor|cheque_no|remarks|policy_start_date|policy_end_date|approved_date|payment_date|currency|status|sid
str2 = invoice_amt|aproved_amt|rejected_amt|defered_amt|invoice_amt1|approved_amt1|rejected_amt1|defered_amt1
str3 = treatment_date_invoice_diff|treatment_date_received_diff

;<TableColumn id="batch" minWidth="100.0" prefWidth="75.0" text="Batch" />
code=
loop, parse, str, `|
{
	txt := cammelCase(A_LoopField)
	cd = String _%A_LoopField% = rs.getString("%a_loopfield%");
	code .= (code = "" ? cd : "`n" cd)
}
loop, parse, str2, `|
{
	txt := cammelCase(A_LoopField)
	cd = double _%A_LoopField% = Double.parseDouble(rs.getString("%a_loopfield%"));
	code .= (code = "" ? cd : "`n" cd)
}
loop, parse, str3, `|
{
	txt := cammelCase(A_LoopField)
	cd = int _%A_LoopField% = Integer.parseInt(rs.getString("%a_loopfield%"));
	code .= (code = "" ? cd : "`n" cd)
}

xstr = %str%|%str2%|%str3%
code .= "`ntableData.add(new reportInvoices("
xcd =
loop, parse, xstr, `|
	xcd .= (xcd = "" ? "_" A_LoopField : ",_" A_LoopField)
code .= xcd "));"
Clipboard := code
MsgBox % code
ExitApp

/*
		TableColumn<reportInvoices, String> batch = new TableColumn<>("Batch Number");
		batch.setMinWidth(300.0);
		batch.setCellValueFactory(new PropertyValueFactory<>("batch"));
*/
/*
code=
loop, parse, str, `|
{
	word := A_LoopField
	StringReplace,word2,word,_,%a_space%,all
	wordName := cammelCase(word2)
	codeStr = TableColumn<reportInvoices, String> %word% = new TableColumn<>("%wordName%");`n%word%.setMinWidth(300.0);`n%word%.setCellValueFactory(new PropertyValueFactory<>("%word%"));
	code .= (code = "" ? codeStr : "`n`n" codeStr)
}
loop, parse, str2, `|
{
	word := A_LoopField
	StringReplace,word2,word,_,%a_space%,all
	wordName := cammelCase(word2)
	codeStr = TableColumn<reportInvoices, Double> %word% = new TableColumn<>("%wordName%");`n%word%.setMinWidth(300.0);`n%word%.setCellValueFactory(new PropertyValueFactory<>("%word%"));
	code .= (code = "" ? codeStr : "`n`n" codeStr)
}
loop, parse, str3, `|
{
	word := A_LoopField ;batch
	StringReplace,word2,word,_,%a_space%,all
	wordName := cammelCase(word2)
	codeStr = TableColumn<reportInvoices, Integer> %word% = new TableColumn<>("%wordName%");`n%word%.setMinWidth(300.0);`n%word%.setCellValueFactory(new PropertyValueFactory<>("%word%"));
	code .= (code = "" ? codeStr : "`n`n" codeStr)
}
Clipboard := code
MsgBox % code
*/

ExitApp

cammelCase(str){
	StringReplace,str,str,_,%a_space%,all
	;this is a goat
	fstr=
	loop, parse, str, %a_space%
	{
		word := A_LoopField ;this
		wordLen := StrLen(word) ;4
		StringMid,firstChar,word,1,1 ;t
		if wordLen > 1
		{
			otherCharsCount := wordLen - 1 ;3
			StringMid,otherChars,word,2,%otherCharsCount% ;his
		}
		StringUpper,firstChar,firstChar ;T
		word2 := (wordLen > 1 ? firstChar otherChars : firstChar) ;This
		fstr .= (fstr = "" ? word2 : " " word2) ;This...
	}
	return fstr ;This Is A Goat
}