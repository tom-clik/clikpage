component extends="contentSection" {
	function init(required contentObj contentObj) {
		
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
		
		return this;
	}

	public string function html(required struct content) {
		return "<h3>#arguments.content.content#</h3>";
	}

	
}