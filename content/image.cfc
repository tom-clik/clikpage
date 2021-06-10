component extends="contentSection" {

	function init(required contentObj contentObj) {
		
		super.init(arguments.contentObj);
		variables.type = "image";
		variables.title = "Image content section";
		variables.description = "Simple image with option for rollover";
		variables.defaults = {
			"title"="Untitled",
			"content"="Undefined content",
		};

		// static css definitions
		variables.static_css = {"images"=1};
		variables.static_js = {};
		
		return this;
	}

	public string function html(required struct content) {
		
		if (StructKeyExists(arguments.content, "image")) {
				local.img = "<figure><img src='#arguments.content.image#'>";
				if (StructKeyExists(arguments.content, "caption")) {
					local.img &= "<figcaption>#arguments.content.caption#</figcaption>";
				}
				local.img &= "</figure>";
		}		
		

		else {
			local.img = "error - no image defined";
		}

		return local.img;
		
	}

	
}