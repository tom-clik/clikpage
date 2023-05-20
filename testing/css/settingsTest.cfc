/* WIP. Taken from imagegrid.cfm

Not sure where I'm going with this. Loading the Objects into it to persist in the application. Will then check it's loaded at the start of each page.

*/ 
component {

	public any function init() {
		// Style definition -- see link to css file ibid.
		local.settingsDef = ExpandPath("../styles/testStyles.xml");
		this.settingsObj = new clikpage.settings.settings(debug=1);
		this.contentObj = new clikpage.content.content(settingsObj=this.settingsObj);
		this.contentObj.debug = 1;
		this.site={};
		this.image_sets = getImages(this.site);

		this.styles = this.settingsObj.loadStyleSettings(local.settingsDef);
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
		StructAppend(arguments.site,{"cs" = {}},false);

		if (! arguments.keyExists("id")) {
			arguments.id = "test_#arguments.type#";
		}
		arguments.site.cs[arguments.id] = this.contentObj.new(id=arguments.id,type=arguments.type);
		arguments.site.cs[arguments.id]["data"] = arguments.data;
		if (arguments.class != "") {
			arguments.site.cs[arguments.id].class = arguments.class;
		}
		
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
		for (local.id in this.site.cs) {
			css &= contentCSS(this.site.cs[local.id]);
		}
		css = this.settingsObj.outputFormat(css=css,media=this.styles.media,debug=this.contentObj.debug);
		return css;
	}

	/**
	 * Return an image set of all photos and updates site.images with the full data
	 */
	array function getImages(required struct site, image_path="/images/") {
		
		local.myXML = application.utils.fnReadXML(ExpandPath("../../sample/_data\data\photos.xml"));
		local.images = application.XMLutils.xml2Data(local.myXML);
		arguments.site.images = [=];
		local.image_set = [];

		for (local.image in local.images) {
			local.image.image = image_path & local.image.image_thumb;
			local.image.image_thumb = image_path & local.image.image_thumb;
			arguments.site.images[local.image.id] = local.image;
			ArrayAppend(local.image_set, local.image.id);
		}

		return local.image_set;

	}

	string function contentCSS(required struct cs) {
		local.site_data = { "#arguments.cs.id#" = arguments.cs};
		local.css = this.contentObj.contentCSS(styles=this.styles, content_sections=local.site_data, media=this.styles.media, format=false);
		return local.css;
	}

	struct function pageData(required struct cs, struct data={}) {
		return this.contentObj.display(content=arguments.cs,data=arguments.data);
	}

	
}