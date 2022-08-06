<cfscript>
settingsObj = new clikpage.settings.settingsObj(debug=1);
contentObj = new clikpage.content.contentObj(settingsObj=settingsObj);

styles = settingsObj.loadStyleSheet(ExpandPath("../styles/testStyles.xml"));
contentObj.debug = 1;

function testCS(required struct cs) {
	
	contentObj.settings(arguments.cs,styles);

	writeDump(arguments.cs.settings);

	displayCSS(arguments.cs);

	local.html=contentObj.html(arguments.cs);

	writeOutput( HTMLEditFormat(contentObj.wrapHTML(content=arguments.cs,html = local.html)));

	local.content = contentObj.getPageContent(arguments.cs,true);
	writeDump(local.content);
	
}



function displayCSS(required struct cs) {
	writeOutput("<pre>" & settingsObj.outputFormat(css=contentObj.css(arguments.cs,styles.media),styles=styles) & "</pre>");
}

</cfscript>