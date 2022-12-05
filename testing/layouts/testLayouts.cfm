<cfscript>

// inputDir = expandPath("testlayout1");
inputDir = expandPath("../../sample/_data/layouts");
outDir = ExpandPath("_output/");

layoutsObj = new clikpage.layouts.layouts(inputDir);
data = layoutsObj.loadAll();

for (id in data.layouts) {
	layout = layoutsObj.getLayout(id);
	layout.layout.body().addClass(layout.bodyClass);
	layoutsObj.addInners(layout);
	fileWrite(outDir & ListLast(id,".") & ".html", layout.layout.html());
}

WriteOutput("complete");
// WriteOutput(HtmlCodeFormat(layoutObj.getHTML(mylayout.layout)));
</cfscript>