<cfscript>

/** 
 *
 * Deprecated. Use sample app
 */

throw("Are you sure you want to be here? Surely use the sample app");

request.rc =Duplicate(form);
StructAppend(request.rc,url,false);

param name="request.rc.section" default="index";
param name="request.rc.action" default="index";
param name="request.rc.id" default="";

settingsObj = CreateObject("component", "clikpage.settings.settingsObj").init(debug=1);
contentObj = CreateObject("component", "clikpage.content.contentObj").init(settingsObj=settingsObj);
layoutObj = createObject("component", "clikpage.layouts.layouts").init(ExpandPath("../layouts"));
pageObj = createObject("component", "clikpage.pageObj").init(debug=1);
siteObj = createObject("component", "clikpage.site.siteObj").init(debug = true);
siteObj.setdebug(true);
siteObj.setpreviewurl("testSite.cfm");
site = siteObj.loadSite(ExpandPath("../site/testSite.xml"));
contentObj.loadButtonDefFile(ExpandPath("/_assets/images/buttons.xml"));

styles = settingsObj.loadStyleSheet(ExpandPath("../styles/testStyles.xml"));

if (!StructKeyExists(site.sections,request.rc.section)) {
	throw("Section not found");
}

request.prc.section = siteObj.getSection(site=site,section=request.rc.section);

site.sections[request.rc.section].location = siteObj.sectionLocation(site=site,section=request.rc.section);

layoutname = siteObj.getLayoutName(section=request.prc.section,action=request.rc.action);

mylayout = layoutObj.getLayout("testlayout1/#layoutname#");

pageContent = pageObj.getContent();
// writeDump(pageContent);
// abort;

pageContent.static_css["columns"] = 1;
pageContent.static_css["fonts"] = 1;

// to do: body class as method of layout object
local.columnLayout = StructKeyExists(mylayout,"columns") ? mylayout.columns : "SMX";

pageContent.bodyClass = "col-SM";

pageContent.css &= settingsObj.layoutCss(styles);
pageContent.css &= settingsObj.fontVariablesCSS(styles);
pageContent.css &= settingsObj.colorVariablesCSS(styles);

for (medium in styles.media) {
	if (medium.name != "main") {
		pageContent.css  &= "@media.#medium.name# {\n";
	}

	pageContent.css  &= settingsObj.containerCss(styles=styles,name="body",selector="body", media=medium.name);

	for (container in  mylayout.containers) {
		pageContent.css  &= "/* generating stylings for #container# [#medium.name#] */\n";
		pageContent.css  &= settingsObj.containerCss(styles=styles,name=container, media=medium.name);	
	}

	if (medium.name != "main") {
			pageContent.css &= "}\n";
	}
}

cs = {};

// to do: add as method of layout object
pageLayout = mylayout.layout.clone();
request.prc.record = {};

for (content in mylayout.content) {
	try {
		csdata = mylayout.content[content];
		
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
		if (StructKeyExists(request.prc.section,"dataset")) {
			if (! StructKeyExists(request.prc.section.dataset,"tag")) {
				throw("tag must be defined for datset at this time");
			}
			request.prc.section["data"] = siteObj.getDataSet(site=site,tag=request.prc.section.dataset.tag);
		}

		// hardwired for list types at the minute. what to do???
		if (cs[content].type == "articlelist") {
			cs[content]["data"] = Duplicate(request.prc.section["data"]);
			siteObj.addLinks(dataSet=cs[content]["data"],site=site,section=request.rc.section);
		}

		pageContent.css &= contentObj.css(cs[content], styles.media);

		local.tag=pageLayout.select("###content#").first();
		local.tag.tagName("div");
		
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
		local.tag.attr("class",contentObj.getClassList(cs[content]));
		
		contentObj.addPageContent(pageContent,contentObj.getPageContent(cs[content],true));
		
	}

	catch (Any e) {
		writeOutput("<h2>issue with #content#</h2>");
		writeDump(e);
	}

}

// first stab at data functionality. 
if (request.rc.id != "") {
	if (! StructKeyExists(request.prc.section,"data")) {
		throw(message="section data not defined",detail="You must define a dataset for a section to use the record functionality");
	}
	request.prc.record = siteObj.getData(site=site,id=request.rc.id,section=request.rc.section,dataSet=request.prc.section.data);
}


// writeDump(cs);
// abort;
// writeDump(mylayout);


pageContent.css = settingsObj.outputFormat(css=pageContent.css,styles=styles);

pageContent.body = layoutObj.getHTML(pageLayout);

pageContent.body = siteObj.dataReplace(site=site, html=pageContent.body, sectioncode=request.rc.section, record=request.prc.record);

writeOutput(pageObj.buildPage(pageContent));


</cfscript>







