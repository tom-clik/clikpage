component extends="contentSection" {

	variables.type = "title";
	variables.title = "Title content section";
	variables.description = "content wrapped in heading tag";
	variables.defaults = {
		"title"="Untitled",
		"content"="Undefined content",
	};
	
	function init(required content contentObj) {
		
		super.init(arguments.contentObj);
		
		// static css definitions
		variables.static_css = {"title"=1};
		variables.static_js = {};

		this.styleDefs = {
			"tag": {"type":"list","name":"Tag","description":"HTML tag to enclose text in","options":[
				{"value":"h1"},{"value":"h2"},{"value":"h3"},{"value":"h4"},{"value":"h5"},{"value":"h6"}
			]},
		};

		this.defaultStyles = {
			"tag": "h2"
		};

		return this;
	}

	public string function html(required struct content) {
		local.hasLink = StructKeyExists(arguments.content,"link") AND  NOT IsNull(arguments.content.link);

		var linkStart = (local.hasLink) ? "<a href='#arguments.content.link#'>" : "";
		var linkEnd = (local.hasLink) ? "</a>" : "";
		return "<#arguments.content.settings.main.tag#>#linkStart#" & arguments.content.content & "#linkEnd#</#arguments.content.settings.main.tag#>";
	}

	
}