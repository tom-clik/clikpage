<cfscript>

path = ExpandPath("../site/preview/config_main.json");
fileData = fileRead(path );
config = deserializeJSON(fileData);
debug = 1;
outPath = "_out/";
outDir = ExpandPath(outPath);

// Style definition -- see link to css file ibid.
// settingsDef = ExpandPath("../styles/testStyles.xml");

settingsObj = new clikpage.settings.settings(debug=debug);
contentObj = new clikpage.content.content(settingsObj=settingsObj,debug=debug);


styles = {};
settingsObj.loadStyleSheet(expandPath("../css/_styles/test_settings.scss"), styles);

// writeDump(styles.style);

colorCss = ":root {" & newLine() &  settingsObj.colorVariablesCSS(styles=styles) & "}";
colorCss = settingsObj.outputFormat(
	css=colorCss,
	media=styles.media,
	debug=contentObj.debug
);

FileWrite(outPath & "colors.css",colorCss);

pageObj = new clikpage.page(debug=debug);

function testCS(required struct cs) {
	
	try {
		
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

	page = pageObj.getContent();
	contentObj.addPageContent(page, local.cs.pagecontent);
	pageObj.addJs(page,"clik_onready");

	writeOutput( HTMLEditFormat(local.cs.html));
	
	writeDump(var=local.cs.pagecontent,label="Page content");

	local.static = staticContent(page);


	writeOutput("<h2>Static links</h2>");
	writeOutput("<pre>" & HTMLEditFormat( local.static.js )  & HTMLEditFormat( local.static.css ) &"</pre>");

	local.js = "
	<script>
	$(document).ready(function() {
		#page.onready#
	});
	</script>
	";
	FileWrite(outPath & arguments.cs.type & ".html",samplepage(arguments.cs,local.cs.html,local.static,local.js));
}

/**
 * @hint Generate complete css file using contentCSS() method
 *
 * This just calls css() for the single content section and applies the media queries.
 */
function CSS(required struct cs) {

	local.debugcontent = {};

	local.content_sections = { "#arguments.cs.id#" = arguments.cs };

	// css =  contentObj.CSS(styles=styles, content=arguments.cs,debugcontent=local.debugcontent);
	// writeDump(styles);
	// writeDump(local.debugcontent);
	// writeDump(css);
	// abort;
	return contentObj.contentCSS(styles=styles, content_sections=local.content_sections);

}

function staticContent(required struct pagecontent) {
	
	var page = {};
	
	page["css"] = pageObj.cssStaticFiles.getLinks(arguments.pagecontent.static_css,1);
	page["js"] = pageObj.jsStaticFiles.getLinks(arguments.pagecontent.static_js,1);
	return page;
	
}

function samplepage(cs,html,static,js) {
	var page = "<html><head><title>#arguments.cs.type# test</title>";
	page &= "<link rel='stylesheet' href='/_assets/css/reset.css'>";
	page &= static.css;
	page &= "<link rel='stylesheet' href='colors.css'>";
	page &= "<link rel='stylesheet' href='#arguments.cs.type#.css'>";
	page &= "</head><body><div class='containerXXX' style='heightXXX:100%;padding:20px;'>";
	page &= html;
	page &= static.js;
	page &= arguments.js;
	page &= "</div></body>";
	return page;
}

</cfscript>