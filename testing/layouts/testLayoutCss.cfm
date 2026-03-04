<cfscript>
/* 

Save CSS for a layout.

*/

layoutName = "main";
layoutFolder = "C:\git\dm\clikdesign\samples\webb\layouts"
layoutsObj = new clikpage.layouts.layouts(layoutFolder);
settingsObj = new clikpage.testing.styles.settingsTest();
styles = {};
settingsObj.loadStyleSheet(expandPath("../css/_styles/test_settings.scss"), styles);

data = layoutsObj.getLayout(layoutName);

css = settingsObj.layoutCss(
		containers=data.containers, 
		styles=data.style,
		media=styles.media,
		selector="body.template-#layoutName#",
		debug=true
	);

writeOutput("<pre>#css#</pre>");
</cfscript>