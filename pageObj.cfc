component {

	// allowable types of meta tage
	variables.metaTypes = {"name"=1,"property"=1,"http-qeuiv"=1};
		
	/**
	 * @hint Pseudo initialiser
	 * 
	 * The "local" values for cssdef and jsdef will load the files in this
	 * folder. To not use static defs, set these to blank
	 * 
	 * As a user of pageObj you would probably edit these files for your
	 * standard libraries and copy them for more complex sites
	 *
	 * @cssdef  File path for cssdef.
	 * @jsdef   File path for jsdef
	 * @debug   Whether to use debug scripts/stylesheets. Note that this can be overridden on any given display function call.
	 *
	 */
	public pageObj function init(string cssdef="local",string jsdef="local", boolean debug=false) {
		
		this.content = {
			"title"="Page object",
			"charset"="UTF-8",
			"lang"="en",
			"body"="",
			"bodyClass"="",
			"css" = "",
			"static_css"={},
			"css_files"=[],
			"static_js"= {"jquery"=1},
			"js_files"=[],
			"onready"="",
			"meta"=[],
			"links"=[],
			"layout"="",
			"gtag"=""
		};
		
		if (arguments.jsdef != "") {
			if (arguments.jsdef == "local") {
				arguments.jsdef = GetDirectoryFromPath(GetCurrentTemplatePath()) & "staticFiles\staticJS.json";
			}
			local.jsDef = loadDefFile(arguments.jsdef);
			variables.hasStaticJS = true;
			this.jsStaticFiles =  CreateObject("component", "clikpage.staticFiles.staticFiles").init(local.jsDef);	
		}
		else {
			variables.hasStaticJS = false;
		}
		
		if (arguments.cssdef != "") {
			if (arguments.cssdef == "local") {
				arguments.cssdef = GetDirectoryFromPath(GetCurrentTemplatePath()) & "staticFiles\staticCSS.json";
			}
			local.cssDef = loadDefFile(arguments.cssdef);
			this.cssStaticFiles =  CreateObject("component", "clikpage.staticFiles.staticFiles").init(local.cssDef);
			this.cssStaticFiles.setCss();
			variables.hasStaticCSS = true;
		}
		else {
			variables.hasStaticCSS = false;
		}

		this.debug = arguments.debug;

		return this;
		
	}

	/**
	 * @hint   Return a page content struct
	 *
	 */
	public struct function getContent() {

		return Duplicate(this.content);
	}

	/**
	 * @hint   add meta tag data to the content
	 *
	 * E.g. to add
	 *
	 * <meta property="og:title" content="Open graph title">
	 *
	 * Use addMeta(content=request.rc.content, name="og:title",value="Open graph title", type="property")
	 * 
	 * @content Page content struct
	 * @name value of name attribute (see also "type"). Must be defined in variables.metaTypes
	 * @value meta content
	 * @type  meta tag type  to e.g. "property".
	 * 
	 */
	public string function addMeta(required struct content, required string name, required string value, string type="name") {
		if (! StructKeyExists(variables.metaTypes, arguments.type)) {
			throw("Invalid meta property #arguments.name#");
		}
		ArrayAppend(arguments.content.meta,{"type"=arguments.type,"name"=arguments.name,"value"=arguments.value});
	}
	/**
	 * @hint      Add an html link tag
	 *
	 * E.g. <link rel="icon" href="/favicon.ico" type="image/x-icon">
	 *
	 * @content  The page content struct
	 * @rel      Relationship e.g. "stylesheet"
	 * @href     href
	 * @type     Type to add to link tag e.g. "image/x-icon"
	 * @crossorigin   Allow crossorigin
	 * @hreflang   hreflang attribute to add to tag
	 *
	 */

	public string function addLink(required struct content, required string rel, required string href, string type="", boolean crossorigin=0,string hreflang="") {
		ArrayAppend(arguments.content.links,{"rel"=arguments.rel,"href"=arguments.href, "type"=arguments.type, "crossorigin"=arguments.crossorigin,"hreflang"=arguments.hreflang});
	}

	/**
	 * @hint      Gneerate HTML page from page content
	 *
	 * @content  Page content
	 * @debug    Use debug mode for any static files
	 *
	 * @return     html page.
	 */
	public string function buildPage(required struct content, boolean debug=this.debug) {

		var page = "";
		var cr = chr(13) & chr(10);

		page &= "<!DOCTYPE html>#cr#";
		page &= "<html lang=""#arguments.content.lang#"">#cr#";
		page &= "<head>#cr#";
		page &= "	<title>#arguments.content.title#</title>#cr#";
		
		page &= "	<meta charset=""#arguments.content.charset#"">#cr#";
		
		// array of meta data
		for (local.meta in arguments.content.meta) {
			page &= "	<meta #local.meta.type#=""#local.meta.name#"" content=""#local.meta.value#"">#cr#";
		}
		
		// array of links
		for (local.link in arguments.content.links) {
			local.type = local.link.type != "" ? " type=""#local.link.type#""" : "";
			local.crossorigin = local.link.crossorigin  ? " crossorigin" : "";
			local.hreflang = local.link.hreflang != "" ? " hreflang=""#local.link.hreflang#""" : "";

			page &= "	<link rel=""#local.link.rel#"" href=""#local.link.href#""#local.type##local.crossorigin##local.hreflang#>#cr#";
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

		local.bodyClass = arguments.content.bodyClass;

		if (arguments.content.gtag != "") {
			page &=  gtagScript(arguments.content.gtag);
		}
		
		// legacy functionality
		if (arguments.content.layout != "") {
			local.bodyClass = ListAppend(local.bodyClass,arguments.content.layout ," ");
		}

		page &= "</head>#cr#";
		page &= "<body class='#local.bodyClass#' id='body'>#cr#";
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
			page &= "});#cr#";
			page &= "</script>#cr#";

		}
		page &= "</body>#cr#";
		page &= "</html>#cr#";

		return page;

	}

	/**
	 * @hint      Add a css file to the content
	 *
	 * @content  The page content
	 * @js       url of css file
	 *
	 */
	public void function addCss(required struct content, required string css) {
		ArrayAppend(arguments.content.css_files, arguments.css);
	}
	
	/**
	 * @hint      Add a javascript file to the content
	 *
	 * @content  The page content
	 * @js       url of javascritp file
	 *
	 */
	public void function addJs(required struct content, required string js) {
		ArrayAppend(arguments.content.js_files, arguments.js);
	}

	/**
	 * @hint    Loads a definition file
	 *
	 * @defFile  Full path to definition file
	 *
	 */
	public struct function loadDefFile(defFile) {
		if (NOT fileExists(arguments.defFile)) {
			throw("Static files definition file #arguments.defFile# not found");
		}
		local.tempData = FileRead(arguments.defFile);
		try {
			local.jsonData = DeserializeJSON(local.tempData);
		}
		catch (Any e) {
			throw(message="Unable to parse static files definition file #arguments.defFile#",detail=e.message & e.detail);	
		}

		return local.jsonData;
	}

	/** Add Google Analytics 4 script */
	public string function gtagScript(required string gtag) {
		local.tag = "	<script async src=""https://www.googletagmanager.com/gtag/js?id=#arguments.gtag#""></script>";
		local.tag &= "	<script>";
		local.tag &= "	  window.dataLayer = window.dataLayer || [];";
		local.tag &= "	  function gtag(){dataLayer.push(arguments);}";
		local.tag &= "	  gtag('js', new Date());";
		local.tag &= "	  gtag('config', '#arguments.gtag#');";
		local.tag &= "	</script>";
		return local.tag;
	}

}