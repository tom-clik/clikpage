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
			"htop":{"title":"title position", "type":"list","options": [
				{"value":"1","name"="Title before image"},
				{"value":"0","name"="Title after image"}
				],
				"description":"Where to place the title in the item layout",
				"default"="false",
				"setting":1
			},
			"image-align":{"title":"Image alignment", "type":"halign","default":"center","setting":1},
			"wrap":{"title":"Wrap text", "type":"boolean","default":"0","setting":1},
			"item-gridgap":{"title":"Image margin", "type":"dimension","description":"Gap between image and text when aligned left or right. Use margins on the panels for other instances","default":"10px","setting":1},
			"image-width":{"title":"Image width", "type":"dimension","default":"40%"},
			"titletag":{"title":"", "type":"list","options": [
				{"value":"h1"},
				{"value":"h2"},
				{"value":"h3"},
				{"value":"h4"},
				{"value":"h5"},
				{"value":"h6"}
			],"default":"h3","hidden"=1},
			"show-title":{"title":"Show title", "type":"boolean","default"="1","setting":1},
			"show-image":{"title":"Show image", "type":"boolean","default"="1","setting":1},
			"imagespace":{"title":"Always show image space", "type":"boolean","default"="0","setting":1},
			"caption-display":{"title":"Show caption", "type":"displayblock","default"="none"}
		];

		updateDefaults();

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

	public string function html(required struct content) {
		
		var classes = {};
		
		StructAppend(arguments.content, {"class"=""},false);	
		arguments.content.class = ListAppend(arguments.content.class, "item"," ");
		arguments.content.description = arguments.content.content;
		local.link = arguments.content.link ? : "";
		var cshtml = variables.contentObj.itemHtml(item=arguments.content, link=local.link, settings = arguments.content, classes=classes);
		
		return cshtml;

	}

	
}