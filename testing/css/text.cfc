/*

# Grid CSS component

See implementation notes in clikdesign/Grid_styling.md

*/

component extends="test_csbase" {

	public grid function init() {
		return this;
	}

	public struct function new(struct settings = {}) {
		StructAppend(arguments.settings,{"grid-mode":"auto","grid-fit":"auto-fit","grid-width":"180px","grid-max-width":"1fr","grid-columns":"2","grid-gap":"10px","grid-row-gap":"","grid-template-columns":"","justify-content":"flex-start","align-items":"flex-start"},false);
		switch (arguments.settings["grid-mode"]) {
			case "auto":
				break;
			case "fixedwidth":
			case "fixedcols":
			case "none": case "flex": case "flexstretch":
				break;
			case "templateareas":
				// TODO: check template areas if supplied
				break;
			default:
				local.extendedinfo = {"settings"=arguments.settings};
				throw(
					extendedinfo = SerializeJSON(local.extendedinfo),
					message      = "Incorrect value for grid mode", 
					detail       = "The supplied value was #arguments.settings.mode#. Permissable values are none, auto, fixedwidth, fixedcols, templateareas, flex, flexstretch",
					errorcode    = "grid.new"		
				);
		}	
		return arguments.settings;
	}

	/**
	 * @hint Get CSS vars for simple settings
	 *
	 * TODO: look at merging this back into the base
	 *
	 */
	private string function css_styles(required struct settings) {
		local.css = "";
		for (local.setting in ['grid-gap','row-gap','justify-content','align-items']) {
			if (StructKeyExists(arguments.settings,local.setting) AND trim(arguments.settings[local.setting]) neq "") {
				local.css &= "\t#local.setting#: " & arguments.settings[local.setting] & ";\n";
			}
			else {
				local.css &= "\t/-- no setting for #local.setting# --/\n";	
			}
		}

		return local.css;
	}

	/**
	 * generate CSS for a grid container
	 * 
	 * @settings      [description]
	 * @param  {[type]} required string        selector      [description]
	 * @param  {String} string   item          [description]
	 * @return {[type]}          [description]
	 */
	public string function css(required struct settings, required string selector, string item="> *",boolean debug) {
		local.mode = StructKeyExists(arguments.settings, "grid-mode") ?  arguments.settings["grid-mode"] : "none" ;
		local.css = "";
		local.item_css = "";

		local.css &= css_styles(arguments.settings);


		switch (local.mode) {
			case "none":
				local.css &= "\tdisplay:block;\n";
				break;
			case "auto":
				local.css &= "\tdisplay:grid;\n";
				local.css &= "\tgrid-template-columns: repeat(#arguments.settings["grid-fit"]#, minmax(#arguments.settings["grid-width"]#, #arguments.settings["grid-max-width"]#));\n";

				break;	
			case "fixedwidth":
				local.css &= "\tdisplay:grid;\n";
				local.css &= "\tgrid-template-columns: repeat(#arguments.settings["grid-fit"]#, #arguments.settings["grid-width"]#);\n";
				break;	
			case "fixedcols":
				local.css &= "\tdisplay:grid;\n";
				if (StructKeyExists(arguments.settings,"grid-template-columns") AND  arguments.settings["grid-template-columns"] neq "") {
					local.css &= "\tgrid-template-columns: " & arguments.settings["grid-template-columns"] & ";\n";
				}
				else {
					local.css &= "\tgrid-template-columns: repeat(#arguments.settings["grid-columns"]#, 1fr);\n";
				}
				
				break;	

			case "templateareas":
				local.css &= "\tgrid-template-areas:""" & arguments.settings["grid-template-areas"] & """;\n";
				break;
			case "flex": case "flexstretch":
				local.css = "\tdisplay:flex;\n\tflex-wrap: wrap;\n\tflex-direction: row;\n";
				if (local.mode eq "flexstretch") {
					local.item_css &= "\n\tflex-grow:1;\n;";
				}
				break;

		}

		local.css = arguments.selector & "{\n" & local.css & "}\n";
		if (local.item_css neq "") {
			local.css &= arguments.selector & arguments.item & "{\n" & local.item_css & "}\n";
		}

		return processText(local.css,arguments.debug);;
	}

	/**
	 * Return array of available grid mode settings
	 */
	public static array function modes() {

		return [
			{"name"="Auto fit","code"="auto","description"=""},
			{"name"="Fixed width","code"="fixedwidth","description"=""},
			{"name"="Fixed columns","code"="fixedcols","description"=""},
			{"name"="Named positions","code"="templateareas","description"=""},
			{"name"="Flex","code"="flex","description"=""},
			{"name"="Flex with stretch","code"="flexstretch","description"=""}
		];

	}

	/**
	 * Return array of available grid mode settings
	 */
	public static array function justifyOptions() {

		return [
			{"name"="Start","code"="flex-start","description"=""},
			{"name"="Center","code"="center","description"=""},
			{"name"="End","code"="flex-end","description"=""}
		];

	}


}