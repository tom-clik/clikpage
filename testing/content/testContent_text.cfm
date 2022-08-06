<cfscript>
cfinclude(template="testContent_include.cfm");


text = contentObj.new(id="text",title="text",type="text",content="Just plain text");

contentObj.settings(text,styles);

writeDump(text);
writeOutput("<pre>" & contentObj.css(text,styles.media) & "</pre>");

css=contentObj.css(text);
writeOutput( HTMLEditFormat(css));

html=contentObj.html(text);
writeOutput( HTMLEditFormat(contentObj.wrapHTML(content=text,html = html)));

content = contentObj.getPageContent(text,true)
writeDump(content);
</cfscript>