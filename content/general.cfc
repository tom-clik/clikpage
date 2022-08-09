component extends="contentSection" {
	
	function init(required contentObj contentObj) {
		
		super.init(arguments.contentObj);
		variables.type = "general";
		variables.title = "General content";
		variables.description = "HTML with optional title and text";
		variables.defaults = {
			"title"="Untitled",
			"content"="Undefined content",
		};
		
		variables.static_css = {"panels":1, "images":1};
		variables.settings = {
			"item" = {
				"heading_position" = "top",
				"mobile_heading_position" = "top",
				"align" = "none",
				"imagewidth" = "",
				"titletag" = "h3",
				"showtitle" = true
			}
		};

		variables.panels = [
			{"name":"title","selector":" .title"},
			{"name":"image","selector":" .imageWrap"}
		];

		this.styleDefs = [
			"htop":{"type":"boolean"},
			"image-align":{"type":"halign"},
			"item-gridgap":{"type":"dimension"},
			"item-image-width":{"type":"dimension"}
		];

		return this;
	}

	/** Create a new content section */
	public struct function new(required string id, string title, string content, string image, string caption, string link) {
		
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
	
	public string function html(required struct content, struct settings) {
		
		// var cssettings = structKeyExists(arguments,"settings") ? arguments.settings.main.item : arguments.content.settings.main.item;
		var classes= {};
		
		cshtml = variables.contentObj.itemHtml(content=arguments.content);
		StructAppend(arguments.content.class,classes);
		
		return cshtml;

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