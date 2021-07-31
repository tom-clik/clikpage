<cfscript>
settingsObj = CreateObject("component", "clikpage.settings.settingsObj").init(debug=1);
contentObj = CreateObject("component", "clikpage.content.contentObj").init(settingsObj=settingsObj);
styles = settingsObj.loadStyleSheet(ExpandPath("../styles/testStyles.xml"));
contentObj.debug = 1;


function testCS(required struct cs) {
	
	contentObj.settings(arguments.cs,styles);

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