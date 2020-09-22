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
			application.pageObj.title = "Test app";

		}
		catch (Any e) {
			writeDump(e);
			abort;
		}
	}
		
	// request start
	public void function onRequestStart( string targetPage ){
		
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
			include template="#arguments.targetPage#";
		}
		
	}

	public void function onRequestEnd(){
		// you can do things like this. Typically you would have a "layout" defined at this stage
		request.prc.content.body = "<h1>#request.prc.content.title#</h2>" & request.prc.content.body;
		writeOutput(application.pageObj.buildPage(request.prc.content));
	}

	public void function onSessionStart(){
		
	}

	public void function onSessionEnd( struct sessionScope, struct appScope ){
		
	}


	

}