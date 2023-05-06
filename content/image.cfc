/*

# Image 

Display Image with optional caption

## Styling

All image sizing is done via the object fit mechanism. Some workarounds are in place to ensure image heights are limited to the height of their containing grid cells. See notes on "grid bust out".

*/
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

		this.selectors = [
			{"name"="main", "selector"=""},
			{"name"="frame", "selector"=" figure"}		
		];

		this.styleDefs = [
			"object-fit": {
				"type":"list",
				"name":"Image fit",
				"description":"How to fit the image to the available space",
				"default":'scale-down',
				"options":[
					{
						"value":"scale-down",
						"display":"Scale down",
						"description": "Reduce the image to fit while preserving its ratio"
					},
					{
						"value":"cover",
						"display":"Cover",
						"description": "Fit as much of the image as possible while preserving its ratio. This may result in cropping."
					},
					{
						"value":"fill",
						"display":"Stretch",
						"description": "Stretch the image to fit the available space"
					},
					{
						"value":"none",
						"display":"None",
						"description": "The image is not resized"
					}
				]

			},
			"object-position-x": {
				"type":"halign",
				"default":"center"
			},
			"object-position-y": {
				"type":"valign",
				"default":"center"
			},
			"fitheight": {
				"name":"Fit to height",
				"description": "Ensure the image fits into the height available. Without this, the container will expand",
				"type":"boolean",
				"default":false,
				"inherit":true
			}
		];

		updateDefaults();
	
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

	private string function css_settings(required string selector, required struct styles) {
		
		var data = getSelectorStruct();
		
		data.frame &= "position: " & (arguments.styles.fitheight ? "absolute" : "static") & ";\n";

		return selectorQualifiedCSS(selector=arguments.selector, css_data=data);

	}

	
}