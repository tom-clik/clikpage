component extends="utils.baseutils" {  // TODO: put back in output=false
	/** 
	 * Constructor 
	 *
	 * @settingsObj  pass in reference to intialised singleton settings object
	 * @types        list of content section types to load
	*/
	public content function init (
		    required   any      settingsObj,
			           string   types="item,grid,title,menu,text,image,imagegrid,articlelist,button,form,columns",
					   boolean  debug=false
		) {
		
		this.settingsObj = arguments.settingsObj;
		
		this.contentSections = {};
		this.debug = arguments.debug;
		super.utils();
		// WILLDO: better solution for utils
		this.deepStructAppend = variables.utils.utils.deepStructAppend;
		
		for (local.type in ListToArray(arguments.types)) {
			load(local.type);
		}
		
		variables.defaultMedia = [{"name"="main"}];
		
		

		return this;
	}

	/** Load a content section type */
	private void function load(required string type) {
		try {
			this.contentSections[arguments.type] = createObject("component", "clikpage.content." & arguments.type).init(this);
		}
		catch (any e) {
			local.extendedinfo = {"tagcontext"=e.tagcontext};
			local.temp = deserializeJSON( e.extendedinfo );
			if (isStruct(local.temp)) {
				structAppend(local.extendedinfo, local.temp);
			}
			throw(
				extendedinfo = SerializeJSON(local.extendedinfo),
				message      = "Unable to update type #arguments.type#:" & e.message, 
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
				 array  data,
				 struct style = {}
				 ) {

		if (!StructKeyExists(this.contentSections,arguments.type)) {
			throw(message="type #arguments.type# is not a valid content sections type",detail="Valid types are #StructKeyList(this.contentSections)#");
		}

		local.cs =this.contentSections[arguments.type].new(argumentCollection=arguments);

		return local.cs;
	}

	/* generate html for a content section */
	public string function html(required struct content, struct data={}) {
		
		var ret = this.contentSections[arguments.content.type].html(content=arguments.content, data=arguments.data);
		
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
	public struct function display(required struct content, struct data={}) {
		local.ret["html"] = wrapHTML(arguments.content,html(arguments.content,data));
		local.ret["pagecontent"] = getPageContent(arguments.content,data);
		return local.ret;
	}

	/**
	 * Get class html attribute for a content section
	 * @content The content object
	 * @return string to use as value of class attribute
	 */
	public string function getClassList(required struct content) {
		
		return this.contentSections[arguments.content.type].getClasses(arguments.content);
	
	}
	/**
	 * Load settings for a collection of content sections
	 * 
	 * @styles           Struct of styles for addition of class settings
	 * @content_sections Struct of content section definitions
	 * @media            Struct of media query definitions
	 * @reload           Reload settings if already present
	 */
	public void function loadSettings(
		required struct   styles, 
		required struct   content_sections, 
		required struct   media,
		         boolean  reload=true, 
		) {
		
		for (var id in arguments.content_sections) {
			local.cs = arguments.content_sections[id];
			if (NOT StructKeyExists(this.contentSections, local.cs.type)) {
				local.extendedinfo = {"cs"=local.cs};
				throw(
					extendedinfo = SerializeJSON(local.extendedinfo),
					message      = "Undefined content type (#local.cs.type#) ",
					detail       = "See content object for details of available content types",
					errorcode    = "content.001"		
				);
				
			}

			if (arguments.reload OR NOT StructKeyExists(local.cs,"settings")) {
				try {
					arguments.content_sections[id] =  new(argumentCollection=local.cs);
				}
				catch (any e) {
					local.extendedinfo = {
						"tagcontext"=e.tagcontext,
						"arguments"=local.cs
					};
					throw(
						extendedinfo = SerializeJSON(local.extendedinfo),
						message      = "Unable to create cs:" & e.message, 
						detail       = e.detail,
						errorcode    = "content.loadSettings.001"		
					);
					
				}
				try {
					settings(arguments.content_sections[id],arguments.styles,arguments.media);
				}
				catch (any e) {
					local.extendedinfo = {
						"tagcontext"=e.tagcontext,
						 "content_section"=arguments.content_sections[id]
					};
					throw(
						extendedinfo = SerializeJSON(local.extendedinfo),
						message      = "Unable to add settings for cs:" & e.message, 
						detail       = e.detail,
						errorcode    = "content.loadSettings.002"		
					);
				}
			}
		}
  
	}

	/**
	 * Generate complete CSS for a collection of content sections
	 * 
	 * @styles           Struct of styles for addition of class settings
	 * @content_sections Struct of content section definitions
	 *
	 * @return CSS stylesheet
	 */
	
	public string function contentCSS(
		required struct  styles, 
		required struct  content_sections, 
				 boolean debug=this.debug
		) localmode=true {

		cr = arguments.debug ? newLine() : "";
		
		cs_styles = [];

		for (id in arguments.content_sections) {
			cs_styles.append( css(styles=arguments.styles,content=arguments.content_sections[id],debug=arguments.debug) );
		}

		return this.settingsObj.contentCSS(css=cs_styles,media=arguments.styles.media);

	}

	/**
	 * @hint Get css for a content section
	 *
	 * @styles       Whole site stylesheet with media etc
	 * @content      Content section (we need "id", "class", and "type")
	 * @return       struct keyed by medium
	 */
	public struct function css(required struct styles, required struct content, boolean debug=this.debug, debugcontent={} ) localmode=true {
		
		css_out = {};

		if (! StructKeyExists(arguments.styles, "media") ) {
			throw("No media defined in stylesheet");
		}

		// Allow settings to be applied via "schemes" (aka classes)
		// MUSTDO: same logic as for layoutCSS in settings.cfc
		// Needs to be in order
		styles_all = {}; 
		if ( arguments.content.keyExists("class") ) {
			for ( class in ListToArray(arguments.content.class, " ") ) {
				if ( arguments.styles.keyExists(class) ) {
					variables.utils.utils.deepStructAppend(styles_all,arguments.styles[class],true);
				}
			}
		}

		if ( arguments.styles.keyExists( arguments.content.id ) ) {
			variables.utils.utils.deepStructAppend(styles_all,arguments.styles[arguments.content.id],true);
		}

		if (! StructCount( styles_all ) ) {
			if (arguments.debug) css_out["main"] = "/* No styles defined for cs #arguments.content.id# */" & newLine() & newLine();
			return css_out;
		}

		if (arguments.debug ) {
			arguments.debugcontent["styles_all"] =styles_all;
		}

		for (medium in arguments.styles.media) {
			if (! StructKeyExists( styles_all,  medium ) ) {
				if (arguments.debug) css_out["#medium#"] = "/* #medium# Settings not defined for cs #arguments.content.id# */" & newLine() & newLine();
				continue;
			}
			css_out["#medium#"] =  this.contentSections[arguments.content.type].css(styles=styles_all[medium], selector="##" & arguments.content.id, debug=arguments.debug);
		}

		return css_out;
		
	}

	/**
	 * @hint Update settings for a content section
	 *
	 */
	public void function settings(required struct content, required struct styles, required struct media) {
		
		throw("needs redoing...possibly deprecated");

		var settings = {"main"={}};
		// add default styling
		variables.utils.utils.deepStructAppend(settings.main,this.contentSections[arguments.content.type].defaultStyles);

		// Add in settings from classes e.g. scheme-whatever, cs-type
		if (StructKeyExists(arguments.content,"class")) {
			// make sure we apply the styles in order.
			for (local.section in arguments.styles) {
				if (listFindNoCase(arguments.content.class, local.section, " ")) {
					variables.utils.utils.deepStructAppend(settings,arguments.styles[local.section]);
				}
			}
		}

		if (StructKeyExists(arguments.styles, arguments.content.id)) {
			variables.utils.utils.deepStructAppend(settings,arguments.styles[arguments.content.id]);
		}

		if (StructKeyExists(arguments.content, "style")) {
			variables.utils.utils.deepStructAppend(settings,arguments.content.style);
		}
		
		arguments.content["settings"] = settings;
			
		try{
			this.contentSections[arguments.content.type].inheritSettings(settings=arguments.content.settings, media=arguments.media);
		} 
		catch (any e) {
			local.extendedinfo = {"tagcontext"=e.tagcontext,"content"=arguments.content};
			throw(
				extendedinfo = SerializeJSON(local.extendedinfo),
				message      = "Error inheriting settings:" & e.message, 
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
	public struct function getPageContent(required struct content, struct data={}) {
		
		var pageContent = {};
		
		pageContent["static_css"] = getStaticCSS(arguments.content);
		pageContent["static_js"] = getStaticJS(arguments.content);
		pageContent["onready"] = getOnready(arguments.content,pageContent,data);
		
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
	 * @pageContent     page content for individual cs (See getPageContent())
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

	public String function getOnready(required struct content, required struct pageContent, struct data={}) {
		var js =this.contentSections[arguments.content.type].onReady(arguments.content,pageContent,data);
		
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
	 * to apply the necessary classes to the surrounding div. This _isn't_ a vestigial remnant from
	 * the old class based styling system, it is just to allow reuse of item html in different cases
	 * 
	 * @item  Item with keys title, description, image, link, caption, 
	 * @classes  Pass in struct by reference to return required classes for the wrapping div.
	 */
	public string function itemHtml(required struct item, string link="", struct settings={}, struct classes) {

		local.titletag = arguments.settings.titletag ? : "h3"; 
		local.hasLink = arguments.link != "";

		var linkStart = (local.hasLink) ? "<a href='#arguments.link#'>" : "";
		var linkEnd = (local.hasLink) ? "</a>" : "";

		arguments.classes["item"] = 1;
		
		var cshtml = "<div class='itemInner'>\n";

		cshtml &= "\t<div class='title'><" & local.titletag & ">" & linkStart & arguments.item.title & linkEnd &  "</" & local.titletag & "></div>\n";
		cshtml &= "\t<div class='imageWrap'>\n";
		if (StructKeyExists(arguments.item,"image")) {
			cshtml &= "\t<figure>\n";
			cshtml &= "\t\t#linkStart#<img src='" & arguments.item.image & "'>#linkEnd#\n";
			if (StructKeyExists(arguments.item,"caption")) {
				cshtml &= "\t\t<figcaption>" & arguments.item.caption & "</figcaption>\n";
			}
			cshtml &= "\t</figure>\n";
		}
		else {
			arguments.classes["noimage"] = 1;
		}
		cshtml &= "\t</div>\n";

		cshtml &= "\t<div class='textWrap'>";
		cshtml &= arguments.item.description ? : "";
		if (local.hasLink && StructKeyExists(arguments.settings,"morelink")) {
			cshtml &= "<span class='morelink'>" & linkStart & arguments.settings.morelink & linkEnd & "</span>";
		}
		cshtml &= "</div>\n</div>";

		return cshtml;

	}

	// putting this here not until I can think of a better
	// way of doing this.
	public string function popupHTML(required string id) {
		return replace("
		    <div id='{id}' class='popup'>
				<div class='popup_inner'>
				</div>
				<div id='{id}closeButton' class='closeButton button auto'>
					<a href='##{id}.close'>
						<svg  class='icon'  viewBox='0 0 357 357'><use xlink:href='/_assets/images/close47.svg##close'></svg>
						<label>Close</label>
					</a>
				</div>
				<div id='{id}nextButton' class='nextButton button auto'>
					<a href='##{id}.next'>
						<svg  class='icon' preserveAspectRatio='none' viewBox='0 0 16 16'><use xlink:href='/_assets/images/chevron-right.svg##chevron-right'></svg>
						<label>Next</label>
					</a>
				</div>
				<div id='{id}previousButton' class='previousButton button auto'>
					<a href='##{id}.previous'>
						<svg  class='icon' preserveAspectRatio='none' viewBox='0 0 16 16' viewBox='0 0 16 16'><use xlink:href='/_assets/images/chevron-left.svg##chevron-left'></svg>
						<label>Previous</label>
					</a>
				</div>
			</div>","{id}",arguments.id, "all");
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
			
			local.xmlData = variables.utils.utils.fnReadXML(arguments.filename,"utf-8");
			local.buttons = variables.utils.xml.xml2data(local.xmlData);
			this.contentSections["button"].addShapes(local.buttons);
			
		}
		catch (Any e) {
			throw(message="Unable to load button definition file", detail=e.message & e.detail);
		}
		

	}

	/* Get list of available shapes to display in a settings edit form */
	public array function shapeOptions() {
		local.ret = [];
		local.shapes =this.contentSections["button"].getShapes();
		for ( local.shape in  local.shapes) {
			local.shapeObj = 
			arrayAppend( local.ret, {"name":local.shapes[local.shape].name,"value":local.shape} );
		}
		return local.ret;
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
	 * Tools function to get all settings definitions
	 */
	public struct function getSettings() {
		var settings = {};
		for (local.type in this.contentSections) {
			settings[local.type]["styleDefs"] = this.contentSections[local.type].styleDefs;
			settings[local.type]["states"] = this.contentSections[local.type].states;
			settings[local.type]["panels"] = this.contentSections[local.type].panels;
		}

		return settings;
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

	/**
	 * Return available options for a given type and setting value
	 */
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