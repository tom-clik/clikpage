<cfscript>
tests = ['definition','attributes','footnote','abbreviation','admonition','autolink'];


jsoup = createObject( "java", "org.jsoup.Jsoup" );

for (test in tests) {
	myrenderer = createObject( "java", "Flexmark" ).init("#test#");
	mytext = FileRead(ExpandPath("markdown/#test#.md"),"utf-8");
	myresult = jsoup.parse(trim(FileRead(ExpandPath("markdown/#test#.html"),"utf-8"))).body().html();
	start = getTickCount();
	raw = myrenderer.render(mytext);
	outhtml = jsoup.parse(trim(raw)).body().html();
	
	if (myresult != outhtml) {
		writeOutput("<p>#test# Failed</p>");
		writeOutput("<pre>#htmlEditFormat(outhtml)#</pre>");
		writeOutput("<pre>#htmlEditFormat(myresult)#</pre>");
	}
	else {
		end = getTickCount() - start;
		writeOutput("<pre>#htmlEditFormat(outhtml)#</pre>");
		writeOutput("<p>#test# Rendered in #end# ms</p>");
	}

}
</cfscript>


