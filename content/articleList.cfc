component extends="general" {

	function init(required contentObj contentObj) {
		
		super.init(arguments.contentObj);
		variables.type = "articlelist";
		variables.title = "Article list";
		variables.description = "List of content items";
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

		variables.panels = [
			{"name":"title","selector":" .title"},
			{"name":"item","selector":" .item"},
			{"name":"image","selector":" .imageWrap"}
		];
		
		return this;
	}

	public string function html(required struct content) {
		
		var cshtml = "<div class='list'>\n";
		var classes = {};

		for (local.item in arguments.content.data) {
			classes = {};
			local.tmpHTML = itemHtml(content=local.item, settings = arguments.content.settings.main.item  , classes= classes);
			local.class = StructKeyList(classes," ");
			cshtml &= "<div class='#local.class#'>";
			cshtml &= local.tmpHTML;
			cshtml &= "</div>";
		}

		cshtml &= "</div>";

		return cshtml;

	}

	
}