<cfscript>
settingsObj = CreateObject("component", "clikpage.settings.settingsObj").init(debug=1);
contentObj = CreateObject("component", "clikpage.content.contentObj").init(settingsObj=settingsObj);

contentObj.debug = true;

styles = settingsObj.loadStyleSheet(ExpandPath("./testStyles.xml"));

columnsObj = new clikpage.content.columns(contentObj=contentObj);

body = contentObj.new(id="ubercontainer",title="Site layout",type="text",content="Dummy columns cs");

media = settingsObj.getMedia(styles);
css = layoutsCSS(media,styles)

writeOutput("<pre>" & settingsObj.outputFormat(css,styles) & "</pre>");

function layoutsCSS(media=media,styles=styles) {
	
	var css;

	for (var medium in arguments.media ) {
		var section_css = "";
		for (var id in arguments.styles.layouts) {
			var layout = arguments.styles.layouts[id];
			if ((medium EQ "main") OR (StructKeyExists(layout, medium))) {
				local.settings = medium EQ "main" ? layout : layout[medium];
				section_css &= columnsObj.css("body.template-#id#",local.settings);
			}	
		}
		css &= "/* CSS for #medium# */\n";
		if (section_css NEQ "") {
			if (medium NEQ "main") {
				css &= "@media.#medium# {\n " & section_css & "\n}\n";
			}
			else {
				css &= section_css;
			}
		}
	}
	return css;
}


</cfscript>


