<cfscript>

path = ExpandPath("../site/preview/config_main.json");
fileData = fileRead(path );
config = deserializeJSON(fileData);

outPath = ExpandPath("_out/");

settingsObj = new clikpage.settings.settings(debug=1);
contentObj = new clikpage.content.content(settingsObj=settingsObj);

// Style definition -- see link to css file ibid.
settingsDef = ExpandPath("../styles/testStyles.xml");

settingsObj = new clikpage.settings.settings(debug=1);
contentObj = new clikpage.content.content(settingsObj=settingsObj);
contentObj.debug = 1;

styles = settingsObj.loadStyleSettings(settingsDef);
// writeDump(styles.style);

colorCss = ":root {" &  settingsObj.colorVariablesCSS(settings=styles,debug=false) & "}";
colorCss = settingsObj.outputFormat(
	css=colorCss,
	media=styles.media,
	debug=contentObj.debug
);

FileWrite(outPath & "colors.css",colorCss);

pageObjOk = 1;
try {
	pageObj = new clikpage.page(debug=1);
}
catch (any e) {
	pageObjOk = 0;
}

contentObj.debug = 1;

function testCS(required struct cs, boolean getSettings=1) {
	
	try {
		if (arguments.getSettings) {
			contentObj.settings(content=arguments.cs,styles=styles.style,media=styles.media);
		}		
		writeDump(var=arguments.cs.settings,label="settings");

		css = CSS(arguments.cs);
		writeOutput("<pre>" & css & "</pre>");

		
		FileWrite(outPath & arguments.cs.type & ".css",css);

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

	local.static = staticContent(local.cs.pagecontent);
	writeOutput("<h2>Static links</h2>");
	writeOutput("<pre>" & HTMLEditFormat( local.static.js )  & HTMLEditFormat( local.static.css ) &"</pre>");

	local.js = "
	<script>
	$(document).ready(function() {
		#local.cs.pagecontent.onready#
	});
	</script>
	";
	FileWrite(outPath & arguments.cs.type & ".html",samplepage(arguments.cs,local.cs.html,local.static,local.js));
}

function CSS(required struct cs) {
	local.site_data = { "#arguments.cs.id#" = arguments.cs};
	
	return contentObj.contentCSS(styles=styles, content_sections=local.site_data, media=styles.media);

	
}

function staticContent(required struct pagecontent) {
	if (pageObjOk) {
		var page = {};
		
		page["css"] = pageObj.cssStaticFiles.getLinks(arguments.pagecontent.static_css,1);
		page["js"] = pageObj.jsStaticFiles.getLinks(arguments.pagecontent.static_js,1);
		return page;

	}
}

function samplepage(cs,html,static,js) {
	var page = "<html><head><title>#arguments.cs.type# test</title>";
	page &= static.css;
	page &= "<link rel='stylesheet' href='/_assets/css/reset.css'>";
	page &= "<link rel='stylesheet' href='colors.css'>";
	page &= "<link rel='stylesheet' href='#arguments.cs.type#.css'>";
	page &= "</head><body>";
	page &= html;
	page &= static.js;
	page &= arguments.js;
	page &= "</body>";
	return page;
}

</cfscript>