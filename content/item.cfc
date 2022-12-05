component extends="contentSection" {
	
	variables.type = "item";
	variables.title = "General content";
	variables.description = "HTML with optional title and text";
	variables.defaults = {
		"title"="Untitled",
		"content"="Undefined content",
	};
	
	function init(required content contentObj) {
		
		super.init(arguments.contentObj);

		variables.static_css = {"panels":1, "images":1};
		this.classes = "item clear";
		
		this.selectors = [
			{"name"="item", "selector"=""},
			{"name"="image", "selector"=" .imageWrap"},
			{"name"="title", "selector"=" .title"},
			{"name"="text", "selector"=" .textWrap"}
		];

		this.panels = [
			{"name":"title","panel":"title","selector":" .title"},
			{"name":"image","panel":"image","selector":" .imageWrap"},
			{"name":"text","panel":"text","selector":" .textWrap"}
		];

		this.styleDefs = [
			"htop":{"type":"boolean","description":"Put headline before image"},
			"image-align":{"type":"halign"},
			"flow":{"type":"boolean"},
			"image-gap":{"type":"dimension","description":"Gap between image and text when aligned left or right. Use margins on the panels for other instances","default":"10px"},
			"image-width":{"type":"dimension","default":"40%"},
			"titletag":{"type":"list","list":"h1,h2,h3,h4,h5,h6"},
			"showtitle":{"type":"boolean"}
		];

		this.settings = {
			"flow":false,
			"titletag":"h3",
			"showtitle":true,
			"htop": false,
			"image-align": 'center'
		};

		this.defaultStyles = {
			"image-width":"40%",
			"image-gap":"10px",
			"htop": false,
			"image-align": 'center'
		};

		return this;
	}

	/** Create a new content section */
	public struct function new(required string id, string title, string content, string image, string caption, string link, struct data) {
		
		var cs =super.new(argumentCollection = arguments);

		if (StructKeyExists(arguments,"image")) {
			cs["image"] = arguments.image;
		}
		
		if (StructKeyExists(arguments,"caption")) {
			cs["caption"] = arguments.caption;
		}
		
		if (StructKeyExists(arguments,"link")) {
			cs["link"] = arguments.link;
		}

		return cs;
	}
	
	public string function html(required struct content) {
		
		var classes = {};
		
		arguments.content.class = ListAppend(arguments.content.class, "item"," ");

		var cshtml = variables.contentObj.itemHtml(content=arguments.content, settings = arguments.content.settings.main, classes=classes);
		
		return cshtml;

	}

	private string function css_settings(required string selector, required struct styles) {
		
		var data = getSelectorStruct();

		local.areas = "";
		local.widths = "";
		local.rows = "";

		if (arguments.styles.flow) {
			data.item &= "\tdisplay:block;\n";
			data.image &= "\tmargin-bottom:var(--item-gridgap);\n";
			switch (arguments.styles["image-align"]) {
				case "left":
					data.image &= "\tfloat:left;\n";
					data.image &= "\twidth:var(--image-width);\n";
					data.image &= "\tmargin-right:var(--item-gridgap);\n";
					data.image &= "\tmargin-left:0;\n";
					break;
				case "right":
					data.image &= "\tfloat:right;\n";
					data.image &= "\twidth:var(--image-width);\n";
					data.image &= "\tmargin-right:0;\n";
					data.image &= "\tmargin-left:var(--item-gridgap);\n";
					break;
				case "center":	
					data.image &= "\tfloat:none;\n";
					data.image &= "\twidth:100%;\n";
					data.image &= "\tmargin-left:0;\n";
					data.image &= "\tmargin-right:0;\n";
					break;

			}
			
		}
		//  htop  | adjust grid template rows to place title on top in spanning column
		else {
			data.image &= "\tfloat:none;\n";
			data.image &= "\twidth:100%;\n";
			data.item &= "\tdisplay:grid;\n";
			if (arguments.styles.htop) {
				local.areas = """title"" ""imageWrap"" ""textWrap""";
			}
			
			if (StructKeyExists(arguments.styles,"image-gap")) {
				data.item &= "\t--item-gridgap: #arguments.styles["image-gap"]#;\n";	
			}

			// imagealign          | left|center|right
				
			switch (arguments.styles["image-align"]) {
				case "left":
					local.widths = "var(--image-width) auto";
					if (arguments.styles.htop) {
						local.areas = """title title"" ""imageWrap textWrap""";	
					}
					else {
						local.areas = " ""imageWrap title"" ""imageWrap textWrap""";	
					}
					local.rows = "min-content 1fr";
				break;
				case "center":
					local.widths = "1fr";
					if (arguments.styles.htop) {
						local.areas = """title"" ""imageWrap"" ""textWrap""";	
					}
					else {
						local.areas = """imageWrap"" ""title"" ""textWrap""";	
					}
					local.rows = "min-content min-content auto";
					data.image &= "\tmargin-left:0;\n";
					data.image &= "\tmargin-right:0;\n";

				break;
				case "right":
					local.widths = "auto var(--image-width)";
					local.rows = "min-content 1fr";
					if (arguments.styles.htop) {
						local.areas = """title title"" ""textWrap imageWrap""";	
					}
					else {
						local.areas = " ""title imageWrap"" ""textWrap imageWrap""";	
					}
				break;
			}
			
		}

		if (local.areas != "") {
			data.item &= "\t--item-grid-template-areas: #local.areas#;\n";
		}
		if (local.widths != "") {
			data.item &= "\t--item-grid-template-columns: #local.widths#;\n";
		}
		if (local.rows != "") {
			data.item &= "\t--item-grid-template-rows: #local.rows#;\n";
		}

		return selectorQualifiedCSS(selector=arguments.selector, css_data=data);
	}

}