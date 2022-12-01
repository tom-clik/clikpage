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

		// TODO: some sort of check
		//checkConfig();

		try {
			
			application.settingsObj = new clikpage.settings.settings(debug=this.debug);
			application.contentObj = new clikpage.content.content(settingsObj=application.settingsObj,debug=this.debug);
			application.layoutsObj = new clikpage.layouts.layouts(application.config.layoutsFolder);
			application.pageObj = new clikpage.page(debug=this.debug);
			application.pageObj.content.static_css["fonts"] = 1;
			application.pageObj.content.static_css["content"] = 1;
			
			application.siteObj = new clikpage.site.site(debug = this.debug);
			application.site = application.siteObj.loadSite(application.config.siteDef);
			application.contentObj.loadButtonDefFile(ExpandPath("/_assets/images/buttons.xml"));
			
			loadStyling(true);

			application.pageObj.addCss(application.pageObj.content, "styles/styles.css");

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
	private boolean function checkStylesChanged() {

		local.fileslastmodified = [Getfileinfo(application.config.styledef).lastmodified];
		arrayAppend(local.fileslastmodified, Getfileinfo(application.config.siteDef).lastmodified);

		local.list = directoryList(application.config.layoutsFolder,true,"query","*.html");
		
		arrayAppend(local.fileslastmodified, local.list.columnData("dateLastModified") , true);

		local.styleslastmodified = ArrayMax(local.fileslastmodified);

		if (! StructKeyExists(application,"styleslastmodified" ) OR application.styleslastmodified < local.styleslastmodified) {
			application.styleslastmodified = local.styleslastmodified;
			return 1;
		}

		// writeDump(application.styleslastmodified);
		// writeDump(local.styleslastmodified);
		// abort;

		return 0;

	}

	// TODO: formalise this. Add path for styles somehow
	private void function loadStyling(boolean reload=false)	 {
		
		local.update = arguments.reload OR checkStylesChanged();

		if (local.update) {
			
			application.styles = application.settingsObj.loadStyleSheet(application.config.styledef);
			
			local.sitedata = application.layoutsObj.loadAll();

			local.css = application.contentObj.siteCSS(site=local.sitedata,styles=application.styles);

			fileWrite(ExpandPath("styles/styles.css"), local.css);

		}

	}
	
	public void function onRequestStart() {
		
		request.rc = StructNew();
		request.prc = StructNew();

		StructAppend(request.rc,url);
		StructAppend(request.rc,form,true);

		try {
			param name="request.rc.section" default="index" type="regex" pattern="[A-Za-z0-9\-\_]+";
			param name="request.rc.action" default="index" type="regex" pattern="[A-Za-z0-9\-\_]+";
			param name="request.rc.id" default="";
			if (NOT (request.rc.id eq "" OR IsValid("integer",request.rc.id))) {
				throw("Invalid ID");
			}
		}
		catch (any e) {
			if (this.debug) {
				throw(e);
			}
			/* throw a badrequest error on dodgy params */
			throw(type="badrequest");
		}

		if (this.debug) {
		  param name="request.rc.reload" default="false" type="boolean";
		  if (request.rc.reload) {
		  	onApplicationStart();
		  }
		  loadStyling(reload=request.rc.reload);
		}

		request.prc.pageContent = application.pageObj.getContent();
		
		request.prc.section = application.siteObj.getSection(site=application.site,section=request.rc.section);

		// WTF. TO DO: sort this
		application.site.sections[request.rc.section].location = application.siteObj.sectionLocation(site=application.site,section=request.rc.section);

		request.prc.layoutname = application.siteObj.getLayoutName(section=request.prc.section,action=request.rc.action);
		request.prc.layout = application.layoutsObj.getLayout(request.prc.layoutname);

		request.prc.pageContent.bodyClass =  request.prc.layout.bodyClass;

		var cs = {};

		request.prc.record = {};
		
		// todo: add as method of content object
		for (var content in request.prc.layout.content) {
			try {
				var csdata = request.prc.layout.content[content];
				
				cs[content] =  application.contentObj.new(argumentCollection=csdata);
				//writeDump(cs[content]);
				application.contentObj.settings(content=cs[content],styles=application.styles.content,media=application.styles.media);
				
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
				else if (request.rc.id != "" AND request.rc.id != 0) {
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

				local.tag=request.prc.layout.layout.select("###content#").first();
				
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
			request.prc.pageContent.css = application.settingsObj.outputFormat(css=request.prc.pageContent.css,media=application.styles.media);

			request.prc.pageContent.body = application.layoutsObj.getHTML(request.prc.layout);

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
		
		var niceError = [
			"usermessage"="Sorry, an error has occurred",
			"message"=arguments.e.message,
			"detail"=arguments.e.detail,
			"code"=arguments.e.errorcode,
			"ExtendedInfo"=deserializeJSON(arguments.e.ExtendedInfo),
			"type"=arguments.e.type,
			"statuscode"=500,
			"statustext"="Error",
			"report"=1
		];

		// supply original tag context in extended info
		if (IsDefined("niceError.ExtendedInfo.tagcontext")) {
			niceError["tagcontext"] =  niceError.ExtendedInfo.tagcontext;
			StructDelete(niceError.ExtendedInfo,"tagcontext");
		}
		else {
			niceError["tagcontext"] =  e.TagContext;
		}
		
		switch ( niceError.type ) {
			case  "badrequest": case "validation":
				niceError.statuscode="400";
				niceError.statustext="Bad Request";
				niceError.report = 0;
				break;
			case  "forbidden":
				niceError.statuscode="403";
				niceError.statustext="Forbidden";
				niceError.report = 0;
				break;
			case  "Unauthorized":
				niceError.statuscode="401";
				niceError.statustext="Unauthorized";
				niceError.report = 0;
				break;
			case  "notfound": case  "notfounddetail":case "not found":
				niceError.statuscode="410";
				niceError.statustext="Page not found";
				niceError.report = 0;
				break;
			case "ajaxerror":
				// avoid throwing ajaxerror. better to set isAjaxRequest
				// and throw normal error
				request.prc.isAjaxRequest = 1;
			case  "custom":
				// custom error messages shopw thrown message
				niceError.usermessage  = niceError.message;
				break;
		}
		
		// set to true in any API to always get JSON errors even when testing
		param name="request.prc.isAjaxRequest" default="false" type="boolean";

		if (request.prc.isAjaxRequest) {

			local.error = {
				"statustext": niceError.statustext,
				"statuscode": niceError.statuscode,
				"message" : niceError.usermessage
			}			

			if (niceError.report) {
				local.error["errorID"] = logError(niceError);
			}

			WriteOutput(serializeJSON(local.error));
		}
		else {
			if (this.debug) {
				writeDump(niceError);
			}
			else {
				local.errorCode = logError(niceError);
				
				var errortext = "<h1>Error</h1>";
				errortext &= "<p>Please contact support quoting ref #local.errorCode#</p>";
				
				// try to write nice page
				local.pageWritten = false;
				if (IsDefined("application.pageObj")) {

					try {
						request.content.body = errortext;
						writeOutput(application.pageObj.buildPage(request.content));
						local.pageWritten = true;
					}
					catch (any e) {

					}
				}
				if (NOT local.pageWritten) {
					writeOutput(errortext);
				}

			}
			
		}
		
	}

	/**
	 * Override this function with your own logger.
	 */
	public string function logError(required struct error) {
		
		local.errorCode = createUUID();
		
		try {
			local.filename = this.errorFolder & "/" & local.errorCode & ".html";
			writeDump(var=error,output=local.filename,format="html");
		}
		catch (any e) {
			local.errorCode = "n/a";
		}

		return local.errorCode;

	}

}



