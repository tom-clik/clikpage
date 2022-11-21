<!---

Currently a scratchpad. Working towards a complete method for saving a stylesheet.

--->

<cfscript>
settingsObj = new clikpage.settings.settings(debug=1);
contentObj  = new clikpage.content.content(settingsObj=settingsObj);

contentObj.debug = true;

styles = settingsObj.loadStyleSheet(ExpandPath("./testStyles.xml"));
writeDump(styles);
abort;

layout_containers = containersData(styles);
containers = containersData(styles);

css = siteCSS(styles);

WriteOutput("<pre>" & HtmlEditFormat(settingsObj.outputFormat(css,styles)) & "</pre>");

string function siteCSS(required struct styles) {
	var css = "";
	css &= ":root {\n";
	css &= settingsObj.colorVariablesCSS(styles);
	css &= settingsObj.fontVariablesCSS(styles);
	css &=  "\n}\n";
	for (local.layout in arguments.styles.layouts) {
		css &= settingsObj.layoutCss(containers, styles);
	}
	
	
	return css;
}

// string  function containersCSS(required struct containers, required struct styles) {
// 	var css = "";

// 	for (var medium in arguments.styles.media ) {
// 		var section_css = "";
// 		for (var id in arguments.containers) {
// 			var cs =  arguments.containers[id];
// 			if ((medium EQ "main") OR (StructKeyExists(cs.settings, medium))) {
// 				local.settings = medium EQ "main" ? cs.settings : cs.settings[medium];
// 				section_css &= settingsObj.containerCss(settings=local.settings,selector="###id#");
// 			}	
// 		}
// 		css &= "/* CSS for #medium# */\n";
// 		if (section_css NEQ "") {
// 			if (medium NEQ "main") {
// 				css &= "@media.#medium# {\n " & section_css & "\n}\n";
// 			}
// 			else {
// 				css &= section_css;
// 			}
// 		}
// 	}
// 	return css;
// }

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