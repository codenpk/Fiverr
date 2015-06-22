#SingleInstance, force
#Persistent

^B:: ;Ctrl+B For Multiple links
clip := Clipboard
links := fetchLinks(clip)
loop, parse, links,`n
{
	newlink := appendLink(A_LoopField)
	StringReplace,clip,clip,%a_loopfield%,%newlink%,all
}
Clipboard := clip
return


fetchLinks(haystack){
	plink =
	links =
	p = 0
	loop
	{
		n := p + StrLen(plink) + 1
		p := RegExMatch(haystack, "(https?://|www\.)[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(/\S*[^\.\'\?\\\s\,\?])?", link, n)
		if p = 0
			break
		links .= (links = "" ? link : "`n" link)
		plink = %link%
	}
	Sort, links, U D`n
	return links
}


appendLink(lnk){
	if lnk contains flipkart,amazon
	{
		if lnk contains flipkart
		{
			if lnk contains ?
				lnk .= "&affid=flipkarto15"
			else
				lnk .= "?affid=flipkarto15"
		}
		/*
		;you can add other domains here if you want :) - Amazon was a bit tricky
		else
		if lnk contains shopclues
		{
			if clip contains ?
				lnk .= "&xxxx=xxxxx"
			else
				lnk .= "?xxxxx=xxxxx"
		}
		*/
		else
		{
			if lnk contains amazon
			{
				StringReplace, testamazon, clip, amazon.com, sjdhkjgfhsdkjtyerut974357434, all
				if testamazon contains sjdhkjgfhsdkjtyerut974357434 ;.com
				{
					if lnk contains ?
						lnk .= "&tag=amazoncus-20"
					else
						lnk .= "?tag=amazoncus-20"
				}
				else ;.in
				{
					if lnk contains ?
						lnk .= "&tag=amazonph-21"
					else
						lnk .= "?tag=amazonph-21"
				}
			}
		}
	}
	return lnk
}