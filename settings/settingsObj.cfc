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

	/** @hint get CSS for layouts
	
	At this time still up for debate about how much will go into here.

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
		color:: var(--textcolor);
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


		for (local.medium in arguments.styles.media) {
			arguments.css = replaceNoCase(arguments.css, "@media.#local.medium.name#", mediaQuery(local.medium.name, arguments.styles),"all");
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

	/* @hint wrap css in media query 
	
	A media query can optionally specify a max width and/or a medium (screen by default)

	A defined medium with neither will just return the css.

	If the medium is not defined, the medium will not be defined.
	
	*/
	private string function mediaQuery(required string name, required struct settings) {

		local.mediumFound = 0;
		local.css = "";	
		for (local.mediumq in arguments.settings.media) {
			if (local.mediumq.name == arguments.name) {
				local.mediaQuery = local.mediumq;
				local.mediumFound = 1;
				break;
			}
		}
			
		if (local.mediumFound || (StructKeyExists(local.mediaQuery,"max") || StructKeyExists(local.mediaQuery,"media"))) {
			local.media = StructKeyExists(local.mediaQuery,"media") ? local.mediaQuery.media : "screen";
			local.maxwidth = StructKeyExists(local.mediaQuery,"max") ?  " and (max-width: #local.mediaQuery.max#px)" : "";
			local.css = "@media only #local.media# #local.maxwidth#";
		}
		else {
			local.css = arguments.css;
		}
		
		

		return local.css;
	}



}