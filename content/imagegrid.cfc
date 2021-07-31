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
		return this;
	}

	/** TODO: remove and valdate properly somewhere */
	private array function getFakeData(boolean submenu=false) {
		
		local.folder = "D:\git\clikpage\testing\images";
		local.dataList = [];

		local.dataFiles = directoryList(path=local.folder,filter="*.json");
		local.data = [];
		for (local.filename in local.dataFiles) {
			local.data = fileRead(local.filename);
			local.image = deserializeJSON(local.data);
			ArrayAppend(local.dataList, {"src":"/images/#local.image.thumb.src#","caption"=local.image.caption,"link"="/images/"&local.image.main.src});
		}

		return local.dataList;
	}

	

	public string function html(required struct content) {
		
		if (! StructKeyExists(arguments.content,"data")) {
			arguments.content.data = getFakeData();
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

	public string function css(required struct settings, required string selector) {
			
		var ret = arguments.selector & " {\n";
		// bit of a hack here. Not sure where to place these settings. Can't use root
		// or "grid" as they will have unintended consequecnes. Feel like we shold have a generic
		// key for placing main settings e.g. "content".
		// Same thing sort of applies to image grid 
		// THP
		if (structKeyExists(arguments.settings, "imagegrid")) {
			for (local.setting in ["max-width","max-height"]) {
				if (StructKeyExists(arguments.settings.imagegrid,local.setting)) {
					ret &= "\t--#local.setting#:" & arguments.settings.imagegrid[local.setting] & ";\n";
				}
			}
		}

		ret &= "}\n";
		
		return ret;
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
			js &= "$#arguments.content.id#Grid.imagesLoaded().progress( function() {\n";
			js &= "\t$#arguments.content.id#Grid.masonry('layout');\n";
			js &= "});\n";
		}

		if (arguments.content.settings.main.imagegrid.popup) {

			js &= "$(""###arguments.content.id# figure a"").colorbox({rel:'group#arguments.content.id#'});";
		}


		return js;
	}
	
}