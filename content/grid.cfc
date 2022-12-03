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
		variables.static_css = {"grids"=1};
		
		this.selectors = [
			{"name"="main", "selector"=""},
			{"name"="item", "selector"="> *"}
		];

		this.styleDefs = [
			"grid-mode":{"type"="list","default"="auto","inherit":1,"options":[
					{"name"="None","code"="none","description"=""},
					{"name"="Auto fit","code"="auto","description"=""},
					{"name"="Fixed width","code"="fixedwidth","description"=""},
					{"name"="Fixed columns","code"="fixedcols","description"=""},
					{"name"="Named positions","code"="templateareas","description"=""},
					{"name"="Flex","code"="flex","description"=""},
					{"name"="Flex with stretch","code"="flexstretch","description"=""}
				]
			},
			"grid-fit":{"type"="list","default"="auto-fit","inherit":1,"options"=[]},
			"grid-width":{"type"="dimension","default"="180px"},
			"grid-max-width":{"type"="list","default"="1fr","note"="Note sure this should be exposed"},
			"grid-columns":{"type"="integer","default"="2"},
			"grid-gap":{"type"="dimension"},
			"grid-template-columns":{"type"="dimensionlist"},
			"grid-template-rows":{"type"="dimensionlist"},
			"grid-template-areas":{"type"="dimensionlist"},
			"justify-content":{"type"="list","options"=[
				{"name"="Start","code"="flex-start","description"=""},
				{"name"="Center","code"="center","description"=""},
				{"name"="End","code"="flex-end","description"=""}
			]},
			"align-items":{"type"="list","options"=[
				{"name"="Start","code"="flex-start","description"=""},
				{"name"="Center","code"="center","description"=""},
				{"name"="End","code"="flex-end","description"=""}
			]}
		];
		
		updateDefaults();

		return this;
		
	}		

	private string function css_settings(required string selector, required struct styles) {
		
		var data = getSelectorStruct();
		
		switch (arguments.styles["grid-mode"]) {
			case "none":
				data.main &= "\tdisplay:block;\n";
				break;
			case "auto":
				data.main &= "\tdisplay:grid;\n";
				data.main &= "\tgrid-template-columns: repeat(#arguments.styles["grid-fit"]#, minmax(#arguments.styles["grid-width"]#, #arguments.styles["grid-max-width"]#));\n";

				break;	
			case "fixedwidth":
				data.main &= "\tdisplay:grid;\n";
				data.main &= "\tgrid-template-columns: repeat(#arguments.styles["grid-fit"]#, #arguments.styles["grid-width"]#);\n";
				break;	
			case "fixedcols":
				data.main &= "\tdisplay:grid;\n";
				// specified column width e.g. 25% auto 15% - this is the most useful application of this mode
				if (StructKeyExists(arguments.styles,"grid-template-columns") AND arguments.styles["grid-template-columns"] neq "") {
					data.main &= "\tgrid-template-columns: " & arguments.styles["grid-template-columns"] & ";\n";
				}
				// specified number of columns
				else if (StructKeyExists(arguments.styles,"grid-columns") AND isValid("integer", arguments.styles["grid-columns"])) {
					data.main &= "\tgrid-template-columns: repeat(" & arguments.styles["grid-columns"] & ",1fr);\n";
				}
				// All columns in one row -- not a very good idea.
				else {
					data.main &= "\tgrid-template-columns: repeat(auto-fit, minmax(20px, max-content));\n";
				}
				
				break;	

			case "templateareas":
				if (NOT StructKeyExists(arguments.styles,"grid-template-areas")) {
					throw("Grid mode templateareas requires grid-template-areas to be set");
				}
				data.main &= "\tgrid-template-areas:" & arguments.styles["grid-template-areas"] & ";\n";
				if (StructKeyExists(arguments.styles,"grid-template-columns") AND arguments.styles["grid-template-columns"] neq "") {
					data.main &= "\tgrid-template-columns: " & arguments.styles["grid-template-columns"] & ";\n";
				}
				if (StructKeyExists(arguments.styles,"grid-template-rows") AND arguments.styles["grid-template-rows"] neq "") {
					data.main &= "\tgrid-template-rows: " & arguments.styles["grid-template-rows"] & ";\n";
				}
				break;
			case "flex": case "flexstretch":
				data.main = "\tdisplay:flex;\n\tflex-wrap: wrap;\n\tflex-direction: row;\n";
				if (arguments.styles["grid-mode"] eq "flexstretch") {
					data.item &= "\n\tflex-grow:1;\n;";
				}
				break;

		}
		
		return selectorQualifiedCSS(selector=arguments.selector, css_data=data);
	}	
	


}