component {
	/** 
	 * Constructor 
	 *
	 * @settingsObj  pass in reference to intialised singleton settings object
	 * @types        list of content section types to load
	*/
	public content function init (
		    required   any      settingsObj,
			           string   types="item,grid,container,columns,title,menu,text,image,imagegrid,articlelist,button"
		)  output=false {
		
		this.contentSections = {};
		this.debug = false;
		
		for (local.type in ListToArray(arguments.types)) {
			load(local.type);
		}
		
		variables.defaultMedia = [{"name"="main"}];
		this.settingsObj = arguments.settingsObj;
		this.utils = CreateObject("component", "utils.utils");
		this.XMLutils = CreateObject("component", "utils.xml");

		return this;
	}

	/** Load a content section type */
	private void function load(required string type) {
		try {
			this.contentSections[arguments.type] = createObject("component", "clikpage.content." & arguments.type).init(this);
		}
		catch (any e) {
			local.extendedinfo = {"tagcontext"=e.tagcontext};
			throw(
				extendedinfo = SerializeJSON(local.extendedinfo),
				message      = "Unable to local cs type #arguments.type#:" & e.message, 
				detail       = e.detail,
				errorcode    = "clikpage.contentObj.load"
			);
		}
		
	}

	/** Create a new content section */
	public struct function new(
		required string id, 
				 string type="item", 
				 string class,
				 string title, 
				 string content,
				 string image, 
				 string caption, 
				 string link,
				 struct data
				 ) {

		if (!StructKeyExists(this.contentSections,arguments.type)) {
			throw(message="type #arguments.type# is not a valid content sections type",detail="Valid types are #StructKeyList(this.contentSections)#");
		}

		local.cs =this.contentSections[arguments.type].new(argumentCollection=arguments);

		return local.cs;
	}


	/* generate html for a content section */
	public string function html(required struct content) {
		
		var ret = this.contentSections[arguments.content.type].html(arguments.content);
		//ret = wrapHTML(arguments.content,ret);
		
		ret = this.settingsObj.outputFormat(css=ret,media={},debug=this.debug);
		
		return ret;
		
	}

	/** 
	@hint Wrap html in div with required attributes for clik system 
	
	There is duplication here as when we use a jsoup layout, we don't use this function as there isn't an easy
	way to replace node. Any functionality here needs to be duplicated in the functionality that places html into
	the layout.

	// Really? This sounds like nonsense. THP. TODO: use element.replaceWith()
	
	*/
	private string function wrapHTML(required struct content, required string html) {
		
		var ret = "<div id='#arguments.content.id#' class='" & getClassList(arguments.content) & "'>" &  NewLine() & arguments.html & "</div>";

		return ret;
	}

	/**
	 * @hint Return html and page elements for a CS
	 *
	 * This was always the preferred mechanism in Clikpic. It's the basis of the caching
	 * mechanism. See notes about wrapHTML
	 *
	 * See no reason not to revert to using this.
	 *
	 * TODO: start using this in prefence to the separate elements
	 * 
	 */
	public struct function display(required struct content) {
		local.ret["html"] = wrapHTML(arguments.content,html(arguments.content));
		local.ret["pagecontent"] = getPageContent(arguments.content);
		return local.ret;
	}

	/**
	 * Add a class(es) to a content section
	 * 
	 * @content The content object
	 * @class Class to add
	 */
	private void function addClass(required struct content, required string class) {
		
		var classstr = "cs-" & arguments.content.type;

		ListAppend(classstr,arguments.content.class, " ");
		
		return classstr;
	}
		
	/**
	 * Get class html attribute for a content section
	 * @content The content object
	 * @return string to use as value of class attribute
	 */
	public string function getClassList(required struct content) {
		
		var classstr = "cs-" & arguments.content.type;
		
		classstr = ListAppend(classstr,arguments.content.class, " ");

		return classstr;
	}

	/**
	 * Generate CSS for a collection of content sections
	 * 
	 * @styles           Struct of styles for each cs.
	 * @content_sections Struct of content section definitions
	 * @media            Struct of media query definitions
	 * @loadsettings     Load settings for each CSS
	 * 
	 * @return CSS stylesheet
	 */
	
	public string function contentCSS(required struct styles, required struct content_sections, required struct media, boolean loadsettings=1, boolean format=true) {
		
		var css_out = "";
		var cs = false;

		if (arguments.loadsettings) {
			for (var id in arguments.content_sections) {
				cs = arguments.content_sections[id];
				settings(cs,arguments.styles,arguments.media);
			}
		}
		
		for (var medium in arguments.media ) {

			var media = arguments.media[medium];
			var media_css = "";

			for (var id in arguments.content_sections) {
				
				cs = arguments.content_sections[id];
				
				media_css &= css(cs,medium,false);
				
			}

			if (media_css NEQ "") {
				if (medium NEQ "main") {
					css_out &= "@media.#medium# {\n" & this.settingsObj.indent(media_css,1) & "\n}\n";
				}
				else {
					css_out &= media_css;
				}
			}
		}

		if (arguments.format) {
			css_out = this.settingsObj.outputFormat(css=css_out, media=arguments.media,debug=this.debug);
		}
		
		return css_out;

	}

	/**
	 * @hint Get css for a content section
	 *
	 * @content      Content section
	 * @format       Format result. Turn off if concatenating many cs
	 * @return       css string
	 */
	public string function css(required struct content, medium="main",boolean format=true) {
		
		var css = "";

		if (! StructKeyExists(arguments.content, "settings")) {
			return "/* Settings not defined for cs */";
		}
		if (! StructKeyExists(arguments.content.settings,arguments.medium)) {
			return "/* #arguments.medium# Settings not defined for cs */";
		}
		
		css &= this.contentSections[arguments.content.type].css(styles=arguments.content.settings[arguments.medium], selector="##" & arguments.content.id);
		
		if (arguments.format) {
			css = this.settingsObj.outputFormat(css=css,media={},debug=this.debug);
		}

		return css;
	}

	/**
	 * @hint Update settings for a content section
	 *
	 * NB this needs to work for containers as well. Do not break.
	 * 
	 */
	public void function settings(required struct content, required struct styles, required struct media) {
		
		if (StructKeyExists(arguments.styles, arguments.content.id)) {
			arguments.content["settings"] = Duplicate(arguments.styles[arguments.content.id]);
		}
		else {
			arguments.content["settings"] = {};
		}

		StructAppend(arguments.content["settings"],{"main"={}},false);

		// Add in settings from classes e.g. scheme-whatever, cs-type
		if (StructKeyExists(arguments.content,"class")) {
			// to do: some sort of sort order for this.
			for (local.class in ListToArray(arguments.content.class," ")) {
				if (StructKeyExists(arguments.styles, local.class)) {
					deepStructAppend(arguments.content.settings,arguments.styles[local.class]);
				}
				
			}
		}

		// add default styling
		deepStructAppend(arguments.content.settings.main,this.contentSections[arguments.content.type].defaultStyles,false);
			
		try{
			this.contentSections[arguments.content.type].inheritSettings(settings=arguments.content.settings, media=arguments.media);
		} 
		catch (any e) {
			local.extendedinfo = {"tagcontext"=e.tagcontext,"content"=arguments.content};
			throw(
				extendedinfo = SerializeJSON(local.extendedinfo),
				message      = "Error getting media settings" & e.message, 
				detail       = e.detail
			);
		}
		

	}	


	/**
	 * @hint Get struct of page content for a content section
	 *  
	 * For details of page content see the pageObj component.
	 * 
	 * @content content section
	 * @return struct on page content keys (static_css,static_js,onready)
	 * @see addPageContent
	 */
	public struct function getPageContent(required struct content) {
		
		var pageContent = {};
		
		pageContent["static_css"] = getStaticCSS(arguments.content);
		pageContent["static_js"] = getStaticJS(arguments.content);
		pageContent["onready"] = getOnready(arguments.content);
		
		return pageContent;
		
	}

	/**
	 * @hint Add page content elements for a content section to a main page struct
	 *
	 * Note we add css if it is there. This is ok for preview. For a live site you
	 * want to ensure the stylesheet generation is done offline.
	 *
	 * See [TODO: document the stylesheet generation process]()
	 *
	 * @page            Main page content
	 * @pageContent     page content for indivudal cs (See getPageContent())
	 */
	public void function addPageContent(required struct page, required struct pageContent) {
		
		for (local.key in ['static_css','static_js','onready','css']) {
			if (StructKeyExists(arguments.pageContent,local.key)) {
				switch (local.key) {
					case "static_css": case "static_js": 
						StructAppend(arguments.page[local.key],arguments.pageContent[local.key]);
					break;
					case "onready": case "css": 
						arguments.page[local.key] &= arguments.pageContent[local.key];
					break;
					default:
				}
			}
		}
		
	}

	public Struct function getStaticCSS(required struct content) {
		return this.contentSections[arguments.content.type].getStaticCss();
	}
	
	public Struct function getStaticJS(required struct content) {
		return this.contentSections[arguments.content.type].getStaticJs();
	}

	public String function getOnready(required struct content) {
		var js =this.contentSections[arguments.content.type].onReady(arguments.content);
		
		if (this.debug) {
			js = "console.log('onready for #arguments.content.id#');"& NewLine() & js;
			js = replace(js, "\n", NewLine(),"all");
			js = replace(js, "\t", chr(9),"all");
		}
		else {
			/** to do: rewrite with java regex to avoid cf bugs */
			js = replace(js, "\t", "","all");
			js = replace(js, "\n", "","all");
			js = REReplace(js,"\/\*.*?\*\/","","all");
		}

		return js;
	}

	/**
	 * @hint Return standard html for an item with a title, text, and image
	 *
	 * This can be used on its own (general) or as part of a listing. Accordingly we need a mechanism
	 * to apply the necessary classes to the surrounding div. This *isn't* a vestigial remnant from
	 * the old class based styling system, it is just to allow reuse of item html in different cases
	 * 
	 * @content  Content section
	 * @settings  item settings. Required are the settings that adjust the html
	 * @classes  Pass in struct by reference to return required classes for the wrapping div.
	 */
	public string function itemHtml(required struct content, struct settings={}, struct classes) {

		local.titletag = arguments.settings.titletag ? : "h3"; 
		local.hasLink = StructKeyExists(arguments.content,"link");

		var linkStart = (local.hasLink) ? "<a href='#arguments.content.link#'>" : "";
		var linkEnd = (local.hasLink) ? "</a>" : "";

		arguments.classes["item"] = 1;
		
		var cshtml = "";

		cshtml &= "\t<" & local.titletag & " class='title'>" & linkStart & arguments.content.title & linkEnd &  "</" & local.titletag & ">\n";
		cshtml &= "\t<div class='imageWrap'>\n";
		if (StructKeyExists(arguments.content,"image")) {
			cshtml &= "\t\t<img src='" & arguments.content.image & "'>\n";
			if (StructKeyExists(arguments.content,"caption")) {
				cshtml &= "\t\t<div class='caption'>" & arguments.content.caption & "</div>\n";
			}
		}
		else {
			arguments.classes["noimage"] = 1;
		}
		cshtml &= "\t</div>\n";

		cshtml &= "\t<div class='textWrap'>";
		cshtml &= arguments.content.content;
		if (local.hasLink && StructKeyExists(arguments.settings,"morelink")) {
			cshtml &= "<span class='morelink'>" & linkStart & arguments.settings.morelink & linkEnd & "</span>";
		}
		cshtml &= "</div>";

		return cshtml;

	}

	/**
	 * Appends the second struct to the first.
	 */
	void function deepStructAppend(struct struct1, struct struct2, overwrite="true") output=false {
		
		for(local.key IN arguments.struct2){
			if(StructKeyExists(arguments.struct1,local.key) AND 
				IsStruct(arguments.struct2[local.key]) AND 
				IsStruct(arguments.struct1[local.key])){
				deepStructAppend(arguments.struct1[local.key],arguments.struct2[local.key],arguments.overwrite);
			}
			else if (arguments.overwrite OR NOT StructKeyExists(arguments.struct1,local.key)){
				arguments.struct1[local.key] = Duplicate(arguments.struct2[local.key]);
			}
		}
	}

	/**
	 * Updates a struct with values from second struct
	 */
	void function deepStructUpdate(struct struct1, struct struct2) output=false {
		
		for(local.key IN arguments.struct1){
			if(StructKeyExists(arguments.struct2,local.key)) {
				if (IsStruct(arguments.struct1[local.key])) {
					deepStructUpdate(arguments.struct1[local.key],arguments.struct2[local.key]);
				}
			}
			else {
				arguments.struct1[local.key] = Duplicate(arguments.struct2[local.key]);
			}
		}
	}


	/**
	 * @hint Utitlty to load XML file for shape definitions
	 *
	 * Usually these are defined in a stylesheet, but this utility can be used for testing etc
	 *
	 * It loads a separate XML file and calls the addShapes method of the button component
	 * 
	 * @filename Filename of definition file
	 */
	void function loadButtonDefFile(required string filename) {
		
		try {
			if (!StructKeyExists(this.contentSections,"button")) {
				throw("buttons content section not defined");
			}
			local.xmlData = this.utils.fnReadXML(arguments.filename,"utf-8");
			local.buttons = this.XMLutils.xml2data(local.xmlData);
			
			this.contentSections["button"].addShapes(local.buttons);
			
		}
		catch (Any e) {
			throw(message="Unable to load button definition file", detail=e.message & e.detail);
		}
		

	}

	/** Documentation function to  list the available types */
	public string function listTypes() {
		var html = "";
		for (local.type in this.contentSections) {
			local.cs = this.contentSections[local.type].getDetails();
			html &= "<div class'type'>";
			html &= "<h3>#local.cs.title# [#local.type#]</h3>";
			html &= "<div class='description'>#local.cs.description#</div>";
			html &= "<div class='links'><a href='testContent_#local.type#.cfm'>test</a></div>";
			html &= "</div>";
		}

		return html;
	}
	 
	
	/** 
	 * @hint Indent string with \t characters 
	 * 
	 * These can be converted to tabs for pretty printing or stripped for compression
	 *
	 * @text text to indent
	 * @indent Number of tabs to indent.
	 */
 
	public string function indent(text,indent) {
		var tab = repeatString("\t", indent);
		var retVal = tab & Replace(arguments.text,"\n","\n#tab#","all");
		if (Right(retVal,2) eq "\t") {
			retVal = retVal.removeChars(retval.len() -1, 2);

		}
		return retVal;
	}


	public array function options(required string type, required string setting) {
		try {
			
			if (NOT StructKeyExists(this.contentSections,arguments.type)) {
				throw("Type #arguments.type#  not defined");
			}
			if (NOT StructKeyExists(this.contentSections[arguments.type].styleDefs,arguments.setting)) {
				throw("Setting #arguments.setting# not defined for type #arguments.type#");
			}
			if (NOT StructKeyExists(this.contentSections[arguments.type].styleDefs[arguments.setting],"options")) {
				throw("Setting #arguments.setting# for type #arguments.type# has no options");
			}

			return this.contentSections[arguments.type].styleDefs[arguments.setting].options;
		}
		catch (any e) {
			local.extendedinfo = {"tagcontext"=e.tagcontext,"type"=arguments.type,"setting"=arguments.setting};
			throw(
				extendedinfo = SerializeJSON(local.extendedinfo),
				message      = e.message, 
				detail       = e.detail,
				errorcode    = "contentObj.options.1"		
			);
		}
		

	}

}