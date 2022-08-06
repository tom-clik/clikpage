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

		variables.panels = [];

		variables.subpanels = [
			{"name":"hover","selector":":hover"},
			{"name":"hi","selector":".hi"}
			];

		this.selectors = [
			{"name"="main", "selector"=""}
		];

		this.states = [
			{"state"="main", "selector"="","name":"Main","description":"The main state"}
		];

		this.styleDefs = [
						
		];

		// see e.g. menu.cfc for formal settings definition
		this.settings = [=];

		return this;
	}

	public struct function getDetails() {
		return {
			"title"=variables.title,
			"description"=variables.description
		};
	}

	/** Create a new content section */
	public struct function new(
		required string id, 
				 string class, 
				 string title, 
				 string content,
				 string image, 
				 string caption, 
				 string link
				 ) {

		var cs = {"id"=arguments.id, "type"=variables.type, "class"={}};
		
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

	
	/**
	 * @hint Get CSS for complex settings
     *
	 * Some components have settings that don't translate exactly to css
	 * properties e.g. menu direction is vertical | horizontal which is translated into grid functions
	 * 
	 * The css often needs applying to sub selectors. These are be defined in this.selectors which provides 
	 * a shorthand when we are building the css.
     *
     * More complex components will override this function and provide a range of settings.
	 */
	private string function css_settings(required string selector, required struct styles) {
		// To do this the styling often has to be applied to sub elements scuh as <ul> for menus
		// We therefore maintain a structkeyed by the "name" of the selector as defined in 
		// this.selectors.
		var ret = getSelectorStruct();

		// As we build the CSS we append to the different struct keys
		// here "main" is nothing to do with media. See this.selectors.
		// a menu function might do ret.ul &= "display:flex;\n"
		ret.main &= "/-- Main CSS goes here --/\n";

		// Once we've built this struct we write it out as a string using this function
		return selectorQualifiedCSS(selector=arguments.selector, css_data=ret);
	}

	/**
	 * @hint Get CSS vars for simple settings
	 *
	 * Any simple property that translated directly into a css property is applied as a var here
	 *
	 * Some content sections have "states" such as rollover or hi (highlighted state)
	 *
	 * These often need applying to a css pseduo class or sub element.
	 *
	 * The details of each state are in this.states
	 *
	 * Note the "main" state has the settings in the root of the struct while other states are
	 * keys of main, e.g.
	 *
	 * {
	 *    "link-color": "darkcolor",
	 *    "hi": {
	 *    	"link-color": accentcolor"
	 *    },
	 *    "hover": {
	 *    	"link-color": "lightcolor""
	 *    }   
	 * }
	 *
	 * 
	 * @selector    Base CSS selector string e.g. #csid 
	 * @styles      styles for the specific content section and medium 
	 * @return      
	 */
	private string function css_styles(required string selector, required struct styles) {
		
		var ret = "";

		for (local.state in this.states) {
			// main has no sub key. Other states dumped into setting struct
			if ( local.state.state eq "main") {
				local.state_styles = arguments.styles;
			}
			else {
				if (NOT StructKeyExists(arguments.styles,local.state.state)) {
					continue;
				}
				local.state_styles = arguments.styles[local.state.state];
			}

			ret &= arguments.selector & local.state.selector & " {\n";
			for (local.stylecode in this.styleDefs) {
				if (StructKeyExists(local.state_styles,local.stylecode)) {
					local.styledef = this.styleDefs[local.stylecode];
					switch (local.styledef.type)  {
						case "color":
								local.val =  "var(--" & local.state_styles[local.stylecode] & ")";
								break;
						default:
								local.val =  local.state_styles[local.stylecode];
					}
					ret &= "\t--#local.stylecode#: " & local.val  & ";\n";
				}
				else {
					ret &= "\t/-- no style for #local.stylecode# --/\n";	
				}
			}
			ret &= "}\n";
		}
		return ret;
	}
	
	
	/**
	Pending a formal settings definition this is a placeholder to give use inheritance
	on the settings that need it. See this.settings  in e.g. menu.cfc */
	public void function checkInheritance(required struct complete_styles) {
		
		local.inheritedSettings = {};
		local.media = variables.contentObj.getMedia(arguments.complete_styles);
		
		for (local.mediumname in local.media) {
			
			if (StructKeyExists(arguments.complete_styles, local.mediumname)) {
				
				for (local.settingname in this.settings) {
					local.setting = this.settings[local.settingname];
					if (StructKeyExists(arguments.complete_styles[local.mediumname], local.settingname)
						AND local.setting.inherit) {
						local.inheritedSettings[local.settingname] = Duplicate(arguments.complete_styles[local.mediumname][local.settingname]);
					}
				}

				StructAppend(arguments.complete_styles[local.mediumname], local.inheritedSettings, false);
			}
		}

	}


	/**
	 * Generate CSS for the content section
	 * 
	 * @settings  Settings struct with keys for each media size
	 */
	public string function css(required string selector, required struct styles, boolean debug) {
		
		if (NOT structKeyExists(arguments,"debug")) {arguments.debug = variables.contentObj.debug}
		var css_str = "";
		
		checkInheritance(arguments.styles);
		
		local.media = variables.contentObj.getMedia(arguments.styles);
		
		for (local.mediumname in local.media) {
			local.medium = local.media[local.mediumname];
			if (StructKeyExists(arguments.styles,local.mediumname)) {
				css_str &= "/* medium #local.mediumname# */\n";

				local.css_section = "";
				/* content specific stuff */
				if (StructKeyExists(arguments.styles[local.mediumname], variables.type)) {
					local.css_section = css_styles(selector = arguments.selector, styles=arguments.styles[local.mediumname][variables.type]);
					local.css_section &= css_settings(selector = arguments.selector, styles=arguments.styles[local.mediumname][variables.type]);
				}
				/* generic panel styling */
				local.css_section &= arguments.selector & " {\n" & variables.contentObj.settingsObj.css(arguments.styles[local.mediumname]) & "}\n";
				
				for (local.panel in this.panels) {
					if (StructKeyExists(arguments.styles[local.mediumname], local.panel.name)) {
							local.css_section &= arguments.selector & " {\n" & variables.contentObj.settingsObj.css(arguments.styles[local.mediumname]) & "}\n";
					}
				}

				local.screenSize=[];
				if (local.css_section != "") {
					if (StructKeyExists(local.medium,"min")) {
						ArrayAppend(local.screenSize,"min-width: #local.medium.min#px")
					};
					if (StructKeyExists(local.medium,"max")) {
						ArrayAppend(local.screenSize,"max-width: #local.medium.max#px")
					};
					if (ArrayLen(local.screenSize)) {
						local.css_section = "@media screen AND (" & ArrayToList(local.screenSize," AND ") & ") {\n" & local.css_section & "}\n";
					}
					css_str &= local.css_section;
				}
			}

		}
		
		return variables.contentObj.processText(css_str,arguments.debug);

	}


	/**
	 * Get general css (see settingsObj.css()) for all panls
	 * @settings content section settings struct
	 * @selector Css selector for main item (usually #id)
	 */
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

	/* return a struct of blank strings with one key for each selector
	*/
	private struct function getSelectorStruct() {
		var ret = {};
		for (local.selector in this.selectors) {
			ret[local.selector.name] = "";
		}
		return ret;
	}

	/**
	 * @hint Combine css settings struct (keyed by sub selector name) into a single text string
	 * 
	 * helper function for css_settings()
	 *
	 * A content item e.g. a menu will have a main selector e.g. #menu
	 *
	 * Depending on the content type it might have a range of sub selectors like ul > li > a
	 * to which styling is applied. These are defined in the component as an array (this.selectors), a typical entry 
	 * is {"name"="a", "selector"=" > ul > li > a"}
	 *
	 * As we define the css, we create a struct keyed by the selector name e.g. "a" for the above
	 *
	 * This function combines all the entries into a single text string e.g.
	 *
	 * #menu  {styling...}
	 * #menu  > ul > li > a {styling...}
	 * 
	 * @selector  The main selector e.g. #mainmenu or .scheme-flex
	 * @css_data  css style entries keyed by sub selector code (see this.selectors)
	 * @return    the complete CSS
	 */
	private string function selectorQualifiedCSS(required string selector,required struct css_data) {
		var ret = "";
		for (local.selector in this.selectors) {

			if (StructKeyExists(arguments.css_data, local.selector.name) AND arguments.css_data[local.selector.name] neq "") {
				ret &= arguments.selector & local.selector.selector & " " & "{\n";
				ret &= variables.contentObj.indent(arguments.css_data[local.selector.name],1);
				ret &= "}\n";

			}
		}
		return ret;
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
			variables.contentObj.fnDeepStructAppend(arguments.content["settings"], {"main" = {}}, false);
		}

		var currentSettings = Duplicate(variables.settings);

		for (local.medium in arguments.media) {
			if (StructKeyExists(arguments.content["settings"],local.medium.name)) {
				variables.contentObj.fnDeepStructAppend(arguments.content["settings"][local.medium.name],currentSettings,false);
				/** if a value is defined in the styling, use it for this and subsequent media */
				variables.contentObj.fnDeepStructUpdate(currentSettings,arguments.content["settings"][local.medium.name]);
				
			}
		}

		return arguments.content["settings"];
	}

	/**
	Pending a formal settings definition this is a placeholder to give use inheritance
	on the settings that need it. See this.settings  in e.g. menu.cfc */
	public void function checkInheritance(required struct complete_styles) {
		
		local.inheritedSettings = {};
		local.media = variables.contentObj.getMedia(arguments.complete_styles);
		
		for (local.mediumname in local.media) {
			
			if (StructKeyExists(arguments.complete_styles, local.mediumname)) {
				
				for (local.settingname in this.settings) {
					local.setting = this.settings[local.settingname];
					if (StructKeyExists(arguments.complete_styles[local.mediumname], local.settingname)
						AND local.setting.inherit) {
						local.inheritedSettings[local.settingname] = Duplicate(arguments.complete_styles[local.mediumname][local.settingname]);
					}
				}

				StructAppend(arguments.complete_styles[local.mediumname], local.inheritedSettings, false);
			}
		}

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

}