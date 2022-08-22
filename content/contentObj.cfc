component {
	/** 
	 * Constructor 
	 *
	 * @settingsObj  pass in reference to intialised singleton settings object
	 * @types        list of content section types to load
	*/
	public contentObj function init (
		    required   any      settingsObj,
			           string   types="item,title,menu,text,image,imagegrid,articlelist,button"
		)  output=false {
		
		this.contentSections = {};
		this.debug = false;
		
		for (local.type in ListToArray(arguments.types)) {
			load(local.type);
		}
		
		variables.defaultMedia = [{"name"="main"}];
		this.settingsObj = arguments.settingsObj;
		// TO DO: strip utils down to just required sections, put in deepstruct appends
		// and just extend it in this.
		this.utils = CreateObject("component", "clikpage.utils.utilsold");

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
				 string link
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
		
		ret = processText(text=ret,debug=this.debug);
		
		return ret;
		
	}

	/** 
	@hint Wrap html in div with required attributes for clik system 
	
	There is duplication here as when we use a jsoup layout, we don't use this function as there isn't an easy
	way to replace node. Any functionality here needs to be duplicated in the functionality that places html into
	the layout.

	// Really? This sounds like nonsense. THP. TODO: use element.replaceWith()
	
	*/
	public string function wrapHTML(required struct content, required string html) {
		
		var ret = "<div id='#arguments.content.id#' class='" & getClassList(arguments.content) & "'>" &  NewLine() & arguments.html & "</div>";

		return ret;
	}

	/* Get class html attribute for a content section */
	public string function getClassList(required struct content) {
		
		var classstr = "cs-" & arguments.content.type;
		
		ListAppend(classstr,arguments.content.class, " ");
		
		return classstr;
	}

	/* get individual css for a content section

	 */
	/**
	 * [css description]
	 * @content      Content section
	 * @format       Format result. Turn off if joining e.g. generating a stylesheet
	 */
	public string function css(required struct content, boolean format=true) {
		
		var css = "";

		if (! StructKeyExists(arguments.content, "settings")) {
			return "/* Settings not defined for cs */";
		}
		
		css &= this.contentSections[arguments.content.type].css(styles=arguments.content.settings, selector="##" & arguments.content.id);

		if (arguments.format) {
			css = processText(css);
		}

		return css;
	}

	/**
	 * @hint Get complete css for all content section
	 *
	 * Loop over all the media queries and generate stylesheet for each CSS
	 * 
	 * @styles    Complete stylesheet with media and content fields
	 * @content_sections Struct of content sections
	 * @loadsettings     Update each cs with its settings. Turn off if this has been done. See settings()
	 */
	public string function stylesheet(required struct styles, required struct content_sections, boolean loadsettings=1) {

		var css_str = "";

		local.media = this.settingsObj.getMedia(arguments.styles);
		
		for (local.mediumname in local.media) {
			
			local.medium = local.media[local.mediumname];

			if (local.mediumname NEQ "main") {
				css_str &= "@media.#local.mediumname# {" & NewLine();
			}

			for (var id in arguments.content_sections) {

				var cs = arguments.content_sections[id];
				if (arguments.update) {
					// NB see TO DO in  settings function. No inheritance 
					settings(cs,arguments.styles);
				}
				
				if (local.mediumname EQ "main" OR StructKeyExists(cs.settings,local.mediumname)) {
					
					local.styles = 	local.mediumname EQ "main" ? local.cs_styles : local.cs_styles[local.mediumname];

					css_str &= this.contentSections[cs.type].css(styles=local.settings, selector="##" & id);
					
				}

			}

			if (local.mediumname NEQ "main") {
				css &= NewLine() & "}" & NewLine();
			}

		}
	}

	/**
	 * @hint Update settings for a content section
	 *
	 * NB MUST put back in in the settings function at the end. Currently broken
	 * due to change in media stuff. This  is needing for inheritance.
	 *
	 * NB this needs to work for containers as well. Do not break.
	 * 
	 */
	public void function settings(required struct content, required struct styles) {
		
		if (StructKeyExists(arguments.styles.content, arguments.content.id)) {
			arguments.content["settings"] = Duplicate(arguments.styles.content[arguments.content.id]);
		}
		else {
			arguments.content["settings"] =  {};
		}

		// Add in settings from classes e.g. scheme-whatever, cs-type
		if (StructKeyExists(arguments.content,"class")) {
			// to do: some sort of sort order for this.
			for (local.class in ListToArray(arguments.content.class," ")) {
				if (StructKeyExists(arguments.styles.content, local.class)) {
					deepStructAppend(arguments.content.settings,arguments.styles.content[local.class]);
				}
				
			}
		}

		// TO DO: inhertance
		
		// MUST DO: resurrect this.
		// this.contentSections[arguments.content.type].settings(arguments.content, arguments.styles.media);

	}	


	/**
	 * @hint Get struct of page content
	 
	For details of page content see the pageObj component.
	
	@content content section
	
	@seealso addPageContent
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
			if (StructKeyExists(arguments.content,local.key)) {
				switch (local.key) {
					case "static_css": case "static_js": 
						StructAppend(arguments.pageContent[local.key],arguments.content[local.key]);
					break;
					case "onready": case "css": 
						arguments.pageContent[local.key] &= arguments.content[local.key];
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
	 * Return standard html for an item with a title, text, and image
	 *
	 * This can be used on its own (general) or as part of a listing
	 * 
	 * @content  Content section
	 * @content  item settings. Either root settings for an individual item or item sub key from others
	 * @classes  Pass in struct by reference to return required classes for the wrapping div.
	 */
	public string function itemHtml(required struct content, struct settings={}, struct classes) {

		local.titletag = StructKeyExists(arguments.settings,"titletag") ? arguments.settings.titletag : "h3"; 
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
			local.buttons = this.utils.xml2data(local.xmlData);
			
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
	 * @hint Process text with \t\t and /-- --/ comments
	 *
	 * If we're not in debug we strip these out otherwise we replace with white space or comment markers.
	 * 
	 * @text    Text to process
	 * @debug   Pretty print output
	 */
	public string function processText(text,boolean debug=true) {
		var tab = arguments.debug ? chr(9) : "";
		var cr = arguments.debug ? chr(13) & chr(10) : "";

		// if (!arguments.debug) {
		// 	arguments.text = reReplace(arguments.text, "\/(\*|\-\-).*?(\*|\-\-)\/", "", "all");
		// }

		// this replace list has just stopped working. No idea why
		// return ReplaceList(arguments.text,"\n,\t","#cr#,#tab#,/*,*/");
		arguments.text = Replace(arguments.text,"/--","/*","all");
		arguments.text = Replace(arguments.text,"--/","*/","all");
		return ReplaceList(arguments.text,"\n,\t","#cr#,#tab#");
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


}