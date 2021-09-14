<cfscript>
/** 

Scratchpad for testing Flexmark parser

## Configuration

Each plugin has an equivalent testing file and expected result in the markdown folder.

## Usage

Define the tests to run, ensure there is a markdown source and expected result file and then preview.

*/


tests = ['definition','attributes','footnote','abbreviation','admonition','autolink'];

// we run all html through jsoup parse so we get a better comparison

jsoup = createObject( "java", "org.jsoup.Jsoup" );

for (test in tests) {
	
	myrenderer = createObject( "java", "Flexmark" ).init("#test#");
	mytext = FileRead(ExpandPath("#test#.md"),"utf-8");
	myresult = jsoup.parse(trim(FileRead(ExpandPath("#test#.html"),"utf-8"))).body().html();
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


