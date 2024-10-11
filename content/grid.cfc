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
		
		this.panels = [
			{"name":"Item","panel":"item","selector":" > *"},
			{"name":"Caption","panel":"caption","selector":" .caption"}
		];

		this.styleDefs = [
			"grid-mode":{"name"="Grid mode","type"="list","default"="none","setting":1,"options":[
					{"name"="None","value"="none","description"="Don't use a grid. Use this setting to turn off a grid in smaller screen sizes."},
					{"name"="Auto fit","value"="fit","description"="Fit as many items as possible into the grid according to the minimum column size."},
					{"name"="Auto fill","value"="fill","description"="Fit as many items as possible into the grid according to the minimum column size but don't stretch as much."},
					{"name"="Fixed width","value"="fixedwidth","description"="A legacy mode in which all columns have the same width"},
					{"name"="Columns","value"="fixed","description"="A grid with a fixed number of equal columns. Set the number in 'Columns'."},
					{"name"="Set columns","value"="columns","description"="A grid with a width definition for the columns e.g. '20% auto 30% '"},
					{"name"="Set rows","value"="rows","description"="A grid with a height definition for the rows e.g. '20% auto 30% '"},
					{"name"="Named positions","value"="named","description"="An advanced mode in which you specify the specific order of the content items."},
					{"name"="Flex","value"="flex","description"="The items in the grid will be as wide/high as their content"}
				],
				"description":"Select the way your grid is laid out"
			},
			"grid-width":{"name":"Item width","type"="dimension","default"="180px","description":"Minimum width of columns for an auto grid or specific width for a fixed width grid.",
				"dependson":"grid-mode","dependvalue":["auto","fixedwidth"]},
			"grid-max-width":{"name":"max width","type"="dimension","default"="1fr","note"="Not sure this should be exposed","hidden":1,"description":"","hidden":1},
			"grid-max-height":{"name":"Max item height","type"="dimension","default"="auto","description":"Maximum height of items in grid"},
			"grid-columns":{"name"="Columns","type"="integer","default"="2","description"="Number of columns for a fixed column grid":"grid-mode","dependvalue":"fixed"},
			"grid-gap":{"type"="dimension","name":"Gap","default":0,"description":"Gap between grid items"},
			"grid-template-columns":{"name":"Template columns","type"="text","description":"Column sizes when using fixed columns or named template areas","dependson":"grid-mode","dependvalue":["named","rows"],"inherit":1,"default":"auto"},
			"grid-template-rows":{"name":"Template rows","description":"Row sizes when using set rows or named items mode","type"="dimensionlist","dependson":"grid-mode","dependvalue":["named","rows"],"default":"auto"},
			"grid-template-areas":{"name"="Template areas","type"="text","dependson":"grid-mode","dependvalue":"templateareas","description":"","inherit":1,"default":""},
			"flex-direction":{"name":"Flexible grid direction","type"="list","default"="row","options"=[
				{"name"="Row","value"="row","description"=""},
				{"name"="Row reverse","value"="row-reverse","description"=""},
				{"name"="Column","value"="column","description"=""},
				{"name"="Column reverse","value"="column-reverse","description"=""}
				],"dependson":"grid-mode","dependvalue":"flex","description":"The direction in which a flexible grid is shown"},
			"justify-content":{"name"="Alignment","type"="list","options"=[
				{"name"="Start","value"="flex-start","description"=""},
				{"name"="Center","value"="center","description"=""},
				{"name"="End","value"="flex-end","description"=""},
				{"name"="Space around","value"="space-around","description"=""},
				{"name"="Space evenly","value"="space-evenly","description"=""},
				{"name"="Space betweem","value"="space-between","description"=""}
				],"description":"Orientation in the same axis to the grid direction. This usually means horiztonal."},
			"align-content":{"name"="Row Alignment","type"="list","options"=[
				{"name"="Start","value"="flex-start","description"=""},
				{"name"="Center","value"="center","description"=""},
				{"name"="End","value"="flex-end","description"=""},
				{"name"="Space around","value"="space-around","description"=""},
				{"name"="Space evenly","value"="space-evenly","description"=""},
				{"name"="Space betweem","value"="space-between","description"=""}
				],"description":"Alignment of multiple rows","hidden":1},
			"align-items":{"name"="Cross align","type"="list","options"=[
				{"name"="Start","value"="flex-start","description"=""},
				{"name"="Center","value"="center","description"=""},
				{"name"="End","value"="flex-end","description"=""}
				],"description":"Orientation in the opposite axis to the grid direction. This usually means vertical."},
			
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

	private string function css_settings(required string selector, required struct styles, boolean debug=true) {
		
		return variables.contentObj.settingsObj.grid(argumentCollection = arguments);
	
	}	
	

}