component extends="contentSection" {
	function init(required content contentObj) {
		
		super.init(arguments.contentObj);
		variables.type = "title";
		variables.title = "Title content section";
		variables.description = "content wrapped in heading tag";
		variables.defaults = {
			"title"="Untitled",
			"content"="Undefined content",
		};
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
		return "<#arguments.content.settings.main.tag#>" & arguments.content.content & "</#arguments.content.settings.main.tag#>";
	}

	
}