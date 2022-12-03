component extends="contentSection" {
	
	variables.type = "text";
	variables.title = "Text content section";
	variables.description = "Displays content with no additional formatting";
	variables.defaults = {
		"title"="Untitled",
		"content"="Undefined content",
	};

	function init(required content contentObj) {
		
		super.init(arguments.contentObj);
		
		
		return this;
	}

	

}