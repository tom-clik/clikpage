<!---

Scratch pad for testing individual cs styling


test = settingsObj.inheritSettings(styles=styles.testfill, media=styles.media, settings);

writeDump(test);


--->

<cfscript>
settingsObj = CreateObject("component", "clikpage.settings.settings").init(debug=1);
contentObj = CreateObject("component", "clikpage.content.content").init(settingsObj=settingsObj);

contentObj.debug = true;

styles = {};
settingsObj.loadStyleSheet(expandPath("./testStyles.css"), styles);
settingsObj.loadStyleSheet(expandPath("../css/_styles/grid_test.css"), styles);

writeDump(styles.testfix);

// menu = contentObj.new(id="topmenu",title="Menu",type="menu");

cs = contentObj.new(id="testfix",title="Grid",type="grid");

css = contentObj.css(content=cs, styles=styles);

for (medium in css) {

	writeOutput("<h2>#medium#</h2>");
	writeOutput("<pre>" & htmlCodeFormat(css[medium]) & "</pre>");

}

</cfscript>