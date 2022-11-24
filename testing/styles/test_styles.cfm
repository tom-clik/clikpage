<!---

Currently a scratchpad. Working towards a complete method for saving a stylesheet.

NEW SYSTEM: 

We have the layout styles in a collection called layouts (a new key of the stylesheet). Each of these can have a set of styling for the layout containers.

The main styles can also have styling for containers but these will apply to everything e.g. colors.

Then we have to write out the styles for all the content sections. How we do this I'm not sure. We need to get every CS from every template.

1. Currently taking a fake collection of divs and writing out the layout styles for these.

Next:

Loop over the same divs and write out styles from the main styles. 

--->

<cfscript>
settingsObj = new clikpage.settings.settings(debug=1);
contentObj  = new clikpage.content.content(settingsObj=settingsObj);

contentObj.debug = true;

styles = settingsObj.loadStyleSheet(ExpandPath("./testStyles.xml"));
fakesite = deserializeJSON(fileRead(ExpandPath("./testlayout5.json")));

css = siteCSS(styles);

WriteOutput("<pre>" & HtmlEditFormat(settingsObj.outputFormat(css,styles)) & "</pre>");

string function siteCSS(required styles) {
	var css = "";
	css &= ":root {\n";
	css &= settingsObj.colorVariablesCSS(styles);
	css &= settingsObj.fontVariablesCSS(styles);
	css &=  "\n}\n";
	css &= settingsObj.CSSCommentHeader("Layouts");
	for (local.layout in arguments.styles.layouts) {
		css &= "/* Layout #local.layout# */\n"
		css &= settingsObj.layoutCss(containers=fakesite.containers, styles=arguments.styles.layouts[local.layout],media=arguments.styles.media,selector="body.template-#local.layout#");
	}
	css &= settingsObj.CSSCommentHeader("Container styling");
	css &= settingsObj.layoutCss(containers=fakesite.containers, styles=arguments.styles.content,media=arguments.styles.media);

	css &= settingsObj.CSSCommentHeader("Content styling");
	
	css &= contentCSS(content_sections=fakesite.content,styles=arguments.styles.content,media=arguments.styles.media);
	
	return css;
}

/**
 * @hint Get complete css for all content section
 *
 * Loop over all the media queries and generate stylesheet for each CSS
 * 
 * @styles    Complete stylesheet with media and content fields
 * @content_sections Struct of content sections
 * @loadsettings     Update each cs with its settings. Turn off if this has been done. See contentObj.settings()
 */
public string function contentCSS(required struct styles, required struct content_sections, required struct media, boolean loadsettings=1) {
	
	var css = "";
	var cs = false;

	if (arguments.loadsettings) {
		for (var id in arguments.content_sections) {
			cs = arguments.content_sections[id];
			contentObj.settings(cs,arguments.styles,arguments.media);
		}
		
	}
	
	for (var medium in arguments.media ) {

		var media = arguments.media[medium];
		var media_css = "";

		for (var id in arguments.content_sections) {
			
			cs = arguments.content_sections[id];
			
			if (StructKeyExists(arguments.styles, id)) {
				if (StructKeyExists(arguments.styles[id], medium)) {
					media_css &= contentObj.css(cs,false);
				}
			}
		}

		if (media_css NEQ "") {
			if (medium NEQ "main") {
				css &= "@media.#medium# {\n" & settingsObj.indent(media_css,1) & "\n}\n";
			}
			else {
				css &= media_css;
			}
		}
	}
	
	return css;
}


</cfscript>