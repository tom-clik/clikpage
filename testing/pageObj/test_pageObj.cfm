<cfscript>
/*

# test_pageObject

The pageObject can just be used on its own (requires static files)

The body content is just set as a text string.

*/

pageObj = new clikpage.page(debug=1);

pageObj.addLink(pageObj.content,"icon","/favicon.ico","image/x-icon");
pageObj.addLink(content=pageObj.content,rel="preconnect",href="https://fonts.googleapis.com");
pageObj.addMeta(pageObj.content,"rating","very good");

content = pageObj.getContent();

pageObj.addJs(content,"menus");
pageObj.addCss(content,"content");
pageObj.addJs(content,"adhocstyle.js?cachebuster=234123512");
pageObj.addCss(content,"adhocstyle.css?cachebuster=234123512");
pageObj.addJs(content,"alert('Hello world')");
pageObj.addCSS(content,"myclass {color:green};");
pageObj.addLink(content,"license","free_for_anybody.html");
pageObj.addMeta(content,"og:title","Open graph title","property");

content.title = "my test page";


content.body = "this is my page content";

writeDump(content)
writeOutput("<pre>");
writeOutput(htmlEditFormat(pageObj.buildPage(content)));
writeOutput("</pre>");
</cfscript>
