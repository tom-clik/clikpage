<cfscript>
contentObj = createObject("component", "clikpage.contentObj").init("image");
contentObj.debug = true;


image = contentObj.new(id="image",title="image",type="image",image="http://localpreview.clikpic.com/sampleimages/nate-johnston-cK_1Q_e5FfU-unsplash.jpg",caption="My caption");
writeDump(image);
writeOutput("<pre>" & contentObj.css(image) & "</pre>");

html=contentObj.html(image);
writeOutput( HTMLEditFormat(contentObj.wrapHTML(content=image,html = html)));

content = contentObj.getPageContent(image,true)
writeDump(content);
</cfscript>