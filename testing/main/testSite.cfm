<cfscript>

/** has sort of turned into the main test page

to do: move into different folder.

*/

request.rc =Duplicate(form);
StructAppend(request.rc,url,false);

param name="request.rc.section" default="home";

settingsObj = CreateObject("component", "clikpage.settingsObj").init(debug=1);
contentObj = CreateObject("component", "clikpage.contentObj").init(settingsObj=settingsObj);
layoutObj = createObject("component", "clikpage.layouts.layouts").init(ExpandPath("../layouts"));
pageObj = createObject("component", "clikpage.pageObj").init(debug=1);
siteObj = createObject("component", "clikpage.site.siteObj").init(debug = true);

site = siteObj.loadSite(ExpandPath("../site/testSite.xml"));

if (!StructKeyExists(site.sections,request.rc.section)) {
	throw("Section not found");
}
sectionLayout = site.sections[request.rc.section];

site.sections[request.rc.section].location = siteObj.sectionLocation(site,request.rc.section);

layoutname = StructKeyExists(site.sections[request.rc.section],"layout") ? site.sections[request.rc.section]["layout"] : "testlayout1";


mylayout = layoutObj.getLayout("testlayout1/#layoutname#");

styles = settingsObj.loadStyleSheet(ExpandPath("../styles/testStyles.xml"));

pageContent = pageObj.getContent();
// writeDump(pageContent);
// abort;

pageContent.static_css["columns"] = 1;
pageContent.static_css["fonts"] = 1;

local.columnLayout = StructKeyExists(mylayout,"columns") ? mylayout.columns : "SMX";

pageContent.bodyClass = "layout-testlayout layout-#layoutname# col-#local.columnLayout# spanning";

pageContent.css &= settingsObj.layoutCss(styles);

pageContent.css &= settingsObj.fontVariablesCSS(styles);
pageContent.css &= settingsObj.colorVariablesCSS(styles);

for (medium in styles.media) {
	if (medium.name != "main") {
		pageContent.css  &= "@media.#medium.name# {\n";
	}
	pageContent.css  &= settingsObj.containerCss(styles=styles,name="body",selector="body", media=medium.name);
	pageContent.css  &= settingsObj.containerCss(styles=styles,name="header", media=medium.name);
	pageContent.css  &= settingsObj.containerCss(styles=styles,name="content", media=medium.name);
	pageContent.css  &= settingsObj.containerCss(styles=styles,name="footer", media=medium.name);
	pageContent.css  &= settingsObj.containerCss(styles=styles,name="topnav", media=medium.name);
	if (medium.name != "main") {
			pageContent.css &= "}\n";
	}
}

cs = {};
pageLayout = mylayout.layout.clone();

for (content in mylayout.content) {
	try {
		csdata = mylayout.content[content];
		// by defaul any cs with a title will be a general cs
		if (! StructKeyExists(csdata, "type")) {
			if (StructKeyExists(csdata, "title")) {
				csdata["type"] = "general";
			}
			else {
				csdata["type"] = "text";
			}
		}
		
		//writeDump(csdata);
		cs[content] = contentObj.new(argumentCollection=csdata);
		//writeDump(cs[content]);
		cs[content].settings = contentObj.settings(cs[content],styles);
		// hack for data
		switch (content) {
			case "mainmenu":case "topmenu":
				cs[content]["data"] = siteObj.menuData(site=site,sections=site.sectionlist);
				break;
			case "footermenu":
				cs[content]["data"] = siteObj.menuData(site=site,sections="about,contact,privacy");
				break;
		}

		// first stab at dataset functionality. 
		if (StructKeyExists(csdata,"dataset")) {
			if (! StructKeyExists(csdata.dataset,"tag")) {
				throw("tag must be defined for datset at this time");
			}
			cs[content]["data"] = siteObj.getData(site=site,tag=csdata.dataset.tag);
		}

		pageContent.css &= contentObj.css(cs[content], styles.media);

		local.tag=pageLayout.select("###content#").first();
		local.tag.tagName("div");
		local.tag.attr("class",contentObj.getClassList(cs[content]));
		// shouldn't be needed
		//local.tag.removeAttr("type");
		try {
			local.tag.html(contentObj.html(cs[content]));
		}
		catch (Any e) {
			writeOutput("Unable to render cs<br>");
			writeOutput(e.message);
			writeDump(e);
			writeDump(cs[content]);
			abort;
		}
		
		contentObj.addPageContent(pageContent,contentObj.getPageContent(cs[content],true));
		

	}
	catch (Any e) {
		writeOutput("<h2>issue with #content#</h2>");
		writeDump(e);
	}
}

// writeDump(cs);
// abort;
//writeDump(mylayout);
//

pageContent.css = settingsObj.outputFormat(css=pageContent.css,styles=styles);

pageContent.body = layoutObj.getHTML(pageLayout);

pageContent.body = siteObj.dataReplace(site=site, html=pageContent.body, sectioncode=request.rc.section, page=pageContent);

writeOutput(pageObj.buildPage(pageContent));


</cfscript>