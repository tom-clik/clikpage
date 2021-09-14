<cfscript>
settingsObj = CreateObject("component", "clikpage.settings.settingsObj").init(debug=1);

layoutObj = createObject("component", "clikpage.layouts.layouts").init(getDirectoryFromPath(getCurrentTemplatePath()));

mylayout = layoutObj.getLayout("testcolumnlayout");

pageObj = createObject("component", "clikpage.pageObj").init(debug=1);

content = pageObj.getContent();

content.static_css["columns"] = 1;
content.css &= "
.border {
	margin:10px;
	padding:10px;
	border:1px solid ##3f3f3f;
} ";

content.title = "my test page";

content.body = layoutObj.getHTML(mylayout.layout);

param name="url.layout" default="SM";
// generate list of possible layouts
maincontent = "<h1>Column Layouts</h1>";
maincontent &= "<h3>#url.layout#</h3>";
layouts = [
	"M","MX","SM","MSX","XMS","SXM","XSM"
];
for (layout in layouts) {
	maincontent &= "<p><a href=""?layout=#layout#"">#layout#</a></p>";
}
content.body  =replace(content.body , "{{maincol}}", maincontent);

content.bodyClass = "col-#url.layout#";

writeOutput(pageObj.buildPage(content));



</cfscript>


