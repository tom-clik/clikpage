component {

	public settingsObj function init(debug=false) {

		this.cr = chr(13) & chr(10);
		this.utils = CreateObject("component", "clikpage.utils.utilsold");	
		this.debug = arguments.debug;

		return this;
	}


	/** Load an XML settings definition */
	public struct function loadStyleSheet(required string filename) {

		if (!FileExists(arguments.filename)) {
			throw("Stylesheet #arguments.filename# not found");
		}

		local.xmlData = this.utils.fnReadXML(arguments.filename,"utf-8");
		local.xml = this.utils.xml2data(local.xmlData);

		return local.xml;

	}

	/**
	 * Generate css for global level variables
	 * 
	 */
	public string function siteCSS(required struct styles, boolean debug=this.debug) {

		local.css = layoutCss(arguments.styles);
		local.css &= fontVariablesCSS(arguments.styles);
		local.css &= colorVariablesCSS(arguments.styles);
		
		return outputFormat(local.css,arguments.styles);

	}
	
	/**
	 * @hint Generate css for containers
	 *
	 * 
	 */
	public string function containersCSS(required struct styles, required struct layout, boolean debug=this.debug) {

		local.css = "";

		for (var medium in arguments.styles.media) {
			if (medium.name != "main") {
				local.css  &= "@media.#medium.name# {\n";
			}

			local.css  &= containerCss(styles=arguments.styles,name="body",selector="body", media=medium.name);
			
			for (var container in  arguments.layout.containers) {
				local.css  &= "/* generating stylings for #container# [#medium.name#] */\n";
				local.css  &= containerCss(styles=arguments.styles,name=container, media=medium.name);	
			}

			if (medium.name != "main") {
				local.css &= "}\n";
			}
		}

		return local.css;
	}

	/** @hint get CSS for layouts
	
	At this time still up for debate about how much will go into here.

	Currently it's a sort of modern incarnation of the old 1998 vintage column layout mechanism.

	If we do preserve that, surely it wants to use a standard grid?? There's always been a problem
	with the old system in that you can't change the flow for mobile etc.

	If not, this is better. It just outputs css variables for the column widths etc.

	The static css is in columns.css.

	*/
	public string function layoutCss(required struct settings, boolean debug=this.debug) {

		local.css = "";

		if (StructKeyExists(arguments.settings, "layouts")) {
			for (local.layoutname in arguments.settings.layouts) {
				local.layout = arguments.settings.layouts[local.layoutname];
				local.css &= "body.layout-#local.layoutname# {\n";

				for (local.setting in local.layout) {
					local.css &= "\t--#local.setting#: " & local.layout[local.setting] & ";\n";
				}

				local.css &= "}\n";
			}
		}

		return local.css;

	}

	/** @hint  Generate css for assigning font variable values

	All font faces are applied as variable names, allowing for esy abstraction, e.g. titlefont, bodyfont.

	These are assigned to actual font faces here,

	e.g.

	:root {
		--bodyfont: Open sans;
	}

	body {
		font-family: var(--bodyfont);
	}

	The fonts faces should be defined in the static CSS.

	*/
	public string function fontVariablesCSS(required struct settings, boolean debug=this.debug) {

		local.css = "";

		if (StructKeyExists(arguments.settings,"fonts")) {
			local.css &= ":root {\n";
			for (local.font in arguments.settings.fonts) {
				if (! (StructKeyExists(local.font,"name") && StructKeyExists(local.font,"value"))) {
					local.css &= "\t/* font incorrectly configured #serializeJSON(local.font)# */\n";
				}
				else {
					local.css &= "\t--#local.font.name#: #local.font.value#;\n";
				}	
				
			}
			local.css &= "}\n";
		}
		
		return local.css;

	}

	/** @hint  Generate css for assigning color variable values

	All colors are applied as variable names, allowing for easy abstraction, e.g. textcolor

	These are assigned to actual colors here,

	e.g.

	:root {
		--textcolor: #3f3f3f;
	}

	body {
		color: var(--textcolor);
	}
	
	*/
	public string function colorVariablesCSS(required struct settings, boolean debug=this.debug) {

		local.css = "";

		if (StructKeyExists(arguments.settings,"colors")) {
			local.css &= ":root {\n";
			for (local.color in arguments.settings.colors) {
				if (! (StructKeyExists(local.color,"name") && StructKeyExists(local.color,"value"))) {
					local.css &= "\t/* color incorrectly configured #serializeJSON(local.color)# */\n";
				}
				else {
					if (StructKeyExists(local.color, "title") && arguments.debug) {
						local.css &= "\t/*  #local.color.title# */\n";
					}
					local.css &= "\t--#local.color.name#: #local.color.value#;\n";
				}	
				
			}
			local.css &= "}\n";
		}
		
		return local.css;

	}
	
	/** get CSS for container */
	public string function containerCss(required struct styles, required string name, string selector="###arguments.name#", string media="main", boolean debug=this.debug) {

		local.css = "";
		if (arguments.debug) {
			local.css &= "/* styling for #arguments.selector# */\n";
		}

		local.innerCSS = "";

		if (StructKeyExists(arguments.styles.content, arguments.name)) {

			if (StructKeyExists(arguments.styles.content[arguments.name],arguments.media)) {
				
				local.settings = arguments.styles.content[arguments.name][arguments.media];
				local.css &= "#arguments.selector# {\n";
				local.css &= this.css(settings=local.settings);
				local.css &= "}\n";
				
				local.inner = "";
				local.gridcss = "";

				if (StructKeyExists(arguments.styles.content[arguments.name][arguments.media], "inner")) {
					local.inner &= this.css(settings=arguments.styles.content[arguments.name][arguments.media]["inner"]);
				}

				if (StructKeyExists(arguments.styles.content[arguments.name][arguments.media],"grid")) {
					local.gridcss &= grid(arguments.styles.content[arguments.name][arguments.media]["grid"]);
				}

				if (local.inner != "") {
					local.css &= "#arguments.selector# .inner {\n";
					local.css &= local.inner & local.gridcss;
					local.css &= "}\n";
				}
				else {
					// could do better here? Repeated selector.
					local.css &= "#arguments.selector# {\n";
					local.css &= local.gridcss;
					local.css &= "}\n";
				}
				

			} else if (arguments.debug) {
				local.css &= "/* no styles found for media #arguments.media# */\n";
			}
		}
		else if (arguments.debug) {
			local.css &= "/* no styles found for name */\n";
		}
		
		return local.css;

	}

	/** get general CSS for content */
	public string function css(required struct settings) {
		
		local.css = "\t/* Font */\n";
		local.css &= font(arguments.settings);
		local.css &= "\t/* Dimensions */\n";
		local.css &= dimensions(arguments.settings);

		return local.css;

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
				local.css &= "\tdisplay:" & (arguments.settings.show ? "block" : "none" ) & ";\n" ;
			}
		}

		if (StructKeyExists(arguments.settings,"border")) {
			local.settings = Duplicate(arguments.settings["border"]);
			StructAppend(local.settings, {"style":"solid"}, false);
			for (local.property in ['width','color','style']) {
				if (StructKeyExists(local.settings,local.property)) {
					local.css &= "\tborder-#local.property#:" & displayProperty(local.property,local.settings[local.property]) & ";\n";
				}
			}
			// local.css &= "/* " & serializeJSON(arguments.settings.border) & "*/\n";
		}

		if (StructKeyExists(arguments.settings,"background")) {
			local.settings = Duplicate(arguments.settings["background"]);
			for (local.property in ['color']) {
				if (StructKeyExists(local.settings,local.property)) {
					local.css &= "\tbackground-#local.property#:" & displayProperty(local.property,local.settings[local.property]) & ";\n";
				}
			}
			// local.css &= "/* " & serializeJSON(arguments.settings.background) & "*/\n";
		}

		for (local.property in ['padding','margin','width','min-width','max-width','height','min-height','max-height']) {
			if (StructKeyExists(arguments.settings,local.property)) {
				local.css &= "\t#local.property#:" & displayProperty(local.property,arguments.settings[local.property]) & ";\n";
			}
		}

		if (StructKeyExists(arguments.settings,"align") && arguments.settings.align == "center") {
			local.css &= "\tmargin-left:auto;\n\tmargin-right:auto;\n";
		}


		return local.css;

	}

	private string function displayProperty(required string name, required string value, string scope="") {

		var retVal = "";

		switch (arguments.name) {

			case "padding": case "margin":case "width":case "max-width": case "max-height":case "min-width":case "min-height":
				retVal = "";
				for (local.dimension in ListToArray(arguments.value," ")) {
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

	private string function displayDimension(required string value) {
		var retVal = arguments.value;
		// getting bug where 30.6666666667 <> 30.6666666667 presumably rounding error
		if (retVal neq "auto" AND Left(val(retVal),6) eq Left(arguments.value,6))	{
			retVal &= "px";
		}
		return retVal;
	}

	private string function displayColor(required string value) {
		var retVal = "var(--#arguments.value#)";
		return retVal;
	}


	private string function grid(required struct settings) {

		local.css = "";

		local.isGrid = StructKeyExists(arguments.settings, "grid") ? arguments.settings.grid : true;

		if (local.isGrid) {
			local.css &= "\tdisplay:grid;\n";
			for (local.setting in ['grid-gap','grid-row-gap']) {
				if (StructKeyExists(arguments.settings, local.setting)) {
					local.css &= "\t#local.setting#: #arguments.settings[local.setting]#;\n";
				}
			}
			// short cut for exact number of columns. Rarely used.
			if (StructKeyExists(arguments.settings, "columns")) {
				local.css &= "\tgrid-template-columns: repeat(#arguments.settings.columns#, 1fr);\n";
			}
			else if (StructKeyExists(arguments.settings, "max-width")) {
				local.css &= "\tgrid-template-columns: repeat(auto-fill, #arguments.settings["max-width"]#,1fr));\n";
			}
			else if (StructKeyExists(arguments.settings, "grid-template-columns")) {
				local.css &= "\tgrid-template-columns: #arguments.settings["grid-template-columns"]#;\n";
			}
			else if (StructKeyExists(arguments.settings, "grid-template-rows")) {
				local.css &= "\tgrid-template-rows: #arguments.settings["grid-template-rows"]#;\n";
			}			
		}
		else {
			local.css &= "\tdisplay:block;\n";
		}

		return local.css;

	}

	/**
	 * Remove \n,\ts etc from css string 
	 * 
	 * @css           CSS to process
	 * @debug         Return readable version with comments
	 * 
	 */
	
	public string function outputFormat(required string css, required struct styles, boolean debug=this.debug) {
		local.media  = getMedia(arguments.styles);
		for (local.medium in local.media) {
			arguments.css = ReplaceNoCase(arguments.css, "@media.#local.medium#", MediaQuery(local.media[local.medium]),"all");
		}

		if (arguments.debug) {
			arguments.css = replace(arguments.css, "\n", this.cr,"all");
			arguments.css = replace(arguments.css, "\t", chr(9),"all");
		}
		else {
			/** to do: rewrite with java regex to avoid cf bugs */
			arguments.css = replace(arguments.css, "\t", "","all");
			arguments.css = replace(arguments.css, "\n", "","all");
			arguments.css = REReplace(arguments.css,"\/\*.*?\*\/","","all");
		}



		return arguments.css;
	}

	/**
	 * @hint generate css media query for a medium
	 *
	 * A media query can optionally specify a max/min width and/or a medium (screen by default)
	 *
	 * A undefined medium or one with no specs (e.g. main) will return a blank string. You need logic to handle this
	 */
	private string function MediaQuery(required struct mediaQuery) {

		local.css = "";

		if (StructKeyExists(arguments.mediaQuery,"max") || StructKeyExists(arguments.mediaQuery,"min") || StructKeyExists(arguments.mediaQuery,"media")) {
			local.media = StructKeyExists(arguments.mediaQuery,"media") ? arguments.mediaQuery.media : "screen";
			local.maxwidth = StructKeyExists(arguments.mediaQuery,"max") ?  " and (max-width: #arguments.mediaQuery.max#px)" : "";
			local.minwidth = StructKeyExists(arguments.mediaQuery,"min") ?  " and (min-width: #local.mediaQuery.min#px)" : "";
			local.css = "@media only #local.media##local.maxwidth##local.minwidth#";
		}
		
		return local.css;

	}

	/**
	 * Return array of mediums from style struct
	 *
	 * TODO: actually do this
	 * @styles    Complete style struct keyed
	 */
	public struct function getMedia(required struct styles) {
		
		StructAppend(arguments.styles,{"media":[]},false);

		local.styles = [=];

		StructAppend(local.styles,{"main":{"name": "Main", "description":"Applies to all screen sizes"}},true);

		for (local.row in arguments.styles.media) {
			// ensure we override any attempt to sabotage main.
			if (StructKeyExists(local.row,"name") AND local.row.name NEQ "main") {
				StructAppend(local.styles,{local.row.name:local.row},true);
			}
		}

		return local.styles;

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

}