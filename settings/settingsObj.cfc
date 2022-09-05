component {

	public settingsObj function init(debug=false)  output=false {

		this.cr = chr(13) & chr(10);
		this.utils = CreateObject("component", "clikpage.utils.utilsold");	
		this.debug = arguments.debug;

		return this;
	}

	/** Load an XML settings definition */
	public struct function loadStyleSheet(required string filename)  output=false {

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
	public string function siteCSS(required struct styles, boolean debug=this.debug)  output=false {

		local.css = layoutCss(arguments.styles);
		local.css &= fontVariablesCSS(arguments.styles);
		local.css &= colorVariablesCSS(arguments.styles);
		
		return outputFormat(local.css,arguments.styles);

	}
	
	/**
	 * @hint Generate css for containers
	 *
	 * NOT really working. Only works for one container. Being used on the fly in the current
	 * sample site.
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

	/**
	 * @hint get CSS for layouts
	 *
	 * WIP 
	 *
	 * NOT done
	 */
	public string function layoutCss(required struct containers, required struct media)  output=false {

		var css = "";

		for (var medium in arguments.media ) {
			var section_css = "";

			//get template here

			for (var id in template.containers) {
				var cs =  arguments.containers[id];
				
				//get the settings don,t do it on every loop!

				if ((medium EQ "main") OR (StructKeyExists(cs.settings, medium))) {
					local.settings = medium EQ "main" ? cs.settings : cs.settings[medium];
					section_css &= settingsObj.containerCss(settings=local.settings,selector="###id#");
				}	
			}

			css &= "/* CSS for #medium# */\n";
			if (section_css NEQ "") {
				if (medium NEQ "main") {
					css &= "@media.#medium# {\n " & section_css & "\n}\n";
				}
				else {
					css &= section_css;
				}
			}
		}
		return css;

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
     * 	--bodyfont: Open sans;
     * }
     *
     * body {
     * 	font-family: var(--bodyfont);
     * }
     *
     * The font faces should be defined in the static CSS.
	 */
	public string function fontVariablesCSS(required struct settings, boolean debug=this.debug)  output=false {

		local.css = "";

		if (StructKeyExists(arguments.settings,"fonts")) {
			for (local.font in arguments.settings.fonts) {
				if (! (StructKeyExists(local.font,"name") && StructKeyExists(local.font,"value"))) {
					local.css &= "\t/* font incorrectly configured #serializeJSON(local.font)# */\n";
				}
				else {
					local.css &= "\t--#local.font.name#: #local.font.value#;\n";
				}	
				
			}
		}
		
		return local.css;

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

		local.css = "";

		if (StructKeyExists(arguments.settings,"colors")) {
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
		}
		
		return local.css;

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
		local.css &= this.dimensions(settings=arguments.settings);
		
		if (StructKeyExists(arguments.settings, "inner")) {
			local.innerCSS &= this.dimensions(arguments.settings.inner);
		}
		if (StructKeyExists(arguments.settings,"grid")) {
			local.gridcss &= grid(arguments.settings.grid);
		}

		local.css &= "}\n";
		
		if (local.innerCSS NEQ "" OR local.gridcss NEQ "") {
			local.css &= "#arguments.selector# .inner {\n";
			local.css &= local.innerCSS & local.gridcss;
			local.css &= "}\n";
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
			/** TODO: rewrite with java regex to avoid cf bugs */
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
	 * Return struct of mediums from array defined in styles
	 *
	 * @styles    Complete styles
	 */
	public struct function getMedia(required struct styles)  output=false {
		
		StructAppend(arguments.styles,{"media":[]},false);

		local.styles = [=];

		// TO DO: separate medium field, don't use main
		StructAppend(local.styles,{"main":{"name": "main", "description":"Applies to all screen sizes"}},true);

		for (local.row in arguments.styles.media) {
			// ensure we override any attempt to sabotage main.
			if (StructKeyExists(local.row,"name") AND local.row.name NEQ "main") {
				local.styles[local.row.name] = local.row;
			}
		}

		return local.styles;

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

}