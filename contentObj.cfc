component {

	public contentObj function init(string types="general,title,menu,text,image,imagegrid,articlelist") {
		this.cr = chr(13) & chr(10);
		this.contentSections = {};
		this.debug = false;
		for (local.type in ListToArray(arguments.types)) {
			load(local.type);
		}
		
		return this;
	}

	public void function load(required string type) {
		this.contentSections[arguments.type] = createObject("component", "clikpage.content.#type#").init(this);
	}

	public struct function new(required string id, string type="general", string class, string title, string content,string image, string caption, string link) {
		if (!StructKeyExists(this.contentSections,arguments.type)) {
			throw(message="type #arguments.type# is not a valid content sections type");
		}
		local.cs =this.contentSections[arguments.type].new(argumentCollection=arguments);
		this.contentSections[arguments.type].settings(local.cs);

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
	/* 
	@hint Wrap html in div with required atteibutes for clik system 
	
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
	public string function css(required struct content) {
		
		var css = this.contentSections[arguments.content.type].css(arguments.content, "##" & arguments.content.id);

		if (this.debug) {
			css = "/* css for #arguments.content.id# [#arguments.content.type#] */\n" & css;
			css = replace(css, "\n", this.cr,"all");
			css = replace(css, "\t", chr(9),"all");
		}
		else {
			/** to do: rewrite with java regex to avoid cf bugs */
			css = replace(css, "\t", "","all");
			css = replace(css, "\n", "","all");
			css = REReplace(css,"\/\*.*?\*\/","","all");
		}
		
		return css;
	}

	/* get individual css for a content section */
	public string function css(required struct content) {
		
		var css = this.contentSections[arguments.content.type].css(arguments.content, "##" & arguments.content.id);

		if (this.debug) {
			css = "/* css for #arguments.content.id# [#arguments.content.type#] */\n" & css;
			css = replace(css, "\n", this.cr,"all");
			css = replace(css, "\t", chr(9),"all");
		}
		else {
			/** to do: rewrite with java regex to avoid cf bugs */
			css = replace(css, "\t", "","all");
			css = replace(css, "\n", "","all");
			css = REReplace(css,"\/\*.*?\*\/","","all");
		}
		
		return css;
	}

	/**
	 * @hint Get struct of page content
	 
	For details of page content see the pageObj component.

	Individual cs page content can be appended to an existing pageContent struct with the methd addPageContent

	@content content section
	@get inline css. Usually this will have been saved to a separate file
	*/
	public struct function getPageContent(required struct content, boolean css = false) {
		
		var pageContent = {};
		
		pageContent["static_css"] = getStaticCSS(arguments.content);
		pageContent["static_js"] = getStaticJS(arguments.content);
		pageContent["onready"] = getOnready(arguments.content);
		
		if (arguments.css) {
			pageContent["css"] = this.css(arguments.content);
		}	
		
		return pageContent;

	}

	public void function addPageContent(required struct pageContent, required struct content) {
		
		for (local.key in ['static_css','static_js','onready','css']) {
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



}