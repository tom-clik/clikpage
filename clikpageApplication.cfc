/**
 * Extend this in your application.cfc to create a Clikpage app or use it as an example
 */
component {

	this.sessionManagement = true;
	this.sessionTimeout = createTimeSpan(0,0,30,0);
	this.setClientCookies = true;
	this.sessioncookie.secure = true;
	this.debug = false;	

	// virtual
	public void function startApp() {
		throw("You must redefine startApp in your own application");
		/* e.g. 
		application.config = {
			layoutsFolder=ExpandPath("layouts"),
			siteDef=ExpandPath("sampleSite.xml"),
			styledef=ExpandPath("styles/sample_style.xml")
		};
		*/
	}

	public void function  onApplicationStart(){
		
		startApp();

		try {
			
			application.settingsObj = new clikpage.settings.settingsObj(debug=this.debug);
			application.contentObj = new clikpage.content.contentObj(settingsObj=application.settingsObj);

			application.layoutObj = new clikpage.layouts.layouts(application.config.layoutsFolder);
			application.pageObj = new clikpage.pageObj(debug=this.debug);
			application.pageObj.content.static_css["columns"] = 1;
			application.pageObj.content.static_css["fonts"] = 1;
			

			application.siteObj = new clikpage.site.siteObj(debug = this.debug);
			application.siteObj.setdebug(this.debug);
			application.siteObj.setpreviewurl("index.cfm");
			application.site = application.siteObj.loadSite(application.config.siteDef);
			application.contentObj.loadButtonDefFile(ExpandPath("/_assets/images/buttons.xml"));
			
			loadStyling(application.config.styledef,true);

			application.pageObj.addCss(application.pageObj.content,"/_assets/css/schemes/columns_schemes.css");
			application.pageObj.addCss(application.pageObj.content, "styles.css");



		}
		catch (any e) {
			local.extendedinfo = {"tagcontext"=e.tagcontext};
			throw(
				extendedinfo = SerializeJSON(local.extendedinfo),
				message      = "error loading application:" & e.message, 
				detail       = e.detail,
				errorcode    = "onApplicationStart.1"		
			);
		}
	}

	// Check whether a styling file has been modified. Just playing with this
	// idea at the minute.
	private boolean function checkStylesChanged()	 {
		local.styleslastmodified = Getfileinfo(application.styleSheetFile).lastmodified;

		if (! StructKeyExists(application,"styleslastmodified" ) OR application.styleslastmodified < local.styleslastmodified) {
			application.styleslastmodified = local.styleslastmodified;
			return 1;
		}

		// writeDump(application.styleslastmodified);
		// writeDump(local.styleslastmodified);
		// abort;

		return 0;

	}

	// complete mess. Get this into the siteObj somehow.
	private void function loadStyling(styledef, boolean reload=false)	 {
		
		application.styleSheetFile = arguments.styledef;

		local.update = arguments.reload OR checkStylesChanged();

		if (local.update) {

			application.styles = application.settingsObj.loadStyleSheet(application.styleSheetFile);
				
			// save site styling
			// TO DO: a formal mechanism for this
			// Possibly a site root in the siteObject?
			local.css = application.settingsObj.siteCss(application.styles);
			FileWrite(ExpandPath("styles.css"), local.css);
		}

	}
	
	public void function onRequestStart() {
		
		request.rc = StructNew();
		request.prc = StructNew();

		StructAppend(request.rc,url);
		StructAppend(request.rc,form,true);

		param name="request.rc.section" default="index";
		param name="request.rc.action" default="index";
		param name="request.rc.id" default="";


		if (this.debug) {
		  param name="request.rc.reload" default="false" type="boolean";
		  if (request.rc.reload) {
		  	onApplicationStart();
		  }
		  loadStyling(styledef=application.styleSheetFile,reload=request.rc.reload);
		}

		request.prc.pageContent = application.pageObj.getContent();
		
		request.prc.section = application.siteObj.getSection(site=application.site,section=request.rc.section);

		// WTF. TO DO: sort this
		application.site.sections[request.rc.section].location = application.siteObj.sectionLocation(site=application.site,section=request.rc.section);

		request.prc.layoutname = application.siteObj.getLayoutName(section=request.prc.section,action=request.rc.action);
		request.prc.mylayout = application.layoutObj.getLayout(request.prc.layoutname);

		request.prc.pageContent.bodyClass =  application.siteObj.bodyClass(request.prc.mylayout);

		var cs = {};

		// to do: add as method of layout object
		request.prc.pageLayout = request.prc.mylayout.layout.clone();

		request.prc.record = {};
		
		for (var content in request.prc.mylayout.content) {
			try {
				var csdata = request.prc.mylayout.content[content];
				
				cs[content] =  application.contentObj.new(argumentCollection=csdata);
				//writeDump(cs[content]);
				application.contentObj.settings(cs[content],application.styles);
				

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
						throw("tag must be defined for dataset at this time");
					}
					local.type = request.prc.section.dataset.type ? : "articles";
					request.prc.section["data"] = application.siteObj.getDataSet(site=application.site,tag=request.prc.section.dataset.tag, type=local.type);
					// first stab at data functionality. 
					if (request.rc.id != "") {
						request.prc.record = application.siteObj.getRecord(site=application.site,id=request.rc.id,type=local.type);
					
						StructAppend(request.prc.record,application.siteObj.getRecordSetInfo(site=application.site,dataset=request.prc.section["data"],id=request.rc.id,type=local.type));
					}
					

				}
				else if (request.rc.id != "") {
					throw(message="section data not defined",detail="You must define a dataset for a section to use the record functionality");
				}

				// hardwired for list types at the minute. what to do???
				// reasonably easy to define data sets but waht about the links
				switch (cs[content].type) {
					case "articlelist":
						cs[content]["data"] = application.siteObj.getRecords(site=application.site,dataset=request.prc.section["data"], type=local.type);
						application.siteObj.addLinks(data=cs[content]["data"],data=cs[content]["data"],site=application.site,section=request.rc.section,action="view");
						break;
					case "imagegrid":
						cs[content]["data"] = application.siteObj.getRecords(site=application.site,dataset=request.prc.section["data"], type=local.type);
						application.siteObj.addLinks(data=cs[content]["data"],data=cs[content]["data"],site=application.site,section=request.rc.section,action="view");
						
						break;
				}

				request.prc.pageContent.css &= application.contentObj.css(cs[content]);

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
	}

	public void function onRequestEnd(){
		
		try { 
			request.prc.pageContent.css = application.settingsObj.outputFormat(css=request.prc.pageContent.css,styles=application.styles);
			request.prc.pageContent.body = application.layoutObj.getHTML(request.prc.pageLayout);

			request.prc.pageContent.body = application.siteObj.dataReplace(site=application.site, html=request.prc.pageContent.body, sectioncode=request.rc.section, record=request.prc.record);

			writeOutput(application.pageObj.buildPage(request.prc.pageContent));

		}
		catch (any e) {
			local.extendedinfo = {"tagcontext"=e.tagcontext,"pageContent"=request.prc.pageContent};
			throw(
				extendedinfo = SerializeJSON(local.extendedinfo),
				message      = "Unable to render page:" & e.message, 
				detail       = e.detail,
				errorcode    = "onRequestEnd.1"		
			);
		}
	
	}


	public void function onSessionStart(){
		
	}

	public void function onSessionEnd( struct sessionScope, struct appScope ){
		
	}


	public void function onError(e) {
		
		var niceError = ["message"=e.message,"detail"=e.detail,"code"=e.errorcode,"ExtendedInfo"=deserializeJSON(e.ExtendedInfo)];
		
		// supply original tag context in extended info
		if (IsDefined("niceError.ExtendedInfo.tagcontext")) {
			niceError["tagcontext"] =  niceError.ExtendedInfo.tagcontext;
			StructDelete(niceError.ExtendedInfo,"tagcontext");
		}
		else {
			niceError["tagcontext"] =  e.TagContext;
		}
		
	

		// set to true in any API to always get JSON errors even when testing
		param name="request.prc.isAjaxRequest" default="false" type="boolean";

		if (e.type == "ajaxError" OR request.prc.isAjaxRequest) {
			
			local.errorCode = createUUID();
			local.filename = this.errorFolder & "/" & local.errorCode & ".html";
			
			FileWrite(local.filename,local.errorDump,"utf-8");
			
			local.error = {
				"status": 500,
				"filename": local.filename,
				"message" : e.message,
				"code": local.errorCode
			}
			
			WriteOutput(serializeJSON(local.error));
		}
		else {
			if (this.debug) {
				writeDump(niceError);
			}
			else {
				handleError(niceError);
				
				local.pageWritten = false;
				if (IsDefined("application.pageObj")) {

					request.content.body = "<h1>Error</h1>";
					request.content.body &= arguments.e.message;
					try {
						writeOutput(application.pageObj.buildPage(request.content));
						local.pageWritten = true;
					}
					catch (any e) {

					}
				}
				if (NOT local.pageWritten) {
					writeOutput("Sorry, an error has occurred");
				}

			}
			
		}
		
	}

	// VIRTUAL
	public void function handleError(struct error) {
		// DO SOMETHING WITH THE ERROR
	}

}



