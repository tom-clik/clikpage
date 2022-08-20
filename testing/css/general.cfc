/*

# General (item panel) styling

## Synopsis

Quite staightforward. We use grid template areas to layout the panel according to the settings.

The template rows and columns are adjusted according to the layout and the "image-width".

## Notes

We always layout in a grid even in mobile. It's important to set the align=center for mobile options. This is necessary to place the title above ot below the image as required.

*/
component extends="test_csbase" {

	public function init() {
		super.init();

		this.states = [
			{"state"="main", "selector"="","name":"Main","description":"The main state"},
			{"state"="hover", "selector"=" li a:hover","name":"Hover","description":"The hover state for menu items"},
			{"state"="hi", "selector"=" li.hi a","name":"Hilighted","description":"The state for the currently selected menu item"}
		]
		

		this.selectors = [
			{"name"="main", "selector"=""}
		];

		this.styleDefs = [
			"htop":{"type":"boolean","description":"Put headline before image"},
			"image-align":{"type":"halign"},
			"image-gap":{"type":"dimension","description":"Gap between image and text when aligned left or right. Use margins on the panels for other instances"},
			"image-width":{"type":"dimension"}
		];
		
		// pending formal definitions of settings,
		// there are some settings that need to cascade, e.g. orientation
		// 
		// ## Settings

		// Name           | Type                  | Implementation
		// ---------------|-----------------------|----------------------
		// htop           | boolean               | 
		
		this.settings = [
			"htop": {"inherit":1},
			"image-align": {"inherit":1}
		];

		this.panels = [
			{"name":"title","selector":".title"},
			{"name":"text","selector":".textWrap"},
			{"name":"image","selector":".imageWrap"}
		]

		
	}
	
	private string function css_settings(required string selector, required struct styles) {
		
		var data = getSelectorStruct();

		local.areas = "";
		local.widths = "";
		local.rows = "";

		//  htop  | adjust grid template rows to place title on top in spanning column
		local.htop = false;
		if (StructKeyExists(arguments.styles,"htop")) {
			data.main &= "/-- htop: #arguments.styles.htop#  --/\n";
			
			if (arguments.styles.htop) {
				local.htop = true;
				local.areas = """title"" ""imageWrap"" ""textWrap""";
			}
		}
		else {
			data.main &= "/-- no htop  --/\n";
		}

		if (StructKeyExists(arguments.styles,"image-gap")) {
			data.main &= "\t--image-gap: #arguments.styles["image-gap"]#;\n";	
		}

		// imagealign          | left|center|right
		local.align = "center";
		if (StructKeyExists(arguments.styles,"image-align")) {
			
			switch (arguments.styles["image-align"]) {
				case "left":
					local.widths = "var(--image-width) auto";
					if (local.htop) {
						local.areas = """title title"" ""imageWrap textWrap""";	
					}
					else {
						local.areas = " ""imageWrap title"" ""imageWrap textWrap""";	
					}
					local.rows = "min-content 1fr";
				break;
				case "center":
					local.widths = "1fr";
					if (local.htop) {
						local.areas = """title"" ""imageWrap"" ""textWrap""";	
					}
					else {
						local.areas = """imageWrap"" ""title"" ""textWrap""";	
					}
					local.rows = "min-content min-content auto";

				break;
				case "right":
					local.widths = "auto var(--image-width)";
					local.rows = "min-content 1fr";
					local.align = "right";
					if (local.htop) {
						local.areas = """title title"" ""textWrap imageWrap""";	
					}
					else {
						local.areas = " ""title imageWrap"" ""textWrap imageWrap""";	
					}
				break;
			}
			
		}
		if (local.areas != "") {
			data.main &= "\t--item-grid-template-areas: #local.areas#;\n";
		}
		if (local.widths != "") {
			data.main &= "\t--item-grid-template-columns: #local.widths#;\n";
		}
		if (local.rows != "") {
			data.main &= "\t--item-grid-template-rows: #local.rows#;\n";
		}

		return selectorQualifiedCSS(selector=arguments.selector, css_data=data);
	}

	
}
