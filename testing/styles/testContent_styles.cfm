<!---

Scratch pad for testing individual cs styling

test = settingsObj.inheritSettings(styles=styles.testfill, media=styles.media, settings);

writeDump(test);

--->

<cfscript>
settingsObj = CreateObject("component", "clikpage.settings.settings").init(debug=1);
contentObj = CreateObject("component", "clikpage.content.content").init(settingsObj=settingsObj);

styles = {};
settingsObj.loadStyleSheet(expandPath("../css/_styles/test_settings.scss"), styles);
//settingsObj.loadStyleSheet(expandPath("../css/_styles/grid_test.css"), styles);
settingsObj.loadStyleSheet(expandPath("../css/_styles/articleList_test.scss"), styles);
id = "articlelist";

// menu = contentObj.new(id="topmenu",title="Menu",type="menu");
// cs = contentObj.new(id="testcolumns",title="Grid",type="grid");
cs = contentObj.new(id=id,title="List",type="articleList",class="scheme-articlelist_title");

debugcontent = {};

css = contentObj.css(content=cs, styles=styles,debug = true, debugcontent=debugcontent);
writeDump(styles[id]);

for (medium in css) {

	writeOutput("<h2>#medium#</h2>");
	writeOutput("<pre>" & htmlCodeFormat(css[medium]) & "</pre>");

}

</cfscript>