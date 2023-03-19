/*

# Settings Object

Handles parsing of the settings files and some writing out of CSS.

## Synopsis

Settings are loaded from XML defnition file.

*/

component {

	public settings function init(debug=false)  output=false {

		this.cr = chr(13) & chr(10);
		this.utils = CreateObject("component", "utils.utils");
		this.utilsXML = CreateObject("component", "utils.xml");	
		this.debug = arguments.debug;
		this.cssParser = new cssParser();	

		return this;
	}

	/**
	 * @hint Load XML style definition file
	 *
	 * XML style definitions define colors, fonts, media queries
	 * and vars. In the CSS files we only ever refer to variable
	 * names defined here.
	 *  
	 */
	public struct function loadStyleSettings(required string filename) output=false  {

		if (!FileExists(arguments.filename)) {
			throw("Stylesheet #arguments.filename# not found");
		}
			
		try {
			
			local.styles = {};// leave this -- see catch below
			local.xmlData = this.utils.fnReadXML(arguments.filename,"utf-8");
			local.styles = this.utilsXML.xml2data(local.xmlData);
			
			local.defaults = {
				"colors" :[=],
				"fonts" :[=],
				"media" :[=],
				"vars" :[=],
				"style": [=]
			};
			
			StructAppend(local.styles,local.defaults,false);
			
			// TODO: surely this can't be right
			for (local.default in local.defaults) {
				if ( NOT IsStruct(local.styles[local.default]) ) {
					local.styles[local.default] = [=];
				}
			}

			// Load external files
			if ( StructKeyExists(local.styles,"link") ) {
				local.root = GetDirectoryFromPath(arguments.filename);
				local.xmlData = this.utils.fnReadXML(arguments.filename,"utf-8");
				if ( NOT isArray(local.styles.link) ) {
					local.styles.link = [local.styles.link];
				}
				for (local.link in local.styles.link) {
					if ( StructKeyExists(local.link,"href") && 
						StructKeyExists(local.link,"rel") ) {
						local.filepath = getCanonicalPath( local.root & local.link.href);
						local.filedata = this.utils.fnReadFile(local.filepath,"utf-8");
						switch (local.link.rel) {
							case "stylesheet":
								local.css = this.cssParser.parse(local.filedata);
								this.utils.deepStructAppend(local.styles.style,local.css);
							break;
						}
					}
				}
				StructDelete( local.styles,"link" );
			}

			checkMedia( local.styles );
			
		}
		catch (any e) {
			local.extendedinfo = {"tagcontext"=e.tagcontext,styles=local.styles};
			throw(
				extendedinfo = SerializeJSON(local.extendedinfo),
				message      = "Unable to parse stylesheet #arguments.filename#:" & e.message, 
				detail       = e.detail,
				errorcode    = "settings.loadStyleSheet"		
			);
		}

		return local.styles;

	}

	/**
	 * Check definition of media queries
	 */
	private void function checkMedia(required struct styles) {
		
		// Main medium can't be defined by user
		structDelete(arguments.styles.media, "main"); 

		// create new ordered struct with main first
		local.tempMedia = ["main"={"title":"Main"}];
		
		for (local.medium in arguments.styles.media) {
			// add default title
			StructAppend(arguments.styles.media[local.medium],				{"title":local.medium},false);
			local.tempMedia[local.medium] = arguments.styles.media[local.medium];
		}
		arguments.styles.media = local.tempMedia;

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
					throw(
						message      = "Styles not struct",
						detail       = SerializeJSON(local.styles)
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
	// public string function siteCSS(required struct styles, boolean debug=this.debug)  output=false {
		
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
	 * @settings   settings (e.g. from layouts>templatename in stylesheet)
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
					for (local.class in arguments.styles) {
						if ( ListFindNoCase(local.cs.class, local.class, " ") AND 
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
						section_css &= containerCss(settings=local.styles,selector=local.select);
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
	public string function variablesCSS(required struct settings, boolean debug=this.debug)  output=false {

		local.css = CSSCommentHeader("Vars");

		if (StructKeyExists(arguments.settings,"vars")) {
			for (local.varname in arguments.settings.vars) {
				local.var = arguments.settings.vars[local.varname];
				if (! StructKeyExists(local.var,"value")) {
					local.css &= "/* No value specified for var #local.varname# */\n";
				}
				else {
					// A var can have a value of another var
					local.varvalue = Left(local.var.value,2) eq "--" ? "var(#local.var.value#)" : local.var.value; 
					local.css &= "--#local.varname#: #local.varvalue#;";
					if (structKeyExists(local.var,"title")) {
						local.css &= " /* #local.var.title# */";
					}
					local.css &= "\n";
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
	public string function fontVariablesCSS(required struct settings, boolean debug=this.debug)  output=false {

		local.css = CSSCommentHeader("Fonts");

		if (StructKeyExists(arguments.settings,"fonts")) {
			for (local.fontname in arguments.settings.fonts) {
				local.font = arguments.settings.fonts[local.fontname];
				if (! StructKeyExists(local.font,"family")) {
					local.css &= "/* No family specified for font #local.fontname# */\n";
				}
				else {
					local.fontfamily = Left(local.font.family,2) eq "--" ? "var(#local.font.family#)" : local.font.family; 
					local.css &= "--#local.fontname#: #local.fontfamily#;";
					if (structKeyExists(local.font,"title")) {
						local.css &= " /* #local.font.title# */";
					}
					local.css &= "\n";

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
	public string function colorVariablesCSS(required struct settings, boolean debug=this.debug) {

		local.css = CSSCommentHeader("Colors");

		if (StructKeyExists(arguments.settings,"colors")) {
			for (local.colorname in arguments.settings.colors) {
				local.color = arguments.settings.colors[local.colorname];
				if (! StructKeyExists(local.color,"value")) {
					local.css &= "/* No value specified for color #local.colorname# */\n";
				}
				else {
					
					local.colorvalue = Left(local.color.value,2) eq "--" ? "var(#local.color.value#)" : local.color.value; 
					local.css &= "--#local.colorname#: #local.colorvalue#;";
					if (structKeyExists(local.color,"title")) {
						local.css &= " /* #local.color.title# */";
					}
					local.css &= "\n";

				}	
				
			}
		}
		
		return Indent(local.css);

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
		local.innerCSS = "";
		local.gridcss = "";
		
		local.css &= "#arguments.selector# {\n";
		local.css &= dimensions(settings=arguments.settings);
		
		// if (StructKeyExists(arguments.settings,"show")) {
		// 	if (NOT arguments.settings.show) {
		// 		local.css &= "}\n";
		// 	}
		// }

		if (StructKeyExists(arguments.settings, "inner")) {
			local.innerCSS &= dimensions(arguments.settings.inner);
		}
		
		local.gridSettings = {"main"="","item"=""};
		if (StructKeyExists(arguments.settings,"grid")) {
			grid(arguments.settings.grid,local.gridSettings);
		}
		
		local.css &= "}\n";
		
		if (local.innerCSS NEQ "" OR StructCount(local.gridSettings)) {
			local.css &= "#arguments.selector# > .inner {\n";
			local.css &= local.innerCSS;
			if (StructCount(local.gridSettings)) {
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
		
		return local.css;

	}

	/** get general CSS for content */
	public string function css(required struct settings) {
		
		local.css = "\t/* Font */\n";
		local.css &= font(arguments.settings);
		local.css &= "\t/* Dimensions */\n";
		local.css &= dimensions(arguments.settings);

		return local.css;2

	}

	private string function font(required struct settings) {

		local.css = "";
		for (local.property in ['font-family','color']) {
			if (StructKeyExists(arguments.settings,local.property)) {
				local.css &= "\t#local.property#:var(--#arguments.settings[local.property]#);\n";
			}
		}

		for (local.property in ['font-size','font-weight','font-style','font-variant','line-height','letter-spacing','text-decoration','text-align','text-transform','text-align-last','white-space','text-indent','word-spacing','word-wrap']) {
			if (StructKeyExists(arguments.settings,local.property)) {
				local.css &= "\t#local.property#:#arguments.settings[local.property]#;\n";
			}
		}
		
		return local.css;

	}

	private string function dimensions(required struct settings) {

		local.css = "";

		if (StructKeyExists(arguments.settings,"show")) {
			if (isBoolean(arguments.settings.show)) {
				if (NOT arguments.settings.show ) {
					local.css &= "\tdisplay:" & "none;\n";
				}
				else if (NOT structKeyExists(arguments.settings, "grid")) {
					local.css &= "\tdisplay:" & "block;\n";
				}
			}
		}

		if (StructKeyExists(arguments.settings,"position")) {
			local.css &= displayPosition(arguments.settings);
		}

		if (StructKeyExists(arguments.settings,"border")) {
			local.settings = Duplicate(arguments.settings["border"]);
			StructAppend(local.settings, {"style":"solid"}, false);
			for (local.property in ['width','color','style']) {
				if (StructKeyExists(local.settings,local.property)) {
					local.css &= "\tborder-#local.property#:" & displayProperty(local.property,local.settings[local.property]) & ";\n";
				}
			}
		}

		if (StructKeyExists(arguments.settings,"background")) {
			local.settings = Duplicate(arguments.settings["background"]);
			for (local.property in ['color','image','repeat','position']) {
				if (StructKeyExists(local.settings,local.property)) {
					local.css &= "\tbackground-#local.property#:" & displayProperty(local.property,local.settings[local.property]) & ";\n";
				}
			}
		}

		for (local.property in ['padding','margin','width','min-width','max-width','height','min-height','max-height']) {
			if (StructKeyExists(arguments.settings,local.property)) {
				local.css &= "\t#local.property#:" & displayProperty(local.property,arguments.settings[local.property]) & ";\n";
			}
		}
		for (local.property in ['object-fit','z-index','overflow','overflow-x','overflow-y','box-shadow']) {
			if (StructKeyExists(arguments.settings,local.property)) {
				local.css &= "\t#local.property#:" & arguments.settings[local.property] & ";\n";
			}
		}

		if (StructKeyExists(arguments.settings,"align") && arguments.settings.align == "center") {
			local.css &= "\tmargin-left:auto;\n\tmargin-right:auto;\n";
		}

		if (StructKeyExists(arguments.settings,"align") && arguments.settings.align == "center") {
			local.css &= "\tmargin-left:auto;\n\tmargin-right:auto;\n";
		}


		return local.css;

	}

	private string function displayPosition(required struct settings) {
		
		// var hasPosition = structSome(arguments.settings,
		// 	function(key,value) {
		// 		return structKeyExists({"top":1,"bottom":1,"left":1,"right":1}, key);
		// 	});		
		
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
				for (local.dimension in ListToArray(arguments.value," #chr(13)##chr(10)##chr(9)#")) {
					retVal = ListAppend(retVal,displayDimension(local.dimension)," ");
				}
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
	private string function displayDimension(required string value) {
		
		var retVal = arguments.value;
		
		if (isValid("numeric", retVal)) {
			retVal &= "px";
		}
		else if (Left(retVal,2) eq "--") {
			retVal = "var(" & retVal & ")";
		}
		
		return retVal;
	}

	private string function displayColor(required string value) {
		var retVal = "var(--#arguments.value#)";
		return retVal;
	}

	/**
	 * NOTE THIS IS JUST COPIED FROM grid.cfc. TODO: incorporate grid styling from grid.cfc
	 * somehow.
	 * 
	 */
	public void function grid(required struct settings, required struct out) {

		var styles = arguments.settings;
		
		arguments.out["main"] = "";
		arguments.out["item"] = "";
		structAppend(styles, {
			"grid-gap":"0",
			"grid-mode":"auto",
			"grid-fit":"auto-fit",
			"grid-width":"180px",
			"grid-max-width":"1fr",
			"grid-max-height":"auto",
			"grid-columns":"2",
			"flex-direction":"row",
			"justify-content":"flex-start",
			"align-items":"center"
			},false);
		arguments.out.main &= "\tgrid-gap:" & displayDimension(styles["grid-gap"]) & ";\n;";
		arguments.out.main &= "\t--grid-max-height:" & displayDimension(styles["grid-max-height"]) & ";\n;";
		
		switch (styles["grid-mode"]) {
			case "none":
				arguments.out.item &= "\tgrid-area:unset;\n;";
				arguments.out.main &= "\tdisplay:block;\n";
				break;
			case "auto":
				arguments.out.item &= "\tgrid-area:unset;\n;";
				arguments.out.main &= "\tdisplay:grid;\n";
				arguments.out.main &= "\tgrid-template-columns: repeat(#styles["grid-fit"]#, minmax(#styles["grid-width"]#, #styles["grid-max-width"]#));\n";

				break;	
			case "fixedwidth":
				arguments.out.item &= "\tgrid-area:unset;\n;";
				arguments.out.main &= "\tdisplay:grid;\n";
				arguments.out.main &= "\tgrid-template-columns: repeat(#styles["grid-fit"]#, #styles["grid-width"]#);\n";
				break;	
			case "fixedcols":
				arguments.out.item &= "\tgrid-area:unset;\n;";
				arguments.out.main &= "\tdisplay:grid;\n";
				// specified column width e.g. 25% auto 15% - this is the most useful application of this mode
				if (StructKeyExists(styles,"grid-template-columns") AND styles["grid-template-columns"] neq "") {
					arguments.out.main &= "\tgrid-template-columns: " & styles["grid-template-columns"] & ";\n";
				}
				// specified number of columns
				else if (StructKeyExists(styles,"grid-columns") AND isValid("integer", styles["grid-columns"])) {
					arguments.out.main &= "\tgrid-template-columns: repeat(" & styles["grid-columns"] & ",1fr);\n";
				}
				// All columns in one row -- not a very good idea.
				else {
					arguments.out.main &= "\tgrid-template-columns: repeat(auto-fit, minmax(20px, max-content));\n";
				}
				
				break;	

			case "templateareas":
				arguments.out.main &= "\tdisplay:grid;\n";
				if (NOT StructKeyExists(styles,"grid-template-areas")) {
					throw("Grid mode templateareas requires grid-template-areas to be set");
				}
				arguments.out.main &= "\tgrid-template-areas:" & styles["grid-template-areas"] & ";\n";
				if (StructKeyExists(styles,"grid-template-columns") AND styles["grid-template-columns"] neq "") {
					arguments.out.main &= "\tgrid-template-columns: " & styles["grid-template-columns"] & ";\n";
				}
				if (StructKeyExists(styles,"grid-template-rows") AND styles["grid-template-rows"] neq "") {
					arguments.out.main &= "\tgrid-template-rows: " & styles["grid-template-rows"] & ";\n";
				}
				break;
			case "flex": case "flexstretch":
				arguments.out.main &= "\tdisplay:flex;\n\tflex-wrap: wrap;\n";
				arguments.out.main &= "\tflex-direction: " & styles["flex-direction"] & ";\n";
				arguments.out.main &= "\tjustify-content: " & styles["justify-content"] & ";\n";
				arguments.out.main &= "\talign-items: " & styles["align-items"] & ";\n";
				if (styles["grid-mode"] eq "flexstretch") {
					arguments.out.item &= "\n\tflex-grow:1;\n;";
				}
				break;
		}

	}

	/**
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
	private string function mediaQuery(required struct mediaQuery)  output=false {

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
	public function newStyles()  output=false {
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
		local.indent = repeatString("\t", arguments.num);
		local.ret = ListToArray(arguments.input,"\n",false,true);
		return local.indent & local.ret.toList("\n" & local.indent) & "\n";
	}

	/**
	 * Create a comment box for a CSS page
	 */
	public string function CSSCommentHeader(required string title, numeric width=66) {
		ret = "/*" & repeatString("*", arguments.width-2) & "\n";
		ret &= "*  " & cJustify(arguments.title, arguments.width-4 ) & "*\n";
		ret &= "" & repeatString("*", arguments.width) & "/\n";
		return ret;
	}

}