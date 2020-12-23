<!---

# test_pageObject

## Usage

Preview to show the HTML for a simple page

Note the defaults for the pageObj include jquery.


--->
<cfscript>

pageObj = createObject("component", "publishing.pageObj").init(debug=1);

content = pageObj.getContent();
writeDump(content)
writeOutput("<pre>");
writeOutput(htmlEditFormat(pageObj.buildPage(content)));
writeOutput("</pre>");
</cfscript>
