<cfscript>
contentObj = createObject("component", "clikpage.contentObj").init();
contentObj.debug = true;

title = contentObj.new(id="sitetitle",type="title",title="Site title",content="Site title");
writeDump(title);

text = contentObj.new(id="text",title="General",content="<p>helloo world</p>",image="");
writeDump(text);


writeOutput( HTMLEditFormat(contentObj.html(title)));
writeOutput( HTMLEditFormat(contentObj.html(text)));



</cfscript>