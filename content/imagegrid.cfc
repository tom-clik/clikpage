component extends="contentSection" {

	function init(required contentObj contentObj) {
		
		super.init(arguments.contentObj);
		variables.type = "imagegrid";
		variables.title = "Image grid";
		variables.description = "Images in grid";
		variables.defaults = {
			"title"="Untitled",
			"content"="Undefined content",
		};

		// static css definitions
		variables.static_css = {"images"=1,"colorbox"=1};
		// to do: only require if there
		variables.static_js = {"masonry"=1,"colorbox"=1};
		variables.settings = {
			"imagegrid" = {
				"masonry"=0,"popup"=0
			}
		}
		this.selectors = [
			{"name"="main", "selector"=""},
			{"name"="item", "selector"=" > *"}
		];

		this.styleDefs = [
			"grid-gap": {"type":"dimension"},
			"row-gap": {"type":"dimension"},
			"max-width": {"type":"dimension"},
			"max-height": {"type":"dimension"},
			"justify-content": {"type":"valign"},
			"align-items": {"type":"halign"}
		];

		return this;
	}

	private string function css_settings(required string selector, required struct styles) {
		
		local.mode = StructKeyExists(arguments.styles, "grid-mode") ?  arguments.styles["grid-mode"] : "none" ;
		
		var data = getSelectorStruct();

		StructAppend(arguments.styles,{"grid-mode":"auto","grid-fit":"auto-fit","grid-width":"180px","grid-max-width":"1fr","grid-columns":"2","grid-gap":"10px","grid-row-gap":"","grid-template-columns":"","justify-content":"flex-start","align-items":"flex-start","masonry":false,"popup":false},false);

		switch (local.mode) {
			case "none":
				data.main &= "\tdisplay:block;\n";
				break;
			case "auto":
				data.main &= "\tdisplay:grid;\n";
				data.main &= "\tgrid-template-columns: repeat(#arguments.styles["grid-fit"]#, minmax(#arguments.styles["grid-width"]#, #arguments.styles["grid-max-width"]#));\n";

				break;	
			case "fixedwidth":
				data.main &= "\tdisplay:grid;\n";
				data.main &= "\tgrid-template-columns: repeat(#arguments.styles["grid-fit"]#, #arguments.styles["grid-width"]#);\n";
				break;	
			case "fixedcols":
				data.main &= "\tdisplay:grid;\n";
				if (StructKeyExists(arguments.styles,"grid-template-columns") AND  arguments.styles["grid-template-columns"] neq "") {
					data.main &= "\tgrid-template-columns: " & arguments.styles["grid-template-columns"] & ";\n";
				}
				else {
					data.main &= "\tgrid-template-columns: repeat(#arguments.styles["grid-columns"]#, 1fr);\n";
				}
				
				break;	

			case "templateareas":
				data.main &= "\tgrid-template-areas:""" & arguments.styles["grid-template-areas"] & """;\n";
				break;
			case "flex": case "flexstretch":
				data.main = "\tdisplay:flex;\n\tflex-wrap: wrap;\n\tflex-direction: row;\n";
				if (local.mode eq "flexstretch") {
					data.item &= "\n\tflex-grow:1;\n;";
				}
				break;

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

		local.html = "<div class='grid'>";

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
		
		local.html &= "</div>";

		if (arguments.content.settings.main.imagegrid.masonry) {
			arguments.content.class["masonry"] = 1;
		}


		return local.html;
		
	}

	public string function onready(required struct content) {
		var js = "";

		
		if (arguments.content.settings.main.imagegrid.masonry) {
			js &= "$#arguments.content.id#Grid = $('###arguments.content.id# .grid').masonry({\n";
			js &= "\t/* options*/\n";
			// js &= "\titemSelector: 'figure',\n";
			js &= "\tcolumnWidth: '###arguments.content.id# figure',\n";
			js &= "\tinitLayout: false,\n";
			js &= "\tpercentPosition: true\n";
			if (StructKeyExists(arguments.content.settings.main.imagegrid,"gridgap")) {
				js &= "\tgutter: #arguments.content.settings.main.imagegrid.gridgap#\n";
			}
			js &= "});\n";

			js &= "/* layout Masonry after each image loads*/\n";
			// js &= "$#arguments.content.id#Grid.imagesLoaded().progress( function() {\n";
			js &= "$#arguments.content.id#Grid.imagesLoaded( function() {\n";
			js &= "\t$#arguments.content.id#Grid.masonry('layout');\n";
			js &= "});\n";
		}

		if (arguments.content.settings.main.imagegrid.popup) {

			js &= "$(""###arguments.content.id# figure a"").colorbox({rel:'group#arguments.content.id#'});";
		}


		return js;
	}
	
}