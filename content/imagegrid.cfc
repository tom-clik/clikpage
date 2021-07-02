component extends="contentSection" {

	function init(required contentObj contentObj) {
		
		super.init(arguments.contentObj);
		variables.type = "imagegrid";
		variables.title = "Image grid content section";
		variables.description = "Images in grid";
		variables.defaults = {
			"title"="Untitled",
			"content"="Undefined content",
		};

		// static css definitions
		variables.static_css = {"images"=1};
		variables.static_js = {"masonry"=1};
		
		return this;
	}

	/** TODO: remove and valdate properly somewhere */
	private array function getFakeData(boolean submenu=false) {
		
		local.folder = "D:\unsplash\random\out";
		local.files = directoryList(path=local.folder,type="file",ListInfo="name",filter="*_thumb.jpg");
		local.path = "http://localpreview.clikpic.com/sampleimages/";

		local.data = [];

		for (local.i = 1; local.i <= 5 ; local.i++) {
			for (local.src in local.files) {
				local.caption = Left("Lorem ipsum dolor sit amet",randRange(12,20));
				local.image = {"src"=local.path  & local.src,"caption"=local.caption};
				
				ArrayAppend(local.data,local.image);
			}
		}

		return local.data;
	}



	public string function html(required struct content) {
		
		if (! StructKeyExists(arguments.content,"data")) {
			arguments.content.data = getFakeData();
		}

		local.html = "<div class='grid'>";

		for (local.image in arguments.content.data) {
		
			local.html &= "<figure><img src='#local.image.src#'>";
			if (StructKeyExists(local.image, "caption")) {
				local.html &= "<figcaption>#local.image.caption#</figcaption>";
			}
			local.html &= "</figure>";

		}		
		
		local.html &= "</div>";


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


		js &= "$grid = $('.cs-imagegrid.masonry .grid').masonry({\n";
		js &= "\t/* options*/\n";
		js &= "\titemSelector: 'figure',\n";
		js &= "\tcolumnWidth: '.cs-imagegrid figure',\n";
		js &= "\tinitLayout: false,\n";
		js &= "\tpercentPosition: true\n";
		js &= "});\n";

		js &= "/* layout Masonry after each image loads*/\n";
		js &= "$grid.imagesLoaded().progress( function() {\n";
		js &= "\t$grid.masonry('layout');\n";
		js &= "});\n";


		return js;
	}
	
}