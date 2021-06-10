<cfscript>
contentObj = createObject("component", "clikpage.contentObj").init("menu");
contentObj.debug = true;


menu = contentObj.new(id="menu",title="menu",type="menu");
writeDump(menu);
writeOutput("<pre>" & contentObj.css(menu) & "</pre>");

html=contentObj.html(menu);
writeOutput( HTMLEditFormat(contentObj.wrapHTML(content=menu,html = html)));

content = contentObj.getPageContent(menu,true)
writeDump(content);
</cfscript>