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
		application.dataObj = new clikpage.data.data_text(config);
		// also
		this.mappings["/logs/"]=[outside your web root!];
		application.errorTemplate=staticHTMLFile

		*/
	}

	public void function  onApplicationStart(){
		
		startApp();

		// TODO: some sort of check
		//checkConfig();

		if (! IsDefined("application.config") ) throw(message="application.config not defined. See notes regarding startApp() ");
		if (! IsDefined("application.dataObj") ) throw(message="application.dataObj not defined. See notes regarding startApp() ");
		 
		try {
			
			application.siteObj = new clikpage.site.site(argumentcollection=application.config,dataObj=application.dataObj, debug = this.debug);
			
			application.siteObj.pageObj.addCss(application.siteObj.pageObj.content, "styles/styles.css");
			application.siteObj.pageObj.content.static_css["fonts"] = 1;
			application.siteObj.pageObj.content.static_css["content"] = 1;
			application.siteObj.pageObj.content.static_js["clik_onready"] = 1;

			application.siteObj.contentObj.loadButtonDefFile(ExpandPath("/_assets/images/buttons.xml"));
			
			loadSite(reload=true);

		}
		catch (any e) {
			
			local.extendedinfo["error"] = e;

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
		local.dir = GetDirectoryFromPath(application.config.sitedef);
		local.list = directoryList(local.dir,true,"query");
		
		local.fileslastmodified = local.list.columnData("dateLastModified");

		local.styleslastmodified = ArrayMax(local.fileslastmodified);


		if (! StructKeyExists(application,"styleslastmodified" ) OR application.styleslastmodified < local.styleslastmodified) {
			application.styleslastmodified = local.styleslastmodified;
			return 1;
		}

		return 0;

	}

	private void function loadSite(boolean reload=false)	 {
		
		local.update = arguments.reload OR checkStylesChanged();

		if (local.update) {
			
			application.siteObj.cacheClear();
			application.site = application.siteObj.loadSite(application.config.siteDef);
			/** What on earth are these doing here
			 * MUSTDO: TODO: put this into the site object somewhere.
			 * I get the idea that we wanted to change the pageContent
			 * but this is the wrong place.
			 * */
			if (StructKeyExists(application.site,"links")) {
				for (local.link in application.site.links) {
					application.siteObj.pageObj.addLink(content=application.siteObj.pageObj.content,argumentcollection=local.link);	
				}
			}
			/* TODO: proper output dir definition */
			local.outputDir = GetDirectoryFromPath(getCurrentTemplatePath());
			/* TODO: put this into the site object somewhere. */
			local.css = "/* File written #now()# */" & NewLine();
			local.css &= application.siteObj.siteCSS(site=application.site);
			fileWrite(local.outputDir & "styles/styles.css", local.css);

			/* TODO: put this into the site object somewhere. */
			application.siteObj.saveData(site=application.site, outputDir=local.outputDir & "scripts");

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
			if (NOT (request.rc.id eq "" OR IsValid("regex",request.rc.id, "[A-Za-z0-9\-\_]+"))) {
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
		  	}
		  	loadSite(reload=request.rc.reload);
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

	function onError(e,method) {
		
		// remember to add path for logs !!! this.mappings["/logs/"]=[outside your web root!];
		local.args = {
			e=e,
			debug=this.debug ? : 0,
			isAjaxRequest=request.prc.isAjaxRequest ? : 0,
			pageTemplate=application.errorTemplate ? : "",
			logger= application.errorLogger ? : new cferrorHandler.textLogger( ExpandPath( "/logs/errors" ) )
		};

		try {
			new cferrorHandler.ErrorHandler(argumentcollection=local.args);
		}
		catch (any n) {
			throw(object=e);
		}
	}

}



