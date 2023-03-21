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
		
		variables.static_css = {"flickity":1};
		variables.static_js = {"flickity":1};

		this.selectors = [
			{"name"="item", "selector"=" .item"},
			{"name"="image", "selector"=" .imageWrap"},
			{"name"="title", "selector"=" .title"},
			{"name"="text", "selector"=" .textWrap"}
		];

		this.styleDefs["carousel"] = {"type":"boolean","description":"use carousel for list"};
		this.settings["carousel"] = false;
		
		this.panels.prepend({"name":"Item","panel":"item","selector":" .item"});

		return this;

	}

	public string function html(required struct content,required struct data) {
		
		
		var cshtml = "<div class='list'>\n";
		var classes = {};

		local.link_format = arguments.content.link ? : "{link.{section.id}.view.{data.id}}";
		
		for (local.id in arguments.content.data) {
			local.item = arguments.data[local.id];
			classes = {};
			local.link = Replace(local.link_format, "{data.id}", local.id);
			local.tmpHTML = variables.contentObj.itemHtml(item=local.item,link=local.link);
			cshtml &= "<div class='item'>";
			cshtml &= local.tmpHTML;
			cshtml &= "</div>";
		}

		cshtml &= "</div>";

		return cshtml;

	}

	public string function onready(required struct content) {
		var js = "";

		if (arguments.content.settings.main.carousel) {
			js = ["$carousel = $('###arguments.content.id# .list');"]
			.append("$carousel.flickity({")
		  	.append("  // options")
		  	.append("  contain: true,")
		  	.append("  freeScroll: false,")
		  	.append("  wrapAround: true")
			.append("});").toList(newLine());
		}

		return js;
	}

		
		
	
}