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

		this.styleDefs =arguments.contentObj.settingsObj.columnDefs;
		
		updateDefaults();

		return this;
		
	}		

	private string function css_settings(required string selector, required struct styles, boolean debug=true) {
		
		return variables.contentObj.settingsObj.grid(argumentCollection = arguments);
	
	}	
	

}