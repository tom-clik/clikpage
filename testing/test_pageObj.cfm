<cfscript>
/*

# test_pageObject

Sratchpad test for pageObject

*/

pageObj = createObject("component", "publishing.pageObj").init(debug=1);

// add to default content
pageObj.addLink(pageObj.content,"icon","/favicon.ico","image/x-icon");
pageObj.addMeta(pageObj.content,"rating","very good");

content = pageObj.getContent();

content.static_js["datatables"] = 1;

pageObj.addLink(content,"license","free_for_anybody.html");
pageObj.addMeta(content,"og:title","Open graph title","property");

pageObj.addCss(content,"adhocstyle.css");

content.title = "my test page";
content.onready &= "alert('Hello world');";

content.body = "this is my page content";

writeDump(content)
writeOutput("<pre>");
writeOutput(htmlEditFormat(pageObj.buildPage(content)));
writeOutput("</pre>");
</cfscript>
