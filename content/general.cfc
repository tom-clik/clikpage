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
		
		variables.static_css = {"items":1, "images":1};
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


	public string function css_settings(required string selector,required struct settings) {
		
		var css = "";
		if (arguments.settings.item.imagewidth != "") {
			css = "#arguments.selector# {\n";
			css &= "\t--imagewidth: #arguments.settings.item.imagewidth#;\n";
			css &= "}\n\n";
		}
		else {
			css = "/* No image width defined */\n";
		}

		return css;

	}





}