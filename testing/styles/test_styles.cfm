<!---

Currently a scratchpad. Working towards a complete method for saving a stylesheet.

--->

<cfscript>

settingsObj = CreateObject("component", "clikpage.settings.settingsObj").init(debug=1);
contentObj = CreateObject("component", "clikpage.content.contentObj").init(settingsObj=settingsObj);

contentObj.debug = true;

styles = settingsObj.loadStyleSheet(ExpandPath("./testStyles.xml"));

// writeDump(styles);
// abort;

containers = containersData(styles);
media = settingsObj.getMedia(styles);

// NB these are going to be replacements for the ones in the object.
css = siteCSS(styles);
css &= containersCSS(containers,media)

WriteOutput("<pre>" & HtmlEditFormat(settingsObj.outputFormat(css,styles)) & "</pre>");

string function siteCSS(required struct media) {
	var css = "";
	css &= ":root {\n ";
	css &= settingsObj.fontVariablesCSS(styles);
	css &= settingsObj.layoutCss(styles);
	css &=  "\n}\n";
	return css;
}

string  function containersCSS(required struct containers, required struct media) {
	var css = "";

	for (var medium in arguments.media ) {
		var section_css = "";
		for (var id in arguments.containers) {
			var cs =  arguments.containers[id];
			if ((medium EQ "main") OR (StructKeyExists(cs.settings, medium))) {
				local.settings = medium EQ "main" ? cs.settings : cs.settings[medium];
				section_css &= settingsObj.containerCss(settings=local.settings,selector="###id#");
			}	
		}
		css &= "/* cSS for #medium# */\n";
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

// fake container data
struct function containersData(required struct styles) output=false {

	var containers = [
		
		"body" = {
			"id"="body"
		},
		"content" = {
			"id"="content"
		},
		"contentfooter" = {
			"id"="contentfooter"
		},
		"footer" = {
			"id"="footer",
			"class"="scheme-spanning"
		},
		"header" = {
			"id"="header",
			"class"="scheme-spanning"
		},
		"topnav" = {
			"id"="topnav",
			"class"="scheme-spanning"
		}

	];

	for (var id in containers) {
		containers[id]["type"] = "container";
		contentObj.settings(containers[id],arguments.styles);
	}

	return containers;

}

</cfscript>