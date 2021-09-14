/* Extend this in your application.cfc to create a Clikpage app or use it as an example   


 */
component {

	this.debug = false;	

	public void function startApp(required string layoutsFolder, required string siteDef, required string styledef){
		try {
			
			application.settingsObj = CreateObject("component", "clikpage.settings.settingsObj").init(debug=this.debug);
			application.contentObj = CreateObject("component", "clikpage.content.contentObj").init(settingsObj=application.settingsObj);

			
			application.layoutObj = createObject("component", "clikpage.layouts.layouts").init(arguments.layoutsFolder);
			application.pageObj = createObject("component", "clikpage.pageObj").init(debug=this.debug);
			application.pageObj.content.static_css["columns"] = 1;
			application.pageObj.content.static_css["fonts"] = 1;
			
			application.siteObj = createObject("component", "clikpage.site.siteObj").init(debug = this.debug);
			application.siteObj.setdebug(this.debug);
			application.siteObj.setpreviewurl("index.cfm");
			application.site = application.siteObj.loadSite(arguments.siteDef);
			application.contentObj.loadButtonDefFile(ExpandPath("/_assets/images/buttons.xml"));
			application.styles = application.settingsObj.loadStyleSheet(arguments.styledef);

			
			// save site styling
			// TO DO: a formal mechanism for this
			// Possibly a site root in the siteObject?
			local.css = application.settingsObj.siteCss(application.styles);

			FileWrite(ExpandPath("styles.css"), application.settingsObj.outputFormat(local.css,application.styles));
			application.pageObj.addCss(application.pageObj.content, "styles.css");		


		}
		catch (Any e) {
			writeOutput("error loading application");
			writeDump(e);
			abort;
		}
	}
	
	public void function onRequestStart(targetPage)	 {
		requestStart();
	}

	private void function requestStart(){
		
		request.rc = StructNew();
		request.prc = StructNew();

		StructAppend(request.rc,url);
		StructAppend(request.rc,form,true);

		param name="request.rc.section" default="index";
		param name="request.rc.action" default="index";
		param name="request.rc.id" default="";


		request.prc.pageContent = application.pageObj.getContent();
		
		request.prc.section = application.siteObj.getSection(site=application.site,section=request.rc.section);

		// WTF. TO DO: sort this
		application.site.sections[request.rc.section].location = application.siteObj.sectionLocation(site=application.site,section=request.rc.section);

		request.prc.layoutname = application.siteObj.getLayoutName(section=request.prc.section,action=request.rc.action);
		request.prc.mylayout = application.layoutObj.getLayout(request.prc.layoutname);

		request.prc.pageContent.css &=  application.settingsObj.containersCSS(application.styles,request.prc.mylayout);

		request.prc.pageContent.bodyClass =  application.siteObj.bodyClass(request.prc.mylayout);

		var cs = {};

		// to do: add as method of layout object
		request.prc.pageLayout = request.prc.mylayout.layout.clone();

		request.prc.record = {};
		
		for (var content in request.prc.mylayout.content) {
			try {
				var csdata = request.prc.mylayout.content[content];
				
				//writeDump(csdata);
				cs[content] =  application.contentObj.new(argumentCollection=csdata);
				//writeDump(cs[content]);
				cs[content].settings =  application.contentObj.settings(cs[content],application.styles);
				// hack for data
				// TO DO: re do this when we have proper data set functionality
				switch (content) {
					case "mainmenu":case "topmenu":
						cs[content]["data"] = application.siteObj.menuData(site=application.site,sections=application.site.sectionlist);
						break;
					case "footermenu":
						cs[content]["data"] = application.siteObj.menuData(site=application.site,sections="about,contact,privacy");
						break;
				}

				// first stab at dataset functionality. 
				if (StructKeyExists(request.prc.section,"dataset")) {
					if (! StructKeyExists(request.prc.section.dataset,"tag")) {
						throw("tag must be defined for datset at this time");
					}
					request.prc.section["data"] = application.siteObj.getDataSet(site=application.site,tag=request.prc.section.dataset.tag);
				}

				// hardwired for list types at the minute. what to do???
				if (cs[content].type == "articlelist") {
					cs[content]["data"] = Duplicate(request.prc.section["data"]);
					application.siteObj.addLinks(dataSet=cs[content]["data"],site=application.site,section=request.rc.section);
				}

				request.prc.pageContent.css &= application.contentObj.css(cs[content], application.styles.media);

				local.tag=request.prc.pageLayout.select("###content#").first();
				local.tag.tagName("div");
				
				// shouldn't be needed
				//local.tag.removeAttr("type");
				try {
					local.tag.html(application.contentObj.html(cs[content]));
				}
				catch (Any e) {
					writeOutput("Unable to render cs<br>");
					writeOutput(e.message);
					writeDump(e);
					writeDump(cs[content]);
					abort;
				}
				local.tag.attr("class",application.contentObj.getClassList(cs[content]));
				
				application.contentObj.addPageContent(request.prc.pageContent,application.contentObj.getPageContent(cs[content],true));
				
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
			request.prc.record = application.siteObj.getData(site=application.site,id=request.rc.id,section=request.rc.section,dataSet=request.prc.section.data);
		}

			
	}

	public void function onRequestEnd(){
		
		request.prc.pageContent.css = application.settingsObj.outputFormat(css=request.prc.pageContent.css,styles=application.styles);

		request.prc.pageContent.body = application.layoutObj.getHTML(request.prc.pageLayout);

		request.prc.pageContent.body = application.siteObj.dataReplace(site=application.site, html=request.prc.pageContent.body, sectioncode=request.rc.section, record=request.prc.record);

		writeOutput(application.pageObj.buildPage(request.prc.pageContent));
	
	}

}



