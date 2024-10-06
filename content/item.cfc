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
			{"name"="image", "selector"=" figure"},
			{"name"="title", "selector"=" .title"},
			{"name"="text", "selector"=" .textWrap"}
		];it

		this.panels = [
			{"name":"title","panel":"title","selector":" .title"},
			{"name":"image","panel":"image","selector":" figure"},
			{"name":"text","panel":"text","selector":" .textWrap"}
		];

		this.styleDefs = [
			"htop":{"type":"boolean","description":"Put headline before image","default"="false"},
			"align":{"type":"halign"},
			"wrap":{"type":"boolean","default":false},
			"item-gridgap":{"type":"dimension","description":"Gap between image and text when aligned left or right. Use margins on the panels for other instances","default":"10px"},
			"image-width":{"type":"dimension","default":"40%"},
			"titletag":{"type":"list","options": [
				{"value":"h1"},
				{"value":"h2"},
				{"value":"h3"},
				{"value":"h4"},
				{"value":"h5"},
				{"value":"h6"}
			],"default":"h3"},
			"title":{"type":"boolean","default"="true"},
			"image":{"type":"boolean","default"="false"},
			"caption-display":{"type":"displayblock","default"="none"}
		];

		updateDefaults();

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
		arguments.content.description = arguments.content.content;
		local.link = arguments.content.link ? : "";
		var cshtml = variables.contentObj.itemHtml(item=arguments.content, link=local.link, settings = arguments.content.settings.main, classes=classes);
		
		return cshtml;

	}

	
}