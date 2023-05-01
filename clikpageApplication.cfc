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
			
			application.siteObj = new clikpage.site.site(argumentcollection=application.config,debug = this.debug);
			application.siteObj.pageObj.addCss(application.siteObj.pageObj.content, "styles/styles.css");
			application.siteObj.pageObj.content.static_css["fonts"] = 1;
			application.siteObj.pageObj.content.static_css["content"] = 1;

			application.siteObj.contentObj.loadButtonDefFile(ExpandPath("/_assets/images/buttons.xml"));
			
			loadSite(reload=true);

		}
		catch (any e) {
			throw(e);
			local.extendedinfo = {};
			local.existing = deserializeJSON(e.extendedinfo);
			if (IsStruct(local.existing)) {
				StructAppend(local.extendedinfo,local.existing);
			}
			
			local.extendedinfo["tagcontext"] = e.tagcontext;

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

	private void function loadSite(boolean reload=false)	 {
		
		local.update = arguments.reload OR checkStylesChanged();

		if (local.update) {
			
			application.site = application.siteObj.loadSite(application.config.siteDef);

			if (StructKeyExists(application.site,"links")) {
				for (local.link in application.site.links) {
					application.siteObj.pageObj.addLink(content=application.siteObj.pageObj.content,argumentcollection=local.link);	
				}
			}
			
			local.css = application.siteObj.siteCSS(site=application.site);

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
				throw(message="Invalid ID");
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
		  		loadSite(reload=1);
		  	}
		}
		
		request.prc.pageContent = application.siteObj.page(site=application.site,pageRequest=request.rc);

	}

	public void function onRequestEnd(){
		
		try { 
			
			// pending formal mechanism for partial content
			if (Left(request.prc.pageContent.layoutname,5) eq "popup") {
				writeOutput(request.prc.pageContent.body);
			}
			else {
				writeOutput(application.siteObj.pageObj.buildPage(request.prc.pageContent));
			}

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
				writeDump(var=niceError,label="Error");
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



