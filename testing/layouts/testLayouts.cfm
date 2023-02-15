<cfscript>
/*
Save a formatted version of each layout to an html file (see outDir)
*/

// inputDir = expandPath("testlayout1");
inputDir = expandPath("../../sample/_data/layouts");
outDir = ExpandPath("_output/");

layoutsObj = new clikpage.layouts.layouts(inputDir);
data = layoutsObj.loadAll();

for (id in data.layouts) {
	layout = layoutsObj.getLayout(id);
	
	fileWrite(outDir & ListLast(id,".") & ".html", layoutsObj.getHTML(layout));
}

WriteOutput("complete");
// WriteOutput(HtmlCodeFormat(layoutObj.getHTML(mylayout.layout)));
</cfscript>