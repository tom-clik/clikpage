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
		 
		 They are not added directly to the CSS. Note the values of the struct are the default.

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
	 */
	public void function updateDefaults() {
		
		// list of settings to apply as classes
		this.varClasses = [];
		// Value of defaults for easy lookup
		this.defaultStyles = {};

		// Value of "setting defaults" -- the styles that aren't simple css vars
		this.settings = {};

		try {
			for (local.setting_code in this.styleDefs){
				local.setting  = this.styleDefs[local.setting_code];
				if (StructKeyExists(local.setting,"default")) {
					this.defaultStyles["#local.setting_code#"] = local.setting.default;
				}
				if (StructKeyExists(local.setting,"setting")) {
					this.varClasses.append(local.setting_code);
					if (! StructKeyExists(local.setting,"default")) {
						throw("Setting #local.setting_code# had no default");
					}
					this.settings["#local.setting_code#"]  = local.setting.default;
					
				}
			}
		}
		catch (any e) {
			local.extendedinfo = {"tagcontext"=e.tagcontext, "setting_code"=local.setting_code};

			throw(
				extendedinfo = SerializeJSON(local.extendedinfo),
				message      = "Error updating defaults:" & e.message, 
				detail       = e.detail,
				errorcode    = ""		
			);
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
				 array  data,
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
	private string function css_settings(required string selector, required struct styles, struct full_styles={}, boolean debug=true) {
		
		var ret = "";

		if ( arguments.debug ) ret &= "/* Main CSS goes here */" & newLine();
		
		return ret;
	
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
	 */
	private string function css_styles(required string selector, required struct styles, boolean debug=true) {
		
		var tab = arguments.debug ? "	": "";
		var css = [];

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

			if (arguments.debug ) css.append("/* writing styles for state #local.state.state# */");

			css.append(arguments.selector & local.state.selector & " {");
			
			for (local.style in this.styleDefs) {
				local.def = this.styleDefs[local.style];
				if (local.def.keyExists("setting")) continue;
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
							case "boolean":
								local.val = local.state_styles[local.style] ? "1" : "0" ;
							break;
							default:
								local.val = local.state_styles[local.style];
							break;
						}
						// css &= this.settingsObj.CSSCommentHeader("Content styling");
						css.append("#tab#--#local.style#: " & local.val & ";");
					}
				}
				else if (arguments.debug ) {
					css.append("#tab#/* no style for #local.style# */")	;
				}
				
			}

			css.append(variables.contentObj.settingsObj.css(local.state_styles, arguments.debug));

			css.append("}");

			// additional panels for plain css styling
			for (local.panel in this.panels) {
				if (StructKeyExists(local.state_styles,local.panel.panel)) {
					if (arguments.debug ) css.append("/* panel #local.panel.panel# */");
					
					// also get state styles for the panels
					// This is pretty crude. If any states are defined it also
					// looks inside every panel for those states. This is necessary
					// where you only want the panel affected and not the whole item
					local.panel_styles = local.state_styles[local.panel.panel];

					for (local.panel_state in this.states) {
						
						if ( local.panel_state.state eq "main") {
							local.panel_state_styles = local.panel_styles;
						}
						else {
							if (NOT StructKeyExists(local.panel_styles,local.panel_state.state)) {
								if (arguments.debug ) css.append("/* No settings for state #local.panel_state.state# */");
								continue;
							}
							local.panel_state_styles = local.panel_styles[local.panel_state.state];
						}
						if (arguments.debug ) css.append("/* state #local.panel_state.state# */");
						try {
							css.append(arguments.selector & local.state.selector & " " & local.panel.selector & local.panel_state.selector & " {" & variables.contentObj.settingsObj.css(settings=local.panel_state_styles, debug=arguments.debug) & "}" );
						}
						catch (any e) {
							local.extendedinfo = {
								"tagcontext"=e.tagcontext,
								"selector" = arguments.selector,
								"state.selector" = local.state.selector,
								"panel_styles" = local.panel_styles,
								"state_styles" = local.state_styles
							};
							throw(
								extendedinfo = SerializeJSON(local.extendedinfo),
								message      = "Unable to process style:" & e.message, 
								detail       = e.detail
							);
						}
					}
				}
				else if (arguments.debug ) {
					css.append("/* No settings for panel #local.panel.panel# */");
				}
			}
			css.append("");

		}

		return css.toList(arguments.debug ? newLine() : "");
	
	}
	
	
	

	/**
	 * @hint Generate CSS for the content section
	 *
	 * Each CS type has a combination of "styles" which are simple css vars and "settings"
	 * which require logic to adjust a number of parameters.
	 *
	 * Each cs component is expected to define its own css_settings() function.
	 *
	 * NB: don't call this yourself. Always use the content.css() method which will calculate full_styles and call this for all the media 
	 * 
	 * @styles  Content section settings struct
	 * @full_styles See settings.inheritSettings - supplies all values for given media
	 */
	public string function css(required string selector, required struct styles, struct full_styles={}, boolean debug=true) {
		
		var css_str = css_styles(argumentCollection = arguments);
		css_str &= css_settings(argumentCollection = arguments);
				
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

	/**
	 *  return a struct of blank strings with one key for each selector
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
	 * Remove style def options e.g. for imagegrid which inherits from grid we don't want flex or named positions.
	 */
	public void function removeOptions(required settingname, required string options) {
		var voptions = arguments.options;
		this.styleDefs[arguments.settingname]["options"] = arrayFilter(this.styleDefs[arguments.settingname]["options"], function(item,options) {
			return !ListFind(variables.voptions,item.value);
		});
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