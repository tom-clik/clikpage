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
		
		variables.static_css = {"images"=1,"jbox"=1};
		variables.static_js = {"masonry"=1,"jbox"=1};
		
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
	

	public string function html(required struct content,required struct data) {
		
		if (! StructKeyExists(arguments.content,"data")) {
			local.extendedinfo = {"content"=arguments.content};
			throw(
				extendedinfo = SerializeJSON(local.extendedinfo),
				message      = "No data defined for content section",
				errorcode    = "content.imagegrid.1"		
			);
		}

		local.html = "";

		for (local.id in arguments.content.data) {
			local.image = arguments.data[local.id];
			local.html &= "<figure>";
			
			// TODO: this is all a mess
			// 1. specify image type e.g. thumbnail
			// 2. Popups proper target for open
			// 3. Link types: none, gallery etc
			local.hasLink = 1;
			if (arguments.content.settings.main.popup) {
				local.link = arguments.content.link ? : local.image.image;
			}
			else {
				local.link = "{link.{section.id}.view.#local.id#}";
			}

			local.image_src = local.image.image_thumb ? : local.image.image;
			
			if (local.hasLink) {
				local.html &= "<a href='#local.link#' title='#encodeForHTMLAttribute(local.image.title)#'>";
			}

			local.html &= "<img src='#local.image_src#'>";

			if (local.image.title NEQ "") {
				local.html &= "<figcaption>#local.image.title#</figcaption>";
			}

			if (local.hasLink) {
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

			js &= "new jBox('Image');";
		}
		
		return js;
	}
	
}