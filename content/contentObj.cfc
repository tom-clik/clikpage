component {
	/** Pseudo constructor 

	@types list of content section types to load
	*/
	public contentObj function init(string types="general,title,menu,text,image,imagegrid,articlelist,button", required settingsObj) {
		this.cr = chr(13) & chr(10);
		this.contentSections = {};
		this.debug = false;
		for (local.type in ListToArray(arguments.types)) {
			load(local.type);
		}
		variables.defaultMedia = [{"name"="main"}];
		this.settingsObj = arguments.settingsObj;
		this.utils = CreateObject("component", "clikpage.utils.utilsold");

		return this;
	}

	/** Load a content section type */
	private void function load(required string type) {
		this.contentSections[arguments.type] = createObject("component", "clikpage.content.#type#").init(this);
	}

	/** Create a new content section */
	public struct function new(required string id, string type="general", string class, string title, string content,string image, string caption, string link) {
		if (!StructKeyExists(this.contentSections,arguments.type)) {
			throw(message="type #arguments.type# is not a valid content sections type");
		}

		local.cs =this.contentSections[arguments.type].new(argumentCollection=arguments);

		return local.cs;
	}

	/* generate html for a content section */
	public string function html(required struct content) {
		
		var ret = this.contentSections[arguments.content.type].html(arguments.content);
		//ret = wrapHTML(arguments.content,ret);
		
		ret = replace(ret, "\n", this.cr,"all");
		ret = replace(ret, "\t", chr(9),"all");
		return ret;
		
	}

	/** 
	@hint Wrap html in div with required attributes for clik system 
	
	There is duplication here as when we use a jsoup layout, we don't use this function as there isn't an easy
	way to replace node. Any functionality here needs to be duplicated in the functionality that places html into
	the layout.
	
	*/
	public string function wrapHTML(required struct content, required string html) {
		
		var ret = "<div id='#arguments.content.id#' class='" & getClassList(arguments.content) & "'>" &  this.cr & arguments.html & "</div>";

		return ret;
	}

	/* Get class html attribute for a content section */
	public string function getClassList(required struct content) {
		var classstr = "";
		if (!StructIsEmpty(arguments.content.class)) {
			classstr = ListAppend(classstr,StructKeyList(arguments.content.class," "), " ");
		}
		return classstr;
	}

	/* get individual css for a content section */
	public string function css(required struct content, required array media) {
		
		var css = "";

		if (! StructKeyExists(arguments.content, "settings")) {
			return "/* Settings not defined for cs */";
		}

		

		for (local.mediaQuery in arguments.media) {

			local.medium = local.mediaQuery.name;

			if (StructKeyExists(arguments.content.settings, local.medium)) {
				
				if (local.medium != "main") {
					css &="@media.#local.medium# {\n";
				}
				
				css &= "##" & arguments.content.id & " {\n";
				css &= this.settingsObj.css(settings=arguments.content.settings[local.medium]);
				css &= "}\n";
				css &= this.contentSections[arguments.content.type].css(settings=arguments.content.settings[local.medium], selector="##" & arguments.content.id);
				
				css &= this.contentSections[arguments.content.type].panelCss(settings=arguments.content.settings[local.medium], selector="##" & arguments.content.id);

				if (local.medium != "main") {
					css &= "}\n";
				}
			}
		}

		return css;
	}



	/**
	 * @hint Update settings for a content section
	 * 
	 * 
	 */
	public struct function settings(required struct content, required struct styles ) {
		
		if (StructKeyExists(arguments.styles.content, arguments.content.id)) {
			// to do: inheritance
			arguments.content.settings = Duplicate(arguments.styles.content[arguments.content.id]);
		}
		else {
			arguments.content.settings =  {};
		}

		if (StructKeyExists(arguments.content,"class")) {
			// to do: some sort of sort order for this.
			for (local.class in arguments.content.class) {
				if (StructKeyExists(arguments.styles.content, local.class)) {
					fnDeepStructAppend(arguments.content.settings,arguments.styles.content[local.class]);
				}
				
			}
		}
			

		
		
		this.contentSections[arguments.content.type].settings(arguments.content, arguments.styles.media);

		return arguments.content.settings;

	}	


	/**
	 * @hint Get struct of page content
	 
	For details of page content see the pageObj component.

	Individual cs page content can be appended to an existing pageContent struct with the methd addPageContent

	@content content section
	
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
	 * Each content section has content like static file references. As part of the page build
	 * process, these need amalgamating. Some are struct appended, some text appeneded.
	 *
	 * @pageContent Main page content
	 * @content     content sections
	 */
	public void function addPageContent(required struct pageContent, required struct content) {
		
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
			js = "console.log('onready for #arguments.content.id#');"& this.cr & js;
			js = replace(js, "\n", this.cr,"all");
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
	 * Appends the second struct to the first.
	 */
	void function fnDeepStructAppend(struct struct1, struct struct2, overwrite="true") output=false {
		
		for(local.key IN arguments.struct2){
			if(StructKeyExists(arguments.struct1,local.key) AND 
				IsStruct(arguments.struct2[local.key]) AND 
				IsStruct(arguments.struct1[local.key])){
				fnDeepStructAppend(arguments.struct1[local.key],arguments.struct2[local.key],arguments.overwrite);
			}
			else if (arguments.overwrite OR NOT StructKeyExists(arguments.struct1,local.key)){
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
	 



}