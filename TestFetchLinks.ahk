#SingleInstance, force
#Persistent

text=
(
I just want to load this link 'http://www.strikebuys.com/wp-admin/options-general.php?page=pvd-settings&pvd_manual=2a60fe9273231b423c508c348edb861c2db55020' so that the my Post via Dropbox plugin gets run.

The plugin is https://wordpress.org/plugins/post-via-dropbox/.
The plugin is https://wordpress.org/plugins/post-via-dropboxs.
The plugin is https://wordpress.org/plugins/post-via-dropbox/.

I mean, when I load the link 'https://www.strikebuys.com/wp-admin/options-general.php?page=pvd-settings&pvd_manual=2a60fe9273231b423c508c348edb861c2db55020', the scanning gets down and publishes my posts.
I mean, when I load the link 'https://www.strikebuys.com/wp-admin/options-general.php?page=pvd-settings&pvd_manual=2a60fe9273231b423c508c348edb861c2db55020', the scanning gets down and publishes my posts.

I just want to load 'http://www.strikebuys.com/wp-admin/options-general.php?page=pvd-settings&pvd_manual=2a60fe9273231b423c508c348edb861c2db55020 in background without opening the page on browser. :)
)

MsgBox % fetchLinks(text)
ExitApp

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