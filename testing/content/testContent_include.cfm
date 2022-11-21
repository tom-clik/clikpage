<cfscript>
settingsObj = new clikpage.settings.settings(debug=1);
contentObj = new clikpage.content.content(settingsObj=settingsObj);

styles = settingsObj.loadStyleSheet(ExpandPath("../styles/testStyles.xml"));
contentObj.debug = 1;

function testCS(required struct cs, boolean getSettings=1) {
	
	try {
		if (arguments.getSettings) {
			contentObj.settings(arguments.cs,styles);
		}
		
		writeDump(var=arguments.cs.settings,label="settings");
		displayCSS(arguments.cs);
		local.cs = contentObj.display(content=arguments.cs);
	}
	catch (any e) {
		local.extendedinfo = {"tagcontext"=e.tagcontext,"cs"=arguments.cs};
		throw(
			extendedinfo = SerializeJSON(local.extendedinfo),
			message      = "Unable to display cs:" & e.message, 
			detail       = e.detail
		);
	}

	

	writeOutput( HTMLEditFormat(local.cs.html));
	writeDump(var=local.cs.pagecontent,label="Page content");
}


function displayCSS(required struct cs) {
	writeOutput("<pre>" & settingsObj.outputFormat(css=contentObj.css(arguments.cs),styles=styles) & "</pre>");
}

</cfscript>