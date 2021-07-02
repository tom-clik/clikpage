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
			"heading_position" = "top",
			"mobile_heading_position" = "top",
			"align" = "none",
			"imagewidth" = "",
			"titletag" = "h3",
			"showtitle" = true
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
		
		var cssettings = structKeyExists(arguments,"settings") ? arguments.settings.main : arguments.content.settings.main;
		arguments.content.class["item"] = 1;
		if (cssettings.heading_position == "top") {
			arguments.content.class["htop"] = 1;
		}
		if (cssettings.mobile_heading_position != "top") {
			arguments.content.class["munder"] = 1;

		}
		if (!cssettings.showtitle) {
			arguments.content.class["notitle"] = 1;

		}
		switch (cssettings.align) {
			case "left": case "right":
			arguments.content.class[cssettings.align] = 1;
		}

		var cshtml = "\t<" & cssettings.titletag & " class='title'>" & arguments.content.title & "</" & cssettings.titletag & ">\n";
		cshtml &= "\t<div class='imageWrap'>\n";
		if (StructKeyExists(arguments.content,"image")) {
			cshtml &= "\t\t<img src='" & arguments.content.image & "'>\n";
			if (StructKeyExists(arguments.content,"caption")) {
				cshtml &= "\t\t<div class='caption'>" & arguments.content.caption & "</div>\n";
			}
		}
			cshtml &= "\t</div>\n";

		cshtml &= "\t<div class='textWrap'>";
		cshtml &= arguments.content.content;
		cshtml &= "</div>";

		return cshtml;

	}


	public string function css(required struct settings, required string selector) {
		
		var css = "";
		if (arguments.settings.imagewidth != "") {
			css = "#arguments.selector# {\n";
			css &= "\t--imagewidth: #arguments.settings.imagewidth#;\n";
			css &= "}\n\n";
			css &= "#arguments.selector#.wide.right {\n";
			css &= "\tgrid-template-columns: auto var(--imagewidth);\n";
			css &= "}\n\n";
			css &= "#arguments.selector#.wide.left {\n";
			css &= "\tgrid-template-columns: var(--imagewidth) auto;\n";
			css &= "}\n\n";
		}
		else {
			css = "/* No image width defined */\n";
		}

		return css;

	}





}