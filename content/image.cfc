component extends="contentSection" {

	variables.type = "image";
	variables.title = "Image";
	variables.description = "Simple image with option for rollover";
	variables.defaults = {
		"title"="Untitled",
		"content"="Undefined content",
	};

	function init(required content contentObj) {
		
		super.init(arguments.contentObj);
		
		// static css definitions
		variables.static_css = {"images"=1};
		variables.static_js = {};
		
		this.panels = [
			{"name":"image","panel":"image", "selector": " img"},
			{"name":"frame","panel":"frame", "selector": " figure"},
			{"name":"Caption","panel":"caption", "selector": " figcaption"}
		];

		return this;
	}

	public string function html(required struct content) {
		
		if (StructKeyExists(arguments.content, "image")) {
			local.hasLink = StructKeyExists(arguments.content,"link");

			var linkStart = (local.hasLink) ? "<a href='#arguments.content.link#'>" : "";
			var linkEnd = (local.hasLink) ? "</a>" : "";
			local.img = "#linkStart#<figure><img src='#arguments.content.image#'>";
			if (StructKeyExists(arguments.content, "caption")) {
				local.img &= "<figcaption>#arguments.content.caption#</figcaption>";
			}
			local.img &= "</figure>#linkEnd#";
		}		
		

		else {
			local.img = "error - no image defined";
		}

		return local.img;
		
	}

	
}