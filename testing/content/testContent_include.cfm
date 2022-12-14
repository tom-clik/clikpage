<cfscript>

path = ExpandPath("../site/preview/config.json");
fileData = fileRead(path );
config = deserializeJSON(fileData);
siteObj = new clikpage.site.site(layoutsFolder=config.layoutsFolder,mode="live");
siteObj.debug = true;

site = siteObj.loadSite(config.siteDef);

settingsObj = new clikpage.settings.settings(debug=1);
contentObj = new clikpage.content.content(settingsObj=settingsObj);

pageObjOk = 1;
try {
	pageObj = new clikpage.page(debug=1);
}
catch (any e) {
	pageObjOk = 0;
}

styles = settingsObj.loadStyleSheet(ExpandPath("../styles/testStyles.xml"));
contentObj.debug = 1;

function testCS(required struct cs, boolean getSettings=1) {
	
	try {
		if (arguments.getSettings) {
			contentObj.settings(arguments.cs,styles.content,styles.media);
		}		
		writeDump(var=arguments.cs.settings,label="settings");
		displayCSS(arguments.cs);
		param name="request.data" type="struct" default={};

		local.cs = contentObj.display(content=arguments.cs,data=request.data);
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

	staticContent(local.cs.pagecontent);
}

function displayCSS(required struct cs) {
	local.site_data = { "#arguments.cs.id#" = arguments.cs};
	
	local.css = contentObj.contentCSS(styles=styles, content_sections=local.site_data, media=styles.media, loadsettings=0);

	writeOutput("<pre>" & local.css & "</pre>");
}

function staticContent(required struct pagecontent) {
	if (pageObjOk) {
		var page = "";
		writeDump(arguments.pagecontent);
		page &= pageObj.cssStaticFiles.getLinks(arguments.pagecontent.static_css,1);
		page &= pageObj.jsStaticFiles.getLinks(arguments.pagecontent.static_js,1);

		writeOutput("<h2>Static links</h2>");
		writeOutput("<pre>" & HTMLEditFormat( page ) & "</pre>");

	}
}

</cfscript>