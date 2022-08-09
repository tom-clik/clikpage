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
			{"name":"item","selector":" .item"},
			{"name":"image","selector":" .imageWrap"}
		];

		this.styleDefs = [
			"item-gridgap":{"type":"dimension"},
			"item-image-width":{"type":"dimension"}
		];
		
		
		
		return this;
	}

	public string function html(required struct content) {
		
		var cshtml = "<div class='list'>\n";
		var classes = {};

		for (local.item in arguments.content.data) {
			classes = {};
			local.tmpHTML = variables.contentObj.itemHtml(content=local.item);
			cshtml &= "<div class='item'>";
			cshtml &= local.tmpHTML;
			cshtml &= "</div>";
		}

		cshtml &= "</div>";

		return cshtml;

	}

	
}