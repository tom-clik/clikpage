/*

New panels component for var based stying.

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
			"htop":{"type":"boolean"},
			"image-align":{"type":"halign"},
			"image-gap":{"type":"dimension"},
			"image-width":{"type":"dimension"}
			
		];
		// pending formal definitions of settings,
		// there are some settings that need to cascade, e.g. orientation
		// 
		// ## Settings

		// Name           | Type                  | Implementation
		// ---------------|-----------------------|----------------------
		// htop           | boolean               | put headline before image
		
		this.settings = [
			"htop": {"inherit":1},
			"image-align": {"inherit":1}
		];

		
	}
	
	private string function css_settings(required string selector, required struct styles) {
		
		var data = getSelectorStruct();
		local.areas = "";
		local.widths = "";
		local.rows = "";
		//  horizontal|vertical   | ul Grid columns
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
			data.main &= "\tgrid-column-gap: #arguments.styles["image-gap"]#;\n";	
		}

		// imagealign          | left|center|right     
		local.align = "center";
		if (StructKeyExists(arguments.styles,"image-align")) {
			
			switch (arguments.styles["image-align"]) {
				case "left":
					local.widths = "var(--item-image-width) auto";
					if (local.htop) {
						local.areas = """title title"" ""imageWrap textWrap""";	
					}
					else {
						local.areas = " ""imageWrap title"" ""imageWrap textWrap""";	
					}
					local.rows = "min-content auto";
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
					local.widths = "auto var(--item-image-width)";
					local.rows = "min-content auto";
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
