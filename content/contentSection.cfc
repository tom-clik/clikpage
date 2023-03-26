/**

@hint Base component for content sections

The content section components are static components that operate on structs of data.

A content section is created using the new() method and passed by reference to each method.

*/

component {

	variables.type = "base";
	variables.title = "Base component";
	variables.description = "The base component shouldn't be used directly.";
	variables.defaults = {
		"title"="Untitled",
		"data"={"text":"Undefined base component"}
	};

	function init(required content contentObj) {
		
		variables.contentObj = arguments.contentObj;
		
		variables.static_css = {};
		variables.static_js = {};

		this.classes = "cs-" & variables.type;		

		// See selectorQualifiedCSS. Shorthand to apply css to sub elements
		this.selectors = [
			{"name"="main", "selector"=""}
		];
			
		// some cs have hover states etc
		this.states = [
			{"state"="main", "selector"="","name":"Main","description":"The main state"},
			{"state"="hover", "selector"=":hover","name":"Hover","description":"Hover state"}

		];

		// panels for generic css styling.
		this.panels = [
		];

		/*
		 define all available settings for this CS
		 Any styles not added to settings (see below) will be written out as a CSS var
		
		 E.g.
		 	this.styleDefs = [
				"orientation":{"type":"orientation"},
				"link-color":{"type":"color"}
			]		
		 Basically freeform at this time. Will be formalised when we 
		 come to build the editing system!

		 Also maybe rework so the settings are generated automatically
		 from this struct which would have default and custom=bool in it.
		*/
		this.styleDefs = [=];

		// apply to main settings struct
		// See above we should probably create this automatically. (DONE: see updateDefaults())
		// also try to avoid using this.
		this.defaultStyles = {};

		/*
		 Keys of this struct are treated as special cases requiring logic to produce CSS
		 
		 They are not added directly to the CSS. Not the values of the struct are the default.

		 NB see note above. Possibly we should create this automatically.
		 
		 e.g.	
			this.settings = [
				"orientation": "horizontal",
				"popup":"false",
				"padding-adjust": true
			];
		*/
			
		this.settings = [=];

		return this;
	}

	public struct function getDetails() {
		return {
			"title"=variables.title,
			"description"=variables.description
		};
	}

	/**
	 * @hint Update settings and defaults from styleDefs
	 *
	 * Some cs still do this manually. This is deprecated
	 */
	public void function updateDefaults() {
		// settings inherit across media
		this.settings = {};
		// defaults only need applying to root
		this.defaultStyles = {};
		for (local.setting_code in this.styleDefs){
			local.setting  = this.styleDefs[local.setting_code];
			if (StructKeyExists(local.setting,"default")) {
				this.defaultStyles[local.setting_code] = local.setting.default;
				if (StructKeyExists(local.setting,"inherit")) {
					this.settings[local.setting_code] = local.setting.default;
				}
			}
			
		}

	}

	/**
	 * @hint Create a new content section 
	 * 
	 * Better to use the new method in the content obj.
	 * 
	 */
	public struct function new(
		required string id, 
				 string class="", 
				 struct data,
				 string title, 
				 string content,
				 string image, 
				 string caption, 
				 string link,
				 struct style={}
				 ) {

		var cs = {"id"=arguments.id, "type"=variables.type, "settings":{}};
		
		variables.contentObj.deepStructAppend(cs,arguments,true);
		variables.contentObj.deepStructAppend(cs,variables.defaults,false);
		
		return cs;
	}

	/**
	 * Generate HTML for the content section
	*/
	public string function html(required struct content) {
		return arguments.content.content;
	}

	/**
	 * @hint Get CSS for complex settings
     *
	 * Some components have settings that don't translate exactly to css
	 * properties e.g. menu direction is vertical | horizontal which is translated into grid functions
	 * 
	 * The css often needs applying to sub selectors. These are defined in this.selectors which provides 
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
		ret.main &= "/* Main CSS goes here */\n";

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
	 * These often need applying to a css pseudo class or sub element.
	 *
	 * The details of each state are in this.states
	 *
	 * Note the "main" state has the settings in the root of the struct while other states are
	 * keys of main, e.g.
	 *
	 * {
	 *    "link-color": "darkcolor",
	 *    "hi": {
	 *    	"link-color": "accentcolor"
	 *    },
	 *    "hover": {
	 *    	"link-color": "lightcolor"
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

			ret &= "/* #serializeJSON(local.state_styles) # */\n";

			ret &= "/* writing styles for state #local.state.state# */\n";

			ret &= arguments.selector & local.state.selector & " {\n";
			
			for (local.style in this.styleDefs) {
				local.def = this.styleDefs[local.style];
				// ignore complex settings
				if (NOT StructKeyExists(this.settings, local.style)) {
					if (StructKeyExists(local.state_styles,local.style)) {
						if (isStruct(local.state_styles[local.style])) {
							throw("incorrect value for #local.style#");
						}
						else {
							switch (local.def.type) {
								case "dimension":
									local.val = variables.contentObj.settingsObj.displayDimension(local.state_styles[local.style]);
								break;
								case "color":
									local.val = variables.contentObj.settingsObj.displayColor(local.state_styles[local.style]);
								break;
								default:
									local.val = local.state_styles[local.style];
								break;
							}
							// css &= this.settingsObj.CSSCommentHeader("Content styling");
							ret &= "\t--#local.style#: " & local.val & ";\n";
						}
					}
					else {
						ret &= "\t/* no style for #local.style# */\n";	
					}
				}
			}

			ret &= variables.contentObj.settingsObj.css(local.state_styles);

			ret &= "}\n";

			// additional panels for plain css styling
			for (local.panel in this.panels) {
				if (StructKeyExists(local.state_styles,local.panel.panel)) {
					ret &= arguments.selector & local.state.selector & " " & local.panel.selector & " {\n" & variables.contentObj.settingsObj.css(local.state_styles[local.panel.panel]) & "}\n";
				}
			}


			
		}
		return ret;
	}
	
	
	

	/**
	 * @hint Generate CSS for the content section
	 *
	 * Each CS type has a combination of "styles" which are simple css vars and "settings"
	 * which require logic to adjust a number of parameters.
	 *
	 * Each cs component is expected to define its own css_settings() function.
	 *
	 * NOTE the "styles" are often saved in the content sections as a convenience. This is a bit unofficial
	 * and contains all the different media. Here stles need to be for the medium required.
	 * 
	 * @styles  Content section settings struct
	 */
	public string function css(required string selector, required struct styles) {
		
		var css_str = css_styles(selector = arguments.selector, styles=arguments.styles);
		css_str &= css_settings(selector = arguments.selector, styles=arguments.styles);
				
		return css_str;

	}


	/**
	 * Get general css (see settingsObj.css()) for all panls
	 * @settings content section settings struct
	 * @selector Css selector for main item (usually #id)
	 *
	 * Think derpecated.
	 */
	public string function panelCss(required struct settings, required string selector) {
		var css = "";
		
		for (local.panel in this.panels) {
			
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
	 * @hint Ensure settings inherit through media hierarchy
	 * 
	 * This is one of the key functions to understand. Say for instance you have a required 
	 * setting "orientation" for a menu. This will have a default value, but this might be 
	 * overridden in "main". When we want to get the value for mobile, it should inherit 
	 * from main or even mid.
	 *
	 * NB shouldn't really be public.
	 * 
	 */
	public void function inheritSettings(required struct settings, required struct media) {
		
		var currentSettings =duplicate(this.settings);
		
		for (local.medium in arguments.media) {
			
			if (NOT StructKeyExists(arguments.settings,local.medium)) {
				arguments.settings[local.medium] = {};
				for (local.setting in this.settings) {
					arguments.settings[local.medium][local.setting] = currentSettings[local.setting];
					
				}
				
			}
			else {
				for (local.setting in this.settings) {
					if (NOT StructKeyExists(arguments.settings[local.medium],local.setting) ) {
						arguments.settings[local.medium][local.setting] = currentSettings[local.setting];
					}
				}
				currentSettings = duplicate(arguments.settings[local.medium]);
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
	
	public string function getClasses(required struct content) {
		
		return this.classes;
	}
	


}