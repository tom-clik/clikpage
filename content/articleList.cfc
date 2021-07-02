component extends="general" {

	function init(required contentObj contentObj) {
		
		super.init(arguments.contentObj);
		variables.type = "articlelist";
		variables.title = "List of articlesGeneral content";
		variables.description = "List of general type";
		variables.defaults = {
			"title"="Untitled",
			"content"="Undefined content",
		};
		
		variables.static_css = {"items":1, "images":1};

		return this;
	}


	public string function html(required struct content) {
		
		var cshtml = "<div class='list'>\n";
		
		for (local.item in arguments.content.data) {
			cshtml &= "<div class='item left htop'>";
			cshtml &= super.html(local.item, arguments.content.settings);
			cshtml &= "</div>";
		}

		cshtml &= "</div>";

		return cshtml;

	}


	public string function css(required struct settings, required string selector) {
		
		var css = "";
		if (arguments.settings.imagewidth != "") {
			css = "#local.select# {\n";
			css &= "\t--imagewidth: #arguments.settings.imagewidth#;\n";
			css &= "}\n\n";
			css &= "#local.select#.wide.right {\n";
			css &= "\tgrid-template-columns: auto var(--imagewidth);\n";
			css &= "}\n\n";
			css &= "#local.select#.wide.left {\n";
			css &= "\tgrid-template-columns: var(--imagewidth) auto;\n";
			css &= "}\n\n";
		}
		else {
			css = "/* No image width defined */\n";
		}

		return css;

	}





}