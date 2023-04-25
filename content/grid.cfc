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
			{"name"="item", "selector"=" > *"}
		];

		this.panels = [
			{"name":"Item","panel":"item","selector":" > *"},
			{"name":"Caption","panel":"caption","selector":" .caption"}
		];

		this.styleDefs = [
			"grid-mode":{"name"="Grid mode","type"="list","default"="none","inherit":1,"options":[
					{"name"="None","value"="none","description"="Don't use a grid. Use this setting to turn off a grid in smaller screen sizes."},
					{"name"="Auto fit","value"="auto","description"="Fit as many items as possible into the grid according to the minimum column size."},
					{"name"="Fixed width","value"="fixedwidth","description"="A legacy mode in which all columns have the same width"},
					{"name"="Fixed columns","value"="fixedcols","description"="A grid with a fixed number of columns. Set either a number in 'Columns' or a width definition e.g. 20% auto 30% in 'Template columns'"},
					{"name"="Named positions","value"="templateareas","description"="An advanced mode in which you specify the specific order of the content items."},
					{"name"="Flex","value"="flex","description"="The items in the grid will be as wide/high as their content"}
				],
				"description":"Select the way your grid is laid out"
			},
			"grid-fit":{"name"="Auto fill mode","type"="list","default"="auto-fit","inherit":1,"options"=[
					{"name"="Fit","value"="auto-fit","description"=""},
					{"name"="Fill","value"="auto-fill","description"=""}
				],
				"description":"How an auto grid is filled up. Use `Fit` unless you know you want fill."
			},
			"grid-width":{"name":"Item width","type"="dimension","default"="180px","description":"Minimum width of columns for an auto grid or specific width for a fixed width grid."},
			"grid-max-width":{"name":"max width","type"="dimension","default"="1fr","note"="Not sure this should be exposed","hidden":1,"description":""},
			"grid-columns":{"name"="Columns","type"="integer","default"="2","description"="Number of columns for a fixed column grid (only used if Template columns is not specified","dependson":"grid-mode","dependvalue":"fixedcols","inherit":1},
			"grid-gap":{"type"="dimension","name":"Gap","default":0,"description":"Gap between grid items"},
			"grid-template-columns":{"name":"Template columns","type"="text","description":"Column sizes when using fixed columns or named template areas","dependson":"grid-mode","dependvalue":"templateareas,fixedcols","inherit":1,"default":""},
			"grid-template-rows":{"name":"Template rows","description":"Row sizes when using a named items mode","type"="dimensionlist","dependson":"grid-mode","dependvalue":"templateareas","inherit":1,"default":""},
			"grid-template-areas":{"name"="Template areas","type"="text","dependson":"grid-mode","dependvalue":"templateareas","description":"","inherit":1,"default":""},
			"justify-content":{"name"="Alignment","type"="list","options"=[
				{"name"="Start","value"="flex-start","description"=""},
				{"name"="Center","value"="center","description"=""},
				{"name"="End","value"="flex-end","description"=""},
				{"name"="Space around","value"="space-around","description"=""},
				{"name"="Space evenly","value"="space-evenly","description"=""},
				{"name"="Space betweem","value"="space-between","description"=""}
			],"description":"Orientation in the same axis to the grid direction. This usually means horiztonal."},
			"align-items":{"name"="Cross align","type"="list","options"=[
				{"name"="Start","value"="flex-start","description"=""},
				{"name"="Center","value"="center","description"=""},
				{"name"="End","value"="flex-end","description"=""}
			],"description":"Orientation in the opposite axis to the grid direction. This usually means vertical."},
			"flex-direction":{"name":"Flexible grid direction","type"="list","default"="row","options"=[
				{"name"="Row","value"="row","description"=""},
				{"name"="Row reverse","value"="row-reverse","description"=""},
				{"name"="Column","value"="column","description"=""},
				{"name"="Column reverse","value"="column-reverse","description"=""}
			],"dependson":"grid-mode","dependvalue":"flex","description":"The direction in which a flexible grid is shown"},
			"flex-stretch":{"name":"Flex stretch","dependson":"grid-mode","dependvalue":"flex","description":"Stretch out the items to fill the available space","type"="boolean","default"="0"},
			"flex-wrap":{"name":"Flex wrap","dependson":"grid-mode","dependvalue":"flex","description":"Wrap items onto multiple lines","type"="list","default"="wrap","options"=[
				{"name"="Wrap","value"="wrap","description"=""},
				{"name"="No Wrap","value"="nowrap","description"=""},
				{"name"="Wrap reverse","value"="wrap-reverse","description"=""}
				]}
		];

		updateDefaults();

		return this;
		
	}		

	private string function css_settings(required string selector, required struct styles) {
		
		var data = getSelectorStruct();
		
		variables.contentObj.settingsObj.grid(settings=arguments.styles,out=data);

		// switch (arguments.styles["grid-mode"]) {
		// 	case "none":
		// 		data.main &= "\tdisplay:block;\n";
		// 		break;
		// 	case "auto":
		// 		data.main &= "\tdisplay:grid;\n";
		// 		data.main &= "\tgrid-template-columns: repeat(#arguments.styles["grid-fit"]#, minmax(#arguments.styles["grid-width"]#, #arguments.styles["grid-max-width"]#));\n";

		// 		break;	
		// 	case "fixedwidth":
		// 		data.main &= "\tdisplay:grid;\n";
		// 		data.main &= "\tgrid-template-columns: repeat(#arguments.styles["grid-fit"]#, #arguments.styles["grid-width"]#);\n";
		// 		break;	
		// 	case "fixedcols":
		// 		data.main &= "\tdisplay:grid;\n";
		// 		// specified column width e.g. 25% auto 15% - this is the most useful application of this mode
		// 		if (StructKeyExists(arguments.styles,"grid-template-columns") AND arguments.styles["grid-template-columns"] neq "") {
		// 			data.main &= "\tgrid-template-columns: " & arguments.styles["grid-template-columns"] & ";\n";
		// 		}
		// 		// specified number of columns
		// 		else if (StructKeyExists(arguments.styles,"grid-columns") AND isValid("integer", arguments.styles["grid-columns"])) {
		// 			data.main &= "\tgrid-template-columns: repeat(" & arguments.styles["grid-columns"] & ",1fr);\n";
		// 		}
		// 		// All columns in one row -- not a very good idea.
		// 		else {
		// 			data.main &= "\tgrid-template-columns: repeat(auto-fit, minmax(20px, max-content));\n";
		// 		}
				
		// 		break;	

		// 	case "templateareas":
		// 		if (NOT StructKeyExists(arguments.styles,"grid-template-areas")) {
		// 			throw("Grid mode templateareas requires grid-template-areas to be set");
		// 		}
		// 		data.main &= "\tgrid-template-areas:" & arguments.styles["grid-template-areas"] & ";\n";
		// 		if (StructKeyExists(arguments.styles,"grid-template-columns") AND arguments.styles["grid-template-columns"] neq "") {
		// 			data.main &= "\tgrid-template-columns: " & arguments.styles["grid-template-columns"] & ";\n";
		// 		}
		// 		if (StructKeyExists(arguments.styles,"grid-template-rows") AND arguments.styles["grid-template-rows"] neq "") {
		// 			data.main &= "\tgrid-template-rows: " & arguments.styles["grid-template-rows"] & ";\n";
		// 		}
		// 		break;
		// 	case "flex": case "flexstretch":
		// 		data.main = "\tdisplay:flex;\n\tflex-wrap: wrap;\n";
		// 		data.main &= "\tflex-direction:" & arguments.styles["flex-direction"] & "\n";
		// 		if (arguments.styles["grid-mode"] eq "flexstretch") {
		// 			data.item &= "\n\tflex-grow:1;\n;";
		// 		}
		// 		break;

		// }
		
		return selectorQualifiedCSS(selector=arguments.selector, css_data=data);
	}	
	


}