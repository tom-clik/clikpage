<!---

Currently a scratchpad. Working towards a complete method for saving a stylesheet.

NEW SYSTEM: 

We have the layout styles in a collection called layouts (a new key of the stylesheet). Each of these can have a set of styling for the layout containers.

The main styles can also have styling for containers but these will apply to everything e.g. colors.

Then we have to write out the styles for all the content sections. How we do this I'm not sure. We need to get every CS from every template.

--->

<cfscript>
settingsObj = new clikpage.settings.settings(debug=1);
contentObj  = new clikpage.content.content(settingsObj=settingsObj);

styles = settingsObj.loadStyleSheet(ExpandPath("./testStyles.xml"));
fakesite = deserializeJSON(fileRead(ExpandPath("./testlayout5.json")));

outfile = ExpandPath("test_settings.css");

contentObj.debug = true;
css = siteCSS(styles);
css = settingsObj.outputFormat(css=css,media=styles.media,debug=contentObj.debug);

fileWrite(outfile, css);

WriteOutput("<pre>" & HtmlEditFormat(css) & "</pre>");

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
	
	css &= contentObj.contentCSS(content_sections=fakesite.content,styles=arguments.styles.content,media=arguments.styles.media);
	
	return css;
}


</cfscript>