<cfscript>
contentObj = createObject("component", "clikpage.contentObj").init("imagegrid");
contentObj.debug = true;


image = contentObj.new(id="imagegrid",title="imagegrid",type="imagegrid");
writeDump(image);
writeOutput("<pre>" & contentObj.css(image) & "</pre>");

html=contentObj.html(image);
writeOutput( HTMLEditFormat(contentObj.wrapHTML(content=image,html = html)));

content = contentObj.getPageContent(image,true)
writeDump(content);
</cfscript>