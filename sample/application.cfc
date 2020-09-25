/*

# clikpage Sample App

Skeleton application showing usage of singleton component to render pages

## Usage



## History

|-----------|------|---------------------
|2019-09-19 | THP  | Created

*/


component{
	// Application properties
	this.name = "clikpagesample";
	this.sessionManagement = true;
	this.sessionTimeout = createTimeSpan(0,0,30,0);
	this.setClientCookies = true;
	this.sessioncookie.secure = true;

	// Java Integration
	// this.javaSettings = { 
	// 	loadPaths = [ ".\lib" ], 
	// 	loadColdFusionClassPath = true, 
	// 	reloadOnChange= false 
	// };

	// application start
	public boolean function onApplicationStart(){
		
		startApp();
		return true;
	}


	public void function startApp(){
		try {
			application.pageObj = createObject("component", "clikpage.pageObj").init();
			application.pageObj.content.title = "Test app";
			application.pageObj.content.static_css["fontawesome"] =1;
			application.pageObj.content.static_css["reset"] =1;
			application.pageObj.content.static_css["forms"] =1;
			application.pageObj.content.static_css["colors"] =1;
			// typically you use the static defs for standard libraries that get reused across
			// projects and use the _files fields for site-specific stuff
			// that isn't a hard and fast rule: you may prefer to use the static files for everything
			ArrayAppend(application.pageObj.content.css_files,"styles/clikpage_sample.css");
		}
		catch (Any e) {
			writeOutput("error loading application");
			writeDump(e);
			abort;
		}
	}
		
	// request start
	public void function onRequestStart( string targetPage ){
		//TODO: take out
		startApp();
		request.rc = StructNew();
		request.prc = StructNew();

		StructAppend(request.rc,url);
		StructAppend(request.rc,form,true);

		param name="request.reload" default="0" type="boolean";

		request.prc.content = application.pageObj.getContent();
	}

	public void function onRequest( string targetPage ){
		
		// you can either save the content like this or (better)
		// not use the standard output at all and ensure everything appends
		// to content.body
		savecontent variable="request.prc.content.body" {
			cfinclude(template=arguments.targetPage);
		}

	}

	public void function onRequestEnd(){
		// you can do things like this. Typically you would have a "layout" defined at this stage
		request.prc.content.body = "<div class=""outer""><h1>#request.prc.content.title#</h2>" & request.prc.content.body & "</div>";
		writeOutput(application.pageObj.buildPage(request.prc.content));
	}

	public void function onSessionStart(){
		
	}

	public void function onSessionEnd( struct sessionScope, struct appScope ){
		
	}


	

}