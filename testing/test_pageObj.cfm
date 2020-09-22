<!---

# test_pageObject

--->
<cfscript>

pageObj = createObject("component", "publishing.pageObj").init(debug=1);

content = pageObj.getContent();
writeDump(content)
writeOutput("<pre;>");
writeOutput(htmlEditFormat(pageObj.buildPage(content)));
writeOutput("</pre>");
</cfscript>
