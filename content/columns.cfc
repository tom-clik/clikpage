component extends="contentSection" {

	variables.type = "grid";
	variables.title = "grid";
	variables.description = "CSS grid";
	variables.defaults = {
		"title"="Untitled grid container",
		"content"="Undefined grid content",
	};
	
	function init(required content contentObj) {
		
		super.init(arguments.contentObj);
		
		// static css definitions
		variables.static_css = {"columns"=1};
		
		this.panels = [
			{"name":"Item","panel":"item","selector":" > *"},
			{"name":"Caption","panel":"caption","selector":" .caption"}
		];

		this.styleDefs = [
			"header-fixed":{ "type"="boolean", "title"="Fixed header","default"=" 0"},
			"footer-fixed":{ "type"="boolean", "title"="Fixed footer","default"=" 0"},
			"menupos ":{ "type"="list", "title"="Menu position","default"="static","options"=[{"value":"static"},{"value":"fixed"},{"value":"slide"}]},
			"menu":{ "type"="list", "title"="Show menu column","default"="open","options"=[{"value":"open"},{"value":"close"}]},
			"xcol":{ "type"="list", "title"="Show extra column","default"="open","options"=[{"value":"open"},{"value":"close"}]}, 
			"framed":{ "type"="boolean", "title"="Frame site","default"=" 0"},
			"site-align":{ "type"="halign", "title"="Align site","default"="center"},
			"menu-width":{ "type"="dimension", "title"="Menu column width","default"="220px"},
			"xcol-width":{ "type"="dimension", "title"="Extra column width","default"="160px"},
			"header-height":{ "type"="dimension", "title"="Header height","default"=" 60px"},
			"site-width":{ "type"="dimension", "title"="Site width","default"="960px"},
			"footer-height":{ "type"="dimension", "title"="Footer height","default"="60px"},
			"menu-anim-time":{ "type"="time", "title"="Menu animation time","default"="0.2s"}

			/* adjustment vars 
			These either need setting explicitly or programatically with something like:

			let menuPad = window.getComputedStyle(document.querySelector('#menu')).paddingTop;
			document.body.style.setProperty('--menu-top-padding', menuPad);
			*/

			// --menu-top-padding: 0px; /* Should be the same as the "top" padding of the menu container when set to sticky */
			// --xcol-top-padding:0px ;/* Should be the same as the "top" padding of the xcol container when set to sticky */

			// /* Individual components of "body" padding */
			// --site-top-padding: 0px;
			// --site-right-padding: 0px;
			// --site-bottom-padding: 0px;
			// --site-left-padding: 0px;
		];

		updateDefaults();

		return this;
		
	}		

	private string function css_settings(required string selector, required struct styles, boolean debug=true) {
		
		return variables.contentObj.settingsObj.grid(argumentCollection = arguments);
	
	}	
	

}