component extends="contentSection" {

	variables.type = "imagegrid";
	variables.title = "Image grid";
	variables.description = "Images in grid";
	variables.defaults = {
		"title"="Untitled",
		"content"="Undefined content",
	};

	function init(required content contentObj) {
		
		super.init(arguments.contentObj);
		
		variables.static_css = {"images"=1,"colorbox"=1};
		variables.static_js = {"masonry"=1,"colorbox"=1};
		
		this.selectors = [
			{"name"="main", "selector"=""},
			{"name"="item", "selector"=" > *"}
		];

		this.styleDefs = [
			"masonry" : {"type":"boolean","default":0},
			"popup" : {"type":"boolean","default":0},
			"grid-gap": {"type":"dimension"},
			"row-gap": {"type":"dimension"},
			"grid-width": {"type":"dimension"},
			"grid-max-width": {"type":"dimension"},
			"grid-max-height": {"type":"dimension"},
			"justify-content": {"type":"valign"},
			"align-items": {"type":"halign"}
		];

		this.settings = {
			"masonry" :0,
			"popup" : 0
		};

		return this;
	}

	private string function css_settings(required string selector, required struct styles) {
		
		var data = getSelectorStruct();
		
		if (arguments.styles.masonry) {
			data.main &= "\tdisplay:block;\n";
			data.item &= "\twidth:var(--grid-width);\n";
		}
		else {
			variables.contentObj.settingsObj.grid(arguments.styles,data)
		}

		return selectorQualifiedCSS(selector=arguments.selector, css_data=data);

	}
	

	public string function html(required struct content) {
		
		if (! StructKeyExists(arguments.content,"data")) {
			local.extendedinfo = {"content"=arguments.content};
			throw(
				extendedinfo = SerializeJSON(local.extendedinfo),
				message      = "No data defined for content section",
				errorcode    = "content.imagegrid.1"		
			);
		}

		local.html = "";

		for (local.image in arguments.content.data) {
		
			local.html &= "<figure>";
			if (StructKeyExists(local.image, "link")) {
				local.html &= "<a href='#local.image.link#'>";
			}
			local.html &= "<img src='#local.image.src#'>";
			if (StructKeyExists(local.image, "caption")) {
				local.html &= "<figcaption>#local.image.caption#</figcaption>";
			}
			if (StructKeyExists(local.image, "link")) {
				local.html &= "</a>";
			}

			local.html &= "</figure>";

		}		
		

		return local.html;
		
	}

	public string function onready(required struct content) {

		var js = "";

		if (arguments.content.settings.main.masonry) {
			js &= "$#arguments.content.id#Grid = $('###arguments.content.id#').masonry({\n";
			js &= "\t/* options*/\n";
			// js &= "\titemSelector: 'figure',\n";
			js &= "\tcolumnWidth: '###arguments.content.id# figure',\n";
			js &= "\tinitLayout: false,\n";
			js &= "\tpercentPosition: true\n";
			if (StructKeyExists(arguments.content.settings.main,"gridgap")) {
				js &= "\tgutter: #Val(arguments.content.settings.main.gridgap)#\n";
			}
			js &= "});\n";

			js &= "/* layout Masonry after each image loads*/\n";
			// js &= "$#arguments.content.id#Grid.imagesLoaded().progress( function() {\n";
			js &= "$#arguments.content.id#Grid.imagesLoaded( function() {\n";
			js &= "\t$#arguments.content.id#Grid.masonry('layout');\n";
			js &= "});\n";
		}

		if (arguments.content.settings.main.popup) {

			js &= "$(""###arguments.content.id# figure a"").colorbox({rel:'group#arguments.content.id#'});";
		}
		
		return js;
	}
	
}