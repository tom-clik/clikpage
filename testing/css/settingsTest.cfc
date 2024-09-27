/* WIP. Taken from imagegrid.cfm

Not sure where I'm going with this. Loading the Objects into it to persist in the application. Will then check it's loaded at the start of each page.

*/ 
component {

	public any function init() {
		// Style definition -- see link to css file ibid.
		variables.settingsDef = ExpandPath("../css/_styles/test_settings.xml");
		this.settingsObj = new clikpage.settings.settings(debug=1);
		this.contentObj = new clikpage.content.content(settingsObj=this.settingsObj);
		this.contentObj.debug = 1;
		this.contentObj.loadButtonDefFile( ExpandPath("/_assets/images/buttons.xml") );

		this.pageObj = new clikpage.page(debug=1);
		StructAppend(this.pageObj.content.static_css,{"reset":1});
		this.site={};
		this.menuData = deserializeJSON(FileRead(ExpandPath("../site/_out/sampleMenu.json")));
		local.tmp = deserializeJSON(FileRead(ExpandPath("../site/_out/sampleImages.json")));
		this.imagesData = tmp.images;
		this.imagesSetData = tmp.gallery;

		local.tmp = deserializeJSON(FileRead(ExpandPath("../site/_out/sampleArticles.json")));
		this.articlesData = tmp.articles;
		this.articlesSetData = tmp.test;

		loadSettings();

	}

	public void function loadSettings() {
		this.styles = this.settingsObj.loadStyleSettings(variables.settingsDef);
	}

	/**
	 * Add a content section to our pseudo site object
	 */
	public void function addCs(
		required struct site, 
		required string type, 
		         string class="",
		         string id,
		         array data=[]) {
		
		if (! arguments.keyExists("id")) {
			arguments.id = "test_#arguments.type#";
		}
		var cs = this.contentObj.new(id=arguments.id,type=arguments.type);
		cs["data"] = getCSData(arguments.type);

		addContent(cs);

		if (arguments.class != "") {
			cs["class"] = arguments.class;
		}

		StructAppend(arguments.site,{"cs" = {}},false);
		arguments.site.cs[arguments.id] = cs;
		
	}

	string function stylePath() {
		return expandPath("_generated/imagegrid.css");
	}

	
	string function css() {

		var css = ":root {\n";
		css &= this.settingsObj.colorVariablesCSS(this.styles);
		css &= this.settingsObj.fontVariablesCSS(this.styles);
		css &=  "\n}\n";
		css &= this.settingsObj.CSSCommentHeader("Content styling");
		
		css &= this.contentObj.contentCSS(styles=this.styles, content_sections=this.site.cs, media=this.styles.media, format=false);

		css = this.settingsObj.outputFormat(css=css,media=this.styles.media,debug=this.contentObj.debug);
		return css;
	}

	struct function pageData(required struct cs, struct data={}) {
		return this.contentObj.display(content=arguments.cs,data=arguments.data);
	}

	public function getCSData(required string type) {
		switch (arguments.type) {
			case "imagegrid":
				return this.imagesSetData;
				break;
			case "articlelist":
				return this.articlesSetData;
				break;
			case "menu":
				return this.menuData;
				break;
		}
		return [];
	}

	public function getSiteData(required string type) {
		switch (arguments.type) {
			case "imagegrid":
				return this.imagesData;
				break;
			case "articlelist":
				return this.articlesData;
				break;
			
		}

		return {};

	}

	/**
	 * @hint Add mock data to a content section according to type
	 *
	 * Some cs use the data mechanism to display their content
	 */
	private void function addContent(required struct cs) {
		switch (arguments.cs.type) {
			case "item":
			case "image":
				local.image = this.imagesData[this.imagesSetData[2]];
				arguments.cs.title = "title content";	
				arguments.cs.content = lorem(255);
				arguments.cs.image = local.image.image;
				arguments.cs.caption = local.image.description;				
				break;
			
			case "button":
				arguments.cs.content = "button label";
				break;
			
		}

	}

	/**
	 * Generate length of filler text
	 */
	string function lorem(len) {
		return left(
			"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
	tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
	quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
	consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse
	cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
	proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
			, arguments.len);

	}

}