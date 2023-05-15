<cfscript>
/* 

Save CSS for a layout.

*/

layoutName = "main";
layoutFolder = "C:\git\dm\clikdesign\samples\webb\layouts"
layoutsObj = new clikpage.layouts.layouts(layoutFolder);
settingsObj = new clikpage.testing.styles.settingsTest();
styles = settingsObj.loadStyleSettings(ExpandPath("../styles/testStyles.xml"));

data = layoutsObj.getLayout(layoutName);

css = settingsObj.layoutCss(
		containers=data.containers, 
		styles=data.style,
		media=styles.media,
		selector="body.template-#layoutName#"
	);

writeOutput("<pre>" & settingsObj.outputFormat(css=css, media=styles.media,debug=true) & "</pre>");
</cfscript>