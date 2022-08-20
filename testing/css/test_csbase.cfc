/* Base component for new cs components */
component {
	
	public function init() {

		// See selectorQualifiedCSS. Shorthand to apply css to sub elements
		this.selectors = [
			{"name"="main", "selector"=""}
		];

		// some cs have hover states etc
		this.states = [
			{"name"="main", "selector"="","name":"Main","description":"The main state"}
		];

		// panels for generic css styling.
		this.panels = [
		];

		// define all available settings for this CS
		// Any styles not added to settings (see below) will be written our as a CSS var
		//
		// E.g.
		// 	"htop":{"type":"boolean","description":"Put headline before image"},
		//	"image-width":{"type":"dimension","description":"Put headline before image"},
		
		// Basically freeform at this time. Will be formalised when we 
		// come to build the editing system!
		// 
		this.styleDefs = {};

		// Keys of this struct are treated as special cases requiring logic to produce CSS
		// They will not be added to the CSS. They will also inherit down the media queries.
		this.settings = [=];
	}

	/* Create a struct of styles to start playing with
	probably not needed in final cut */
	public function newStyles() {
		var styles = {
			"main": {},
			"mobile": {},
			"mid": {},
		}
		return styles;
	}

	/**
	 * Return array of mediums from style struct
	 *
	 * TODO: actually do this
	 * @styles    Complete style struct keyed
	 */
	public struct function getMedia(required struct styles) {
		return [
			"main": {"name": "Main", "description":"Applies to all screen sizes"},
			"max": {"name": "Max", "description":"Only apply at full size", "min"="1200"},
			"mid": {"name": "Mid", "description":"Apply at medium size or below", "max"="800"},
			"mobile": {"name": "Mobile", "description":"Apply at mobile size", "max"="630"},
		];

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
	 * These often need applying to a css pseudo class or sub element.
	 *
	 * The details of each state are in this.states
	 *
	 * Note the "main" state has the settings in the root of the struct while other states are
	 * keys of main, e.g.
	 *
	 * {
	 *    "link-color": "var(--darkcolor)",
	 *    "hi": {
	 *    	"link-color": "var(--accentcolor)"
	 *    },
	 *    "hover": {
	 *    	"link-color": "var(--lightcolor)""
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

			for (local.style in this.styleDefs) {
				// ignore complex settings
				if (NOT StructKeyExists(this.settings, local.style)) {
					if (StructKeyExists(local.state_styles,local.style)) {
						ret &= "\t--#local.style#: " & local.state_styles[local.style] & ";\n";
					}
					else {
						ret &= "\t/-- no style for #local.style# --/\n";	
					}
				}
			}

			ret &= panelCSS(local.state_styles) ;
			ret &= "}\n";

			// additional panels for plain css styling
			for (local.panel in this.panels) {
				if (StructKeyExists(local.state_styles,local.panel.name)) {
					ret &= arguments.selector & local.state.selector & " " & local.panel.selector & " {\n" & panelCSS(local.state_styles[local.panel.name]) & "}\n";
				}
			}


			
		}
		return ret;
	}
	
	 /**
	  * @hint Inherit settings for meida queries.

		Where a style definition isn't a simple CSS var we need to ensure it inherits
		across media queries.
	  * @complete_styles  Struct with all media queries styles
	  */
	public void function checkInheritance(required struct complete_styles) {
		
		local.inheritedSettings = {};
		local.media = getMedia(arguments.complete_styles);
		
		for (local.mediumname in local.media) {
			
			if (StructKeyExists(arguments.complete_styles, local.mediumname)) {
				
				for (local.settingname in this.settings) {
					local.setting = this.settings[local.settingname];
					if (StructKeyExists(arguments.complete_styles[local.mediumname], local.settingname)) {
						local.inheritedSettings[local.settingname] = Duplicate(arguments.complete_styles[local.mediumname][local.settingname]);
					}
				}

				StructAppend(arguments.complete_styles[local.mediumname], local.inheritedSettings, false);
			}
		}

	}


	/**
	 * @hint Generate CSS for the content section
	 *
	 * Each CS type has a combination of "styles" which are simple css vars and "settings"
	 * which require logic to adjust a number of parameters.
	 *
	 * Each cs component is expected to define its own css_settings() function.
	 * 
	 * @settings  Settings struct with keys for each media size
	 */
	public string function css(required string selector, required struct styles, boolean debug=false) {
		
		var css_str = "";
		
		checkInheritance(arguments.styles);
		
		local.media = getMedia(arguments.styles);
		
		for (local.mediumname in local.media) {
			local.medium = local.media[local.mediumname];
			if (StructKeyExists(arguments.styles,local.mediumname)) {
				
				local.css_section = css_styles(selector = arguments.selector, styles=arguments.styles[local.mediumname]);
				local.css_section &= css_settings(selector = arguments.selector, styles=arguments.styles[local.mediumname]);
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
		
		return processText(css_str,arguments.debug);

	}

	/**
	 * @hint Process text with \t\t and /-- --/ comments
	 *
	 * If we're not in debug we strip these out otherwise we replace with white space or comment markers.
	 * 
	 * @text    Text to process
	 * @debug   Pretty print output
	 */
	private string function processText(text,boolean debug=true) {
		var tab = arguments.debug ? chr(9) : "";
		var cr = arguments.debug ? chr(13) & chr(10) : "";

		// if (!arguments.debug) {
		// 	arguments.text = reReplace(arguments.text, "\/(\*|\-\-).*?(\*|\-\-)\/", "", "all");
		// }

		return ReplaceList(arguments.text,"\n,\t,/--,--/","#cr#,#tab#,/*,*/");
	}

	/** 
	 * @hint Indent string with \t characters 
	 * 
	 * These can be converted to tabs for pretty printing or stripped for compression
	 *
	 * @text text to indent
	 * @indent Number of tabs to indent.
	 */
 
	private string function indent(text,indent) {
		var tab = repeatString("\t", indent);
		var retVal = tab & Replace(arguments.text,"\n","\n#tab#","all");
		if (Right(retVal,2) eq "\t") {
			retVal = retVal.removeChars(retval.len() -1, 2);

		}
		return retVal;
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
				ret &= indent(arguments.css_data[local.selector.name],1);
				ret &= "}\n";

			}
		}
		return ret;
	}

	/**
	 * @hint Generic CSS styling applicable to the css panels of an item. Includes padding, border, background, and margin.
	 *
	 * NB panels are exposed to the users who are expected to apply stylings. Selectors are an internal mechanism to achieve complex settings functionality.
	 *
	 * For the main panel, settings are just dumped into the root.
	 * 
	 */
	
	private string function panelCSS(required struct settings) {
		// TODO: actually do this backgrouds want to be structs
		// WIP basic panel settings
		local.css = "/* adding panel settings */\n";
		for (local.setting in ["border-width","border-color","color","margin","padding","font-family","font-size","font-style","font-weight","text-align","background-color","letter-spacing","line-height","background-color","background-image","background-repeat","background-position","background-size"]) {

			if (StructKeyExists(arguments.settings, local.setting)) {
				local.css &= local.setting & ":" & arguments.settings[local.setting] & ";\n";
			}

		}

		return local.css;
	}
	

}