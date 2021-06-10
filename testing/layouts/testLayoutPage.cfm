<cfscript>

/** has sort of turned into the main test page

to do: move into different folder.
*/

request.rc =Duplicate(form);
StructAppend(request.rc,url,false);

param name="request.rc.section" default="home";

contentObj = createObject("component", "clikpage.contentObj").init();
layoutObj = createObject("component", "clikpage.layouts.layouts").init(getDirectoryFromPath(getCurrentTemplatePath()));
pageObj = createObject("component", "clikpage.pageObj").init(debug=1);
settingsObj = createObject("component", "clikpage.settingsObj").init(debug=1);
siteObj = createObject("component", "clikpage.site.siteObj").init(debug = true);

site = siteObj.loadSite(ExpandPath("../site/testSite.xml"));

sectionLayout = site.sections[request.rc.section];

if (!StructKeyExists(site.sections,request.rc.section)) {
	throw("Section not found");
}
layoutname = StructKeyExists(site.sections[request.rc.section],"layout") ? site.sections[request.rc.section]["layout"] : "testlayout1";


mylayout = layoutObj.getLayout("testlayout1/#layoutname#");
styles = settingsObj.loadStyleSheet(ExpandPath("../styles/testStyles.xml"));

pageContent = pageObj.getContent();
// writeDump(pageContent);
// abort;

pageContent.static_css["columns"] = 1;
pageContent.bodyClass = "layout-testlayout layout-#layoutname# col-SMX";

pageContent.css &= settingsObj.getLayoutCss(styles);

cs = {};
pageLayout = Duplicate(mylayout.layout);

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
		
		// hack for data
		switch (content) {
			case "mainmenu":
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

		if (StructKeyExists(styles.content,content)) {
			cs[content]["settings"] = styles.content[content];
		}
		
		local.tag=pageLayout.select("###content#").first();
		local.tag.tagName("div");
		local.tag.attr("class",contentObj.getClassList(cs[content]));
		// shouldn't be needed
		//local.tag.removeAttr("type");
		local.tag.html(contentObj.html(cs[content]));
		
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

pageContent.body = pageLayout.body().html();

pageContent.body = siteObj.dataReplace(site=site, html=pageContent.body, sectioncode=request.rc.section, page=pageContent);

writeOutput(pageObj.buildPage(pageContent));


</cfscript>