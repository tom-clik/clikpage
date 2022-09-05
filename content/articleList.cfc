component extends="contentSection" {

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
		
		this.panels = [
			{"name":"Title","panel":"title","selector":" .title"},
			{"name":"Item","panel":"item","selector":" .item", "type":"item"},
			{"name":"Image","panel":"image","selector":" .imageWrap"},
			{"name":"Text","panel":"text","selector":" .textWrap"}
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