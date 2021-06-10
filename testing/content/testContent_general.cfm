<cfscript>
contentObj = createObject("component", "clikpage.contentObj").init("general");
contentObj.debug = true;


text = contentObj.new(id="text",title="General",content="<p>hello world</p>",image="//d2033d905cppg6.cloudfront.net/tompeer/images/Graphic_111.jpg",caption="lorem ipsum");
writeDump(text);
writeOutput("<pre>" & contentObj.css(text) & "</pre>");

html=contentObj.html(text);
writeOutput( HTMLEditFormat(contentObj.wrapHTML(content=text,html = html)));

text.settings.align = "left";
text.settings.imagewidth = "66%";
writeOutput("<pre>" & contentObj.css(text) & "</pre>");

writeDump(text);

html=contentObj.html(text);
writeOutput( HTMLEditFormat(contentObj.wrapHTML(content=text,html = html)));


</cfscript>