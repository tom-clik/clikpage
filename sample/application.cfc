/*

# clikpage Sample App

Skeleton application showing usage of singleton component to render pages

## Usage



## History

|-----------|------|---------------------
|2019-09-19 | THP  | Created

*/


component  extends="clikpage.clikpageApplication" {
	// Application properties
	this.name = "clikpagesample";
	this.sessionManagement = true;
	this.sessionTimeout = createTimeSpan(0,0,30,0);
	this.setClientCookies = true;
	this.sessioncookie.secure = true;
	this.componentpaths=[ExpandPath("../..")];

	// Java Integration
	// this.javaSettings = { 
	// 	loadPaths = [ ".\lib" ], 
	// 	loadColdFusionClassPath = true, 
	// 	reloadOnChange= false 
	// };

	// application start
	this.debug = 1;
	public boolean function onApplicationStart(){
		startApp(layoutsFolder=ExpandPath("layouts"),siteDef=ExpandPath("sampleSite.xml"),styledef=ExpandPath("styles/sample_style.xml"));
		return true;
	}

	public void function onRequestStart(targetPage)	 {
		
		// TO DO: remove
		// startApp(layoutsFolder=ExpandPath("layouts"),siteDef=ExpandPath("sampleSite.xml"),styledef=ExpandPath("styles/sample_style.xml"));
		
		requestStart();
	}


	public void function onSessionStart(){
		
	}

	public void function onSessionEnd( struct sessionScope, struct appScope ){
		
	}


	

}