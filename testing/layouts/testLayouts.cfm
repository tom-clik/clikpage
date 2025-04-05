<cfscript>
/*
Save a formatted version of each layout to an html file (see outDir)
*/

// inputDir = expandPath("testlayout1");
inputDir = expandPath("../../sample/_data/layouts");
outDir = ExpandPath("_output/");

layoutsObj = new clikpage.layouts.layouts(inputDir);
files = DirectoryList(inputDir,0,"name");

for (filename in files) {
	id = ListFirst(filename,".");
	layout = layoutsObj.getLayout(id);
	
	fileWrite(outDir & ListLast(id,".") & ".html", layoutsObj.getHTML(layout));
}

WriteOutput("complete");
// WriteOutput(HtmlCodeFormat(layoutObj.getHTML(mylayout.layout)));
</cfscript>