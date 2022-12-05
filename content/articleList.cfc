component extends="item" {

	variables.type = "articlelist";
	variables.title = "Article list";
	variables.description = "List of content items";
	variables.defaults = {
		"title"="Untitled",
		"content"="Undefined content",
	};
	
	function init(required content contentObj) {
		
		super.init(arguments.contentObj);
		
		this.selectors = [
			{"name"="item", "selector"=" .item"},
			{"name"="image", "selector"=" .imageWrap"},
			{"name"="title", "selector"=" .title"},
			{"name"="text", "selector"=" .textWrap"}
		];

		this.panels.prepend({"name":"Item","panel":"item","selector":" .item"});

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