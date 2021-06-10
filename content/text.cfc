component extends="contentSection" {
	function init(required contentObj contentObj) {
		
		super.init(arguments.contentObj);
		variables.type = "text";
		variables.title = "Text content section";
		variables.description = "Displays content with no additional formatting";
		variables.defaults = {
			"title"="Untitled",
			"content"="Undefined content",
		};
		
		return this;
	}

	

}