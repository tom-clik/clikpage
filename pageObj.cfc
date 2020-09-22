component {
	/**
	 * @hint Pseudo initialiser
	 * 
	 * The "local" values for cssdef and jsdef will load the files in this
	 * folder. To not use static defs, set these to blank
	 * 
	 * As a user of pageObj you would probably edit these files for your
	 * standard libraries and copy them for more complex sites
	 *
	 * @cssdef  File path for cssdef
	 * @jsdef   File path for jsdef
	 * @debug   Whether to use debug scripts/stylesheets. Note that this can be overridden on any given display function call.
	 *
	 */
	public pageObj function init(string cssdef="local",string jsdef="local", boolean debug=false) {
		
		this.content = {
			"title"="Page object",
			"body"="",
			"bodyClass"="",
			"css" = "",
			"static_css"={},
			"css_files"=[],
			"static_js"= {"jquery"=1},
			"js_files"=[],
			"onready"="",
			"meta"=[],
			"css_inline"="",
			"layout"="col-SM"
		};
		
		if (arguments.jsdef != "") {
			if (arguments.jsdef == "local") {
				arguments.jsdef = GetDirectoryFromPath(GetCurrentTemplatePath()) & "staticJS.json";
			}
			local.jsDef = loadDefFile(arguments.jsdef);
			variables.hasStaticJS = true;
			this.jsStaticFiles =  CreateObject("component", "publishing.staticFiles").init(local.jsDef);	
		}
		else {
			variables.hasStaticJS = false;
		}
		
		if (arguments.cssdef != "") {
			if (arguments.cssdef == "local") {
				arguments.cssdef = GetDirectoryFromPath(GetCurrentTemplatePath()) & "staticCSS.json";
			}
			local.cssDef = loadDefFile(arguments.cssdef);
			this.cssStaticFiles =  CreateObject("component", "publishing.staticFiles").init(local.cssDef);
			this.cssStaticFiles.setCss();
			variables.hasStaticCSS = true;
		}
		else {
			variables.hasStaticCSS = false;
		}

		this.debug = arguments.debug;

		return this;
		
	}

	public struct function getContent() {

		return Duplicate(this.content);
	}

	public string function addMeta(required struct content, required string name, required string value) {
		arrayAppend(arguments.content.meta,{"name"=arguments.name,"value"=arguments.value});
	}

	public string function buildPage(required struct content, boolean debug=this.debug) {

		var page = "";
		var cr = chr(13) & chr(10);

		page &= "<!DOCTYPE html>#cr#";
		page &= "<html>#cr#";
		page &= "<head>#cr#";
		page &= "	<title>#arguments.content.title#</title>#cr#";
		
		// array of meta data
		for (local.meta in arguments.content.meta) {
			page &= "	<meta name=""#local.meta.name#"" content=""#local.meta.value#"">#cr#";
		}
		
		if (variables.hasStaticCSS) {
			page &= this.cssStaticFiles.getLinks(arguments.content.static_css,arguments.debug);
		}

		// array of arbitrary files to link to
		for (local.style in arguments.content.css_files) {
			page &= "	<link rel=""stylesheet"" href=""#local.style#"">#cr#";
		}

		if (arguments.content.css != "") {
			page &= "	<style>#arguments.content.css#</style>#cr#";
		}

		local.bodyClass = 
		page &= "</head>#cr#";
		page &= "<body class='#arguments.content.layout#'>#cr#";
		page &= arguments.content.body & cr;

		if (variables.hasStaticJS) {
			page &= this.jsStaticFiles.getLinks(arguments.content.static_js,arguments.debug);
		}

		// arbitrary js files
		for (local.js in arguments.content.js_files) {
			page &= "	<script src=""#local.js#""></script>#cr#";
		}
		
		if (arguments.content.onready neq "") {
			page &= "<script>#cr#";
			page &= "$( document ).ready(function() {#cr#";
			page &= arguments.content.onready & cr;
			page &= "})#cr#";
			page &= "</script>#cr#";

		}
		page &= "</body>#cr#";
		page &= "</html>#cr#";

		return page;

	}

	public void function addCss(required struct content, required string css) {
		ArrayAppend(arguments.content.css_files, arguments.css);
	}
	
	public void function addJs(required struct content, required string js) {
		ArrayAppend(arguments.content.js_files, arguments.js);
	}

	/**
	 * @hint      Loads a definition file.
	 *
	 * @defFile  Full path to definition file
	 *
	 */
	public struct function loadDefFile(defFile) {
		if (NOT fileExists(arguments.defFile)) {
			throw("Static files definition file #arguments.defFile# not found");
		}
		local.tempData = fileRead(arguments.defFile);
		try {
			local.jsonData = deserializeJSON(local.tempData);
		}
		catch (Any e) {
			throw("Unable to parse static files definition file #arguments.defFile#");	
		}

		return local.jsonData;
	}



}