/*

# Settings Object

Handles parsing of the settings files and some writing out of CSS.

## Synopsis

Styles are stored in a css-like text format. This parses them into a struct and does some processing of media scopes.

### 1. Parsing

The css is parsed into a nested struct. The root keys are either system defs (fonts, media, colors, vars), individual IDs, or classes. Note that while you can use @, #, and . prefixes to distinguish these in the source, they are removed in the result.



*/

component output=false {

	public settings function init(debug=false) {

		this.cr = newLine();
		this.utils = CreateObject("component", "utils.utils");
		this.debug = arguments.debug;
		this.cssParser = new cssParser();	

		// set of "reserved" keys in stylesheets
		variables.systemSettings = {"media"=1,"vars"=1,"colors"=1,"fonts"=1};

		return this;
	}

	/**
	 * Parse a stylesheet and append to struct. Note that the settings WON'T be overridden.
	 *
	 * @filename full path to stylesheet
	 * @styles   struct to append to (won't overwrite existing) 
	 */
	public void function loadStylesheet(required string filename, required struct styles)   {
		
		if ( !FileExists(arguments.filename) ) {
	 		throw("Stylesheet #arguments.filename# not found");
	 	}

	 	var newStyles = this.cssParser.parse( FileRead(arguments.filename) );
	 	
	 	for (key in newStyles) {
	 		if (! variables.systemSettings.keyExists( key ) ) {
	 			this.cssParser.addMainMedium(newStyles[key]);
	 		}
		}

		this.utils.deepStructAppend(arguments.styles, newStyles, false);

	 	for (key in arguments.styles) {

	 		var recursionCheck = {};
	 		if (! variables.systemSettings.keyExists( key ) ) {
	 			checkInheritance(key=key,styles=arguments.styles, recursionCheck=recursionCheck);
	 		}			
		}

	 	checkMedia(arguments.styles);

	}

	/**
	 * @hint Apply "inherits" styles
	 *
	 * Might prove problematic with complex inheritance structures. Always recurses every time, doesn't cache results. TODO: fix this
	 * 
	 */
	private void function checkInheritance(required string key,required struct styles, required struct recursionCheck) localmode=true {
		
		section = arguments.styles[arguments.key];

		if ( section.KeyExists("main") && section.main.KeyExists("inherit") ) {
			for (ikey in ListToArray(section.main.inherit, " ") ) {
				tmpKey = ListFirst(ikey, ".##");
				if (! arguments.recursionCheck.keyExists(tmpKey)) {
					recursionCheck[arguments.key] = 1;
					checkInheritance(key=tmpKey,styles=arguments.styles, recursionCheck=recursionCheck);
				}
				else {
					throw("Circular inheritance reference to section #tmpKey#");
				}
				this.utils.deepStructAppend(section, arguments.styles[tmpKey], false);
			}
			section.main.delete("inherit");
		}
	}

	/**
	 * Check definition of media queries
	 */
	private void function checkMedia(required struct styles) {
		
		// Main medium can't be defined by user
		arguments.styles.media["main"] = ["main"={"title":"Main"}];
		
		for (local.medium in arguments.styles.media) {
			// add default title
			StructAppend(arguments.styles.media[local.medium],{"title":local.medium},false);
		}
		
	}

	/**
	 * @hint move root settings "up" into "main" medium
	 *
	 * When styles are defined, the settings for the main medium
	 *  are just in the root. For consistency, we put them into
	 *  a key "main".
	 *
	 */
	private void function checkMediaMainStyles(required struct section, required struct styles) {
		
		for (local.cs in arguments.section) {

			local.styles = arguments.section[local.cs];
			local.tempStyles = {};
	
			for (local.medium in arguments.styles.media) {
				if (NOT IsStruct(local.styles)) {
					local.extendedinfo = {"styles"=local.styles};
					throw(
						message      = "Styles not struct",
						extendedinfo = SerializeJSON(local.extendedinfo)
					);
				}
				if (StructKeyExists(local.styles,local.medium)) {
					local.tempStyles["#local.medium#"] = local.styles[local.medium];
					structDelete(local.styles, local.medium);
				}
			}

			local.tempStyles["main"] = local.styles;
			arguments.section[local.cs] = local.tempStyles;
		}
	}

	/**
	 * not going to work becuase we need the contentObject
	 * 
	 */
	// public string function siteCSS(required struct styles, boolean debug=this.debug)  {
		
	// 	throw("WIP see test_styles.cfm");
	// 	local.css &= fontVariablesCSS(arguments.styles);
	// 	local.css &= colorVariablesCSS(arguments.styles);
	// 	local.css = layoutCss(argsneeded);
		
	// 	return outputFormat(local.css,arguments.styles.media);

	// }
	
	/**
	 * @hint get CSS for layouts
	 *
	 * Loop over a collection of containers and apply basic styling qualified by the template
	 * name
	 * 
	 * @containers Struct of containers with optional key for class
	 * @styles     settings (e.g. from layouts>templatename in stylesheet)
	 * @media      struct of media settings
	 * @selector   Settings qualififier e.g. body.templatename.
	 * 
	 */
	
	public string function layoutCss(required struct containers, required struct styles, required struct media, string selector="") {

		var css = "";
		
		for ( var medium in arguments.media ) {

			var media = arguments.media[medium];
			var section_css = "";
			
			for ( var id in arguments.containers ) {
				
				local.cs = arguments.containers[id];
				local.styles = {};

				if ( StructKeyExists(local.cs,"class") ) {
					
					// classes must be applied in order they appear in stylesheet
					local.classLookup = this.utils.listToStruct(local.cs.class, " ");
					for (local.class in arguments.styles) {
						if ( local.classLookup.keyExists( local.class ) AND 
						 	StructKeyExists(arguments.styles[local.class], medium) ) {
							this.utils.deepStructAppend(local.styles, arguments.styles[local.class][medium]);
						}
					}
				}

				if ( StructKeyExists(arguments.styles, id) AND
					 StructKeyExists(arguments.styles[id], medium)) {
						this.utils.deepStructAppend(local.styles, arguments.styles[local.id][medium]);
				}
				
				if ( NOT structIsEmpty(local.styles) ) {
					local.select = ListAppend(arguments.selector, "###id#", " ");
					try {
						section_css &= containerCss(settings=local.styles,selector=local.select);
					}
					catch (any e) {
						local.extendedinfo = {"tagcontext"=e.tagcontext,id=id,settings=local.styles};
						throw(
							extendedinfo = SerializeJSON(local.extendedinfo),
							message      = "Unable to write css for container #id#:" & e.message, 
							detail       = e.detail
						);
					}
				}
			}

			if (section_css NEQ "") {
				if (medium NEQ "main") {
					css &= "@media.#medium# {\n" & indent(section_css,1) & "\n}\n";
				}
				else {
					css &= section_css;
				}
			}
		}
		return css;

	}

	/**
	 * CSS for variable definitions
	 */
	public string function variablesCSS(required struct settings, boolean debug=this.debug) {

		local.css = arguments.debug ? CSSCommentHeader("Vars") : "";

		if (StructKeyExists(arguments.settings,"vars")) {
			for (local.varname in arguments.settings.vars) {
				local.var = arguments.settings.vars[local.varname];
				if ( arguments.debug  && ! StructKeyExists(local.var,"value") ) {
					local.css &= "/* No value specified for var #local.varname# */" & newLine();
				}
				else {
					// A var can have a value of another var
					local.varvalue = Left(local.var.value,2) eq "--" ? "var(#local.var.value#)" : local.var.value; 
					local.css &= "--#local.varname#: #local.varvalue#;";
					if ( arguments.debug ) {
						if ( StructKeyExists(local.var,"title") ) {
							local.css &= " /* #local.var.title# */";
						}
						local.css &= newLine();
					}
				}	
			}
		}
		
		return indent(local.css);

	}	

	/** 
	 * @hint  Generate css for assigning font variable values
     *
     * All font faces are applied as variable names, allowing for easy abstraction, e.g. titlefont, bodyfont.
     *
     * These are assigned to actual font faces here,
     *
     * e.g.
     *
     * :root {
     * 	--bodyfont: "Open sans";
     * }
     *
     * body {
     * 	font-family: var(--bodyfont);
     * }
     *
     * The font faces should be defined in the static CSS.
	 */
	public string function fontVariablesCSS(required struct settings, boolean debug=this.debug) {

		local.css = arguments.debug ? CSSCommentHeader("Fonts") : "";
		var cr = arguments.debug ? newLine() : "";

		if (StructKeyExists(arguments.settings,"fonts")) {
			for (local.fontname in arguments.settings.fonts) {
				local.font = arguments.settings.fonts[local.fontname];
				if (arguments.debug && ! StructKeyExists(local.font,"family")) {
					local.css &= "/* No family specified for font #local.fontname# */#cr#";
				}
				else {
					local.fontfamily = Left(local.font.family,2) eq "--" ? "var(#local.font.family#)" : local.font.family; 
					local.css &= "--#local.fontname#: #local.fontfamily#;";
					if (arguments.debug && StructKeyExists(local.font,"title")) {
						local.css &= " /* #local.font.title# */#cr#";
					}
					local.css &= cr;

				}	
				
			}
		}
		
		return indent(local.css);

	}

	/** 
	 * @hint  Generate css for assigning color variable values
     * 
     * All colors are applied as variable names, allowing for easy abstraction, e.g. textcolor
     * 
     * These are assigned to actual colors here,
     * 
     * e.g.
     * 
     * :root {
     * 	 --textcolor: #3f3f3f;
     * }
     * 
     * 	body {
     * 		color: var(--textcolor);
     * 	}
	 * 
	 */
	public string function colorVariablesCSS(required struct styles, boolean debug=this.debug) {

		local.css = arguments.debug ? CSSCommentHeader("Colors") : "";
		
		if (StructKeyExists(arguments.styles,"colors")) {
			for (local.colorname in arguments.styles.colors) {
				local.color = arguments.styles.colors[local.colorname];
				
				if ( StructKeyExists(local.color,"value") ) {
					
					local.colorvalue = Left(local.color.value,2) eq "--" ? "var(#local.color.value#)" : local.color.value; 
					local.css &= "--#local.colorname#: #local.colorvalue#;";
					
					if (arguments.debug ) {
						if ( StructKeyExists(local.color,"title") ) {
							local.css &= " /* #local.color.title# */";
						}
						local.css &= newLine() ;
					}
				}
				else if ( arguments.debug ) {
					local.css &= "/* No value specified for color #local.colorname# */" & newLine() ;
				}	
				
			}
		}
		
		return Indent(local.css);

	}
	/**
	 * Concatenate an array of content section css data with media queries
	 */
	public string function contentCSS(required array css, required struct media) localmode=true {
		
		cr = newLine();

		cssData = {};
		
		for (cs in arguments.css) {
			
			for (medium in cs) {
				if (! cssData.keyExists(medium) ) cssData[medium] = "";
				cssData[medium] &= cs[medium];
			}

		}

		css_ret = "";


		for ( medium in getMediaOrder( arguments.media ) ) {
			if ( cssData.keyExists(medium) ) {
				if (medium != "main") css_ret &= mediaQuery( arguments.media[medium] ) & "{" & cr;
					css_ret &= cssData[medium];
				if (medium != "main") css_ret &= "}" & cr;
			}
		}

		return css_ret;

	} 

	/** TODO: this */
	private array function getMediaOrder( required struct media ) {

		return ["main","max","mid","mobile","print"];

	}

	

	/** 
	 * get CSS for a container
	 * 
	 * @settings   medium settings for the container
	 * @selector  css stylesheet selector e.g. #main
	 */
	public string function containerCss(
			required struct  settings,
			required string  selector, 
					 boolean debug=this.debug
			) {
		local.css = "";

		local.mainCSS = "";
		local.innerCSS = "";
		local.gridcss = "";
		
		local.mainCSS = dimensions(settings=arguments.settings);
		
		if ( local.mainCSS neq "") {
			local.css &= "#arguments.selector# {\n" & local.mainCSS & "}\n";
		}

		if (StructKeyExists(arguments.settings, "inner")) {
			local.innerCSS &= dimensions(arguments.settings.inner);
		}
		
		local.gridSettings = {"main"="","item"=""};

		grid(arguments.settings,local.gridSettings);
		
		local.hasGrid = local.gridSettings.main != "" OR local.gridSettings.item != "";

		if ( local.innerCSS NEQ "" OR local.hasGrid ) {
			local.css &= "#arguments.selector# > .inner {\n";
			local.css &= local.innerCSS;
			if ( local.hasGrid ) {
				local.css &= local.gridSettings.main;
			};
			local.css &= "}\n";
			// hacky here. Should use format qualifier mechanism from grid cs type
			if (StructCount(local.gridSettings) AND local.gridSettings.item !="") {
				local.css &= "#arguments.selector# .inner > * {\n";
				local.css  &= local.gridSettings.item;
				local.css &= "}\n";
			};			
		}

		if (StructKeyExists(arguments.settings, "open")) {
			local.openCss = dimensions(arguments.settings.open);
			if ( local.openCss NEQ "") {
				local.css &= "#arguments.selector#.open {\n";
				local.css  &= local.openCss;
				local.css &= "}\n";
			}

		}
		
		return local.css;
		
	}

	/** 
	 * get general CSS for content
	 */
	public string function css(required struct settings, boolean debug=true) {
		var cr = arguments.debug ? newline() : "";
		var tab = arguments.debug ? "	" : "";
		
		local.css = "";

		if (arguments.debug) local.css &= "#tab#/* Font */" & cr;
		local.css &= font(arguments.settings,arguments.debug);
		if (arguments.debug) local.css &= "#tab#/* Dimensions */" & cr;
		local.css &= dimensions(arguments.settings,arguments.debug);

		return local.css;

	}

	private string function font(required struct settings,boolean debug=true) {

		var cr = arguments.debug ? newline() : "";
		var tab = arguments.debug ? "	" : "";

		local.css = "";
		for (local.property in ['font-family','color']) {
			if (StructKeyExists(arguments.settings,local.property)) {
				local.css &= "#tab##local.property#:var(--#arguments.settings[local.property]#);" & cr;
			}
		}

		for (local.property in ['font-size','font-weight','font-style','font-variant','line-height','letter-spacing','text-decoration','text-align','text-transform','text-align-last','white-space','text-indent','word-spacing','word-wrap']) {
			if (StructKeyExists(arguments.settings,local.property)) {
				local.css &= "#tab##local.property#:#arguments.settings[local.property]#;" & cr;
			}
		}
		
		return local.css;

	}

	private string function dimensions(required struct settings, boolean debug=true) {

		var cr = arguments.debug ? newline() : "";
		var tab = arguments.debug ? "	" : "";

		local.css = "";

		if (StructKeyExists(arguments.settings,"show")) {
			if (isBoolean(arguments.settings.show)) {
				if (NOT arguments.settings.show ) {
					local.css &= "#tab#display:" & "none;#cr#";
				}
				else if (NOT structKeyExists(arguments.settings, "grid")) {
					local.css &= "#tab#display:" & "block;#cr#";
				}
			}
		}

		for (local.property in ['color','link-color']) {
			if (StructKeyExists(arguments.settings,local.property)) {
				local.css &= "#tab#--#local.property#:" & displayColor(arguments.settings[local.property]) & ";#cr#";
			}
		}


		if (StructKeyExists(arguments.settings,"position")) {
			local.css &= displayPosition(arguments.settings);
		}

		if ( structKeyExists( arguments.settings, "float") ) {
			local.css &= "#tab#float:#arguments.settings.float#;#cr#";
			if ( structKeyExists( arguments.settings, "float-margin") ) {
				local.margin = displayDimension(arguments.settings["float-margin"]);
				local.css &= "#tab#margin-bottom:#local.margin#;#cr#";
				local.outside = arguments.settings.float eq "left" ? "right" : "left";
				local.css &= "#tab#margin-#local.outside#:#local.margin#;#cr#";
			}
		}

		if (StructKeyExists(arguments.settings,"border")) {
			local.settings = Duplicate(arguments.settings["border"]);
			StructAppend(local.settings, {"style":"solid"}, false);
			for (local.property in ['width','color','style']) {
				if (StructKeyExists(local.settings,local.property)) {
					local.css &= "#tab#border-#local.property#:" & displayProperty(local.property,local.settings[local.property]) & ";#cr#";
				}
			}
		}

		if (StructKeyExists(arguments.settings,"background")) {
			local.settings = Duplicate(arguments.settings["background"]);
			for (local.property in ['color','image','repeat','position']) {
				if (StructKeyExists(local.settings,local.property)) {
					local.css &= "#tab#background-#local.property#:" & displayProperty(local.property,local.settings[local.property]) & ";#cr#";
				}
			}
		}

		for (local.property in ['padding','margin','width','min-width','max-width','height','min-height','max-height']) {
			if (StructKeyExists(arguments.settings,local.property)) {
				local.css &= "#tab##local.property#:" & displayProperty(local.property,arguments.settings[local.property]) & ";#cr#";
			}
		}

		for (local.property in ['opacity','z-index','overflow','overflow-x','overflow-y','box-shadow','transform','transition']) {
			if (StructKeyExists(arguments.settings,local.property)) {
				local.css &= "#tab##local.property#:" & arguments.settings[local.property] & ";#cr#";
			}
		}

		if (StructKeyExists(arguments.settings,"align") && arguments.settings.align == "center") {
			local.css &= "#tab#margin-left:auto;#cr##tab#margin-right:auto;#cr#";
		}

		return local.css;

	}

	private string function displayPosition(required struct settings) {
		
		var retVal = ["\tposition:" & arguments.settings.position & ";"];

		switch ( arguments.settings.position ) {
			case "sticky":
				local.positions = ['top','bottom','left','right'];
				local.hasPosition = 0;
				for ( local.position in local.positions ) {
					if ( structKeyExists( arguments.settings, local.position ) ) {
						retVal.append( local.position & ":" & displayDimension(arguments.settings[local.position] )  & ";" );
						local.hasPosition = 1;
						break;
					}
					if ( NOT local.hasPosition ) {
						retVal.append( "top:0;" );
					}
				}
				break;
			case "fixed":case "absolute":case "relative":
				local.ordinals = [['top','bottom'],['left','right']];
				
				for ( local.ordinal in local.ordinals ) {
					local.hasPosition = 0;
					for ( local.position in local.ordinal ) {
						if ( structKeyExists( arguments.settings, local.position ) )  {
							retVal.append( local.position & ":" & displayDimension( arguments.settings[local.position] ) & ";" );
							local.hasPosition = 1;
							break;
						}
					}

					if ( NOT local.hasPosition ) {
						retVal.append( local.ordinal[1] & ":0;" );
					}
					
				}
				break;
			
		}
		
		return retVal.toList( "\n\t" ) & "\n";

	}

	private string function displayProperty(required string name, required string value, string scope="") {

		var retVal = "";

		switch (arguments.name) {

			case "padding": case "margin":case "width":case "max-width": case "max-height":case "min-width":case "min-height":
				retVal = displayDimension(arguments.value);
				break;
			case "color":
				retVal = displayColor(arguments.value);
				break;
			default:
				retVal = arguments.value;
		
		}
		return retVal;

	}
	
	/**
	 * Add dimensions to plain number values and check vars
	 */
	public string function displayDimension(required string value) {
		
		var retVal = "";
		for (local.dimension in ListToArray( arguments.value," #chr(13)##chr(10)##chr(9)#") ) {
			if ( isValid( "numeric", local.dimension ) ) {
				local.dimension &= "px";
			}
			else if ( Left(local.dimension,2) eq "--" ) {
				local.dimension = "var(" & local.dimension & ")";
			}

			retVal = ListAppend(retVal,local.dimension," ");
		}

		return retVal;
	}

	public string function displayColor(required string value) {
		var retVal = "var(--#arguments.value#)";
		return retVal;
	}

	/**
	 * @hint CSS styling for a grid
	 * 
	 */
	public string function grid(required struct styles, required string selector, boolean debug=true) {

		if (! arguments.styles.keyExists("grid-mode") ) return "";

		var css = [arguments.selector & " {"];
		var tab = arguments.debug ? "	": "";

		switch (arguments.styles["grid-mode"]) {
			case  "none":
				css.append("#tab#display: block;");
				break;

			case  "fill":
				css.append("#tab#--grid-fit: auto-fill;");
			case  "fit":
				css.append("#tab#display: grid;");	
				css.append("#tab#grid-template-columns: repeat(var(--grid-fit), minmax(var(--grid-width),var(--grid-max-width)));");
				break;
			
			case  "flex":	
				css.append("#tab#display: flex;");
				break;

			case "fixed":
				css.append("#tab#display: grid;");	
				css.append("#tab#grid-template-columns: repeat(var(--grid-columns), 1fr);");
				break;

			case "fixedwidth":
				css.append("#tab#display: grid;");	
				css.append("#tab#grid-template-columns:  repeat(auto-fit, var(--grid-width));");
				break;

			case "columns":
				css.append("#tab#display: grid;");	
				css.append("#tab#grid-template-columns: var(--grid-template-columns);");
				css.append("#tab#grid-template-rows: var(--grid-template-rows);");
				break;

			case "rows":
				css.append("#tab#display: grid;");	
				css.append("#tab#grid-template-columns: 1fr;");
				css.append("#tab#grid-template-rows: var(--grid-template-rows);");
				break;
			case "named":
				css.append("#tab#display: grid;");	
				css.append("#tab#grid-template-areas: var(--grid-template-areas);");
				css.append("#tab#grid-template-columns: var(--grid-template-columns);");
				css.append("#tab#grid-template-rows: var(--grid-template-rows);");
				break;
		}

		css.append("}");

		if ( styles["grid-mode"] neq "named") {
			css.append("#arguments.selector# > * {");
			css.append("#tab#grid-area: unset !important;");
			css.append("}");
		}
		css.append("");

		return css.toList(arguments.debug ? newLine() : "");

	}

	/**
	 * DEPRECATED - each function should have a debug switch
	 * 
	 * Remove \n,\ts etc from css string 
	 * 
	 * @css           CSS to process
	 * @media         Struct of media settings
	 * @debug         Return readable version with comments
	 * 
	 */
	
	public string function outputFormat(required string css, required struct media, boolean debug=this.debug) {

		var patternObj = createObject( "java", "java.util.regex.Pattern");
		var pattern = patternObj.compile("\/\*.*?\*\/", patternObj.MULTILINE + patternObj.UNIX_LINES);

		for (local.medium in arguments.media) {
			arguments.css = ReplaceNoCase(arguments.css, "@media.#local.medium#", MediaQuery(arguments.media[local.medium]),"all");
		}

		if (arguments.debug) {
			arguments.css = replace(arguments.css, "\n", this.cr,"all");
			arguments.css = replace(arguments.css, "\t", chr(9),"all");
		}
		else {
			arguments.css = replace(arguments.css, "\t", "","all");
			arguments.css = replace(arguments.css, "\n", "","all");
			arguments.css  = pattern.matcher(arguments.css).replaceAll("");
		}

		return arguments.css;

	}

	/**
	 * @hint generate css media query for a medium
	 *
	 * A media query can optionally specify a max/min width and/or a medium (screen by default)
	 *
	 * A undefined medium or one with no specs (e.g. main) will return a blank string. You need logic to handle this
	 *
	 * @mediaQuery    struct of information 
	 */
	private string function mediaQuery(required struct mediaQuery) {

		local.css = "";
		
		if (StructKeyExists(arguments.mediaQuery,"max") || StructKeyExists(arguments.mediaQuery,"min") || StructKeyExists(arguments.mediaQuery,"media")) {
			local.media = StructKeyExists(arguments.mediaQuery,"media") ? arguments.mediaQuery.media : "screen";
			local.maxwidth = StructKeyExists(arguments.mediaQuery,"max") ?  " and (max-width: #arguments.mediaQuery.max#px)" : "";
			local.minwidth = StructKeyExists(arguments.mediaQuery,"min") ?  " and (min-width: #arguments.mediaQuery.min#px)" : "";
			local.css = "@media only #local.media##local.maxwidth##local.minwidth#";

		}
		
		return local.css;

	}

	/**
	 * Create a struct of styles to start playing with
	 * probably not needed in final cut 
	 */
	public function newStyles() {
		var styles = {
			"main": {},
			"mobile": {},
			"mid": {},
		}
		return styles;
	}

	/**
	 * Indent string using tabs
	 */
	public string function indent(required string input, numeric num=1){
		local.indent = repeatString("	", arguments.num);
		local.ret = ListToArray(arguments.input,newLine(),false,false);
		return local.indent & local.ret.toList(newLine() & local.indent) & newLine();
	}

	/**
	 * Create a comment box for a CSS page
	 */
	public string function CSSCommentHeader(required string title, numeric width=66) {
		ret = "/*" & repeatString("*", arguments.width-2) & newLine();
		ret &= "*  " & cJustify(arguments.title, arguments.width-4 ) & "*" & newLine();
		ret &= "" & repeatString("*", arguments.width) & "/" & newLine();
		return ret;
	}

	/**
	 * @hint Ensure settings inherit through media hierarchy
	 * 
	 * This is one of the key functions to understand. Say for instance you have a required 
	 * setting "orientation" for a menu. This will have a default value, but this might be 
	 * overridden in "main". When we want to get the value for mobile, it should inherit 
	 * from main or even mid, not the default value.
	 *
	 * This is easy for plain css variables as the media queries take care of this. For "settings",
	 * we need to know the value when we write out the CSS.
	 *
	 * Say we have settings htop and align for an item. We may only redefine "align" in mobile, but to 
	 * correctly write out the css, we need to also know the valye for htop.
	 *
	 * We could just write out every setting but this would lead to bloat. We only want to write out
	 * settings in other media when they are redefined. 	 * 
	 * 
	 * @styles css styles (indivual content section styles)
	 * @media  Media struct
	 * @settings  "settings" defaults from Content section type. Tis is a struct of all default values for styledefs with setting=1   
	 */
	public struct function inheritSettings(required struct styles, required struct media, required struct settings) localmode=true {
		
		checkMediaInheritance(arguments.media);

		fullStyles = {};

		// settings required in main
		if (! StructKeyExists( arguments.styles, "main" ) ) {
			arguments.styles["main"] = Duplicate(arguments.settings)
		}
		else {
			this.utils.deepStructAppend(arguments.styles["main"], arguments.settings, false);
		}

		// first pass - create "clean" copy of defined values
		for (medium in arguments.media) {
			
			fullStyles["#medium#"] = {};

			if ( arguments.styles.keyExists(medium) ) {
				for (setting in  arguments.settings) {
					if ( arguments.styles[medium].keyExists(setting) ) {
						fullStyles[medium]["#setting#"] = arguments.styles[medium][setting];
					}
				}
			}
			
		}

		this.utils.deepStructAppend(fullStyles["main"], arguments.settings, false);

		for (medium in arguments.media) {
			if (medium eq "main") continue;
			
			mediumSettings = arguments.media[medium];

			allMedia = ["main"];

			if ( mediumSettings.keyExists( "inherit" ) ){
				allMedia.append(mediumSettings.inherit, true);
			}

			for ( imedium in  allMedia ) {
				this.utils.deepStructAppend(fullStyles[medium], fullStyles[imedium], false);
			}

		}
		
		return fullStyles;
		
	}

	/**
	 * Create an array of mediums to inherit from in each medium. The order is crucial
	 * 
	 * TODO: actually do this, it's hard wired...	 * 
	 * 
	 */
	public void function checkMediaInheritance(required struct media) localmode=true {
		
		if ( arguments.media.keyExists("mobile") ) {
			if ( ! arguments.media["mobile"].keyExists("inherit") ) {
				arguments.media["mobile"]["inherit"] = ["mid"];
			}
		}
		
		for (medium in arguments.media) {
			if ( arguments.media[medium].keyExists("inherit") && ! isArray(arguments.media[medium].inherit) ) {
				arguments.media[medium].inherit = ListToArray(arguments.media[medium].inherit);
			}
		}

	}


}