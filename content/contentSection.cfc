/**

@hint Base component for content sections

The content section components are static components that operate on structs of data.

A content section is created using the new() method and passed by reference to each method.

*/

component {

	function init(required contentObj contentObj) {
		
		variables.contentObj = arguments.contentObj;
		variables.type = "base";
		variables.title = "Base component";
		variables.description = "The base component shouldn't be used directly.";
		variables.defaults = {
			"title"="Untitled",
			"content"="Undefined base component",
		};
		variables.static_css = {};
		variables.static_js = {};
		variables.settings = {

		};

		variables.panels = [];

		variables.subpanels = [
			{"name":"hover","selector":":hover"},
			{"name":"hi","selector":".hi"}
			];

		return this;
	}

	public struct function getDetails() {
		return {
			"title"=variables.title,
			"description"=variables.description
		};
	}

	/** Create a new content section */
	public struct function new(required string id, string type=variables.type, string class, string title, string content,string image, string caption, string link) {
		var cs = {"id"=arguments.id,"type"=arguments.type, "class"={}};
		if (StructKeyExists(arguments,"content")) {
			cs["content"] = arguments.content;
		}
		if (StructKeyExists(arguments,"image")) {
			cs["image"] = arguments.image;
		}
		if (StructKeyExists(arguments,"caption")) {
			cs["caption"] = arguments.caption;
		}
		if (StructKeyExists(arguments,"title")) {
			cs["title"] = arguments.title;
		}
		if (StructKeyExists(arguments,"link")) {
			cs["link"] = arguments.link;
		}
		if (StructKeyExists(arguments,"class")) {
			for (local.className in ListToArray(arguments.class," ")) {
				cs["class"][local.className] = 1;
			}
		}
		
		StructAppend(cs,variables.defaults,false);
		cs.class["cs-#variables.type#"] = 1;
		return cs;
	}

	public string function html(required struct content) {
		return arguments.content.content;
	}

	public string function css(required struct settings, required string selector) {
		return "/* #variables.type# css no custom css */\n";
	}

	public string function panelCss(required struct settings, required string selector) {
		var css = "";
		
		for (local.panel in variables.panels) {
			
			if (StructKeyExists(arguments.settings,local.panel.name)) {
				css &= arguments.selector & local.panel.selector & "{\n";
				css &= variables.contentObj.settingsObj.css(arguments.settings[local.panel.name]);
				css &= "}\n";
				
				for (local.subpanel in variables.subpanels) {
					if (StructKeyExists(arguments.settings[local.panel.name], local.subpanel.name)) {
						css &= arguments.selector & local.panel.selector & local.subpanel.selector & "{\n";
						css &= variables.contentObj.settingsObj.css(arguments.settings[local.panel.name][local.subpanel.name]);
						css &= "}\n";
					}
				}			
			}


		}

		return css;
	}

	/**
	 * Return standard html for an item with a title, text, and image
	 *
	 * This can be used on its own (general) or as part of a listing
	 * 
	 * @content  Content section
	 * @content  item settings
	 * @classes  Pass in struct by reference to retrun required classes for the wrapping div.
	 */
	public string function itemHtml(required struct content, struct settings, struct classes) {
		
		local.hasLink = StructKeyExists(arguments.content,"link");

		var linkStart = (local.hasLink) ? "<a href='#arguments.content.link#'>" : "";
		var linkEnd = (local.hasLink) ? "</a>" : "";

		arguments.classes["item"] = 1;
		if (arguments.settings.heading_position == "top") {
			arguments.classes["htop"] = 1;
		}
		if (arguments.settings.mobile_heading_position != "top") {
			arguments.classes["munder"] = 1;

		}
		if (!arguments.settings.showtitle) {
			arguments.classes["notitle"] = 1;

		}
		switch (arguments.settings.align) {
			case "left": case "right":
			arguments.classes[arguments.settings.align] = 1;
		}
		var cshtml = "";

		cshtml &= "\t<" & arguments.settings.titletag & " class='title'>" & linkStart & arguments.content.title & linkEnd &  "</" & arguments.settings.titletag & ">\n";
		cshtml &= "\t<div class='imageWrap'>\n";
		if (StructKeyExists(arguments.content,"image")) {
			cshtml &= "\t\t<img src='" & arguments.content.image & "'>\n";
			if (StructKeyExists(arguments.content,"caption")) {
				cshtml &= "\t\t<div class='caption'>" & arguments.content.caption & "</div>\n";
			}
		}
			cshtml &= "\t</div>\n";

		cshtml &= "\t<div class='textWrap'>";
		cshtml &= arguments.content.content;
		if (local.hasLink && StructKeyExists(arguments.settings,"morelink")) {
			cshtml &= "<span class='morelink'>" & linkStart & arguments.settings.morelink & linkEnd & "</span>";
		}
		cshtml &= "</div>";

		return cshtml;

	}



	/**
	 * @hint Update settings with required values
	 * 
	 * This is one of the key functions to understand. Say for instance you have a required setting "orientation" for
	 * a menu. This will have a default value, but this might be overridden in "main". When we want to get the value
	 * for mobile, it should inherit from main or mid.
	 *
	 * At the same time, we don't want to create settings for a medium where there are none.
	 *
	 * If you want a default for mobile that's different, use the styling to inherit from a base value.
	 * 
	 */
	public struct function settings(required struct content, required array media ) {
		
		if (! StructKeyExists(arguments.content,"settings")) {
			arguments.content["settings"] = {
				"main" = {}
			};	
		}
		else {
			fnDeepStructAppend(arguments.content["settings"], {"main" = {}}, false);
		}

		var currentSettings = Duplicate(variables.settings);

		for (local.medium in arguments.media) {
			if (StructKeyExists(arguments.content["settings"],local.medium.name)) {
				fnDeepStructAppend(arguments.content["settings"][local.medium.name],currentSettings,false);
				/** if a value is defined in the styling, use it for this and subsequent media */
				fnDeepStructUpdate(currentSettings,arguments.content["settings"][local.medium.name]);
				
			}
		}

		return arguments.content["settings"];
	}
	
	public struct function getStaticCss() {
		return variables.static_css;
	}

	public struct function getStaticJs() {
		return variables.static_js;
	}

	public string function onready(required struct content) {
		var js = "";

		return js;
	}

	/**
	 * Appends the second struct to the first.
	 */
	void function fnDeepStructAppend(struct struct1, struct struct2, overwrite="true") output=false {
		
		for(local.key IN arguments.struct2){
			if(StructKeyExists(arguments.struct1,local.key) AND 
				IsStruct(arguments.struct2[local.key]) AND 
				IsStruct(arguments.struct1[local.key])){
				fnDeepStructAppend(arguments.struct1[local.key],arguments.struct2[local.key],arguments.overwrite);
			}
			else if (arguments.overwrite OR NOT StructKeyExists(arguments.struct1,local.key)){
				arguments.struct1[local.key] = Duplicate(arguments.struct2[local.key]);
			}
		}
	}

	/**
	 * Updates a struct with values from second struct
	 */
	void function fnDeepStructUpdate(struct struct1, struct struct2) output=false {
		
		for(local.key IN arguments.struct1){
			if(StructKeyExists(arguments.struct2,local.key)) {
				if (IsStruct(arguments.struct1[local.key])) {
					fnDeepStructUpdate(arguments.struct1[local.key],arguments.struct2[local.key]);
				}
			}
			else {
				arguments.struct1[local.key] = Duplicate(arguments.struct2[local.key]);
			}
		}
	}


}