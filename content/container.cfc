component extends="contentSection" {
	
	variables.type = "container";
	variables.title = "Container";
	variables.description = "A container to add to yur layouts";
	variables.defaults = {
		"title"="Untitled Container",
		"content"="Undefined content",
	};
	
	this.styleDefs = [
		"hasInner": {"type":"boolean","name":"Use inner","description":"Use a inner div","default":false,"hidden"="true"}
		];
	
	this.settings = [
			"orientation": "left",
			"border-type": "none",
			"flex":"false",
			"stretch":"false",
			"popup":"false",
			"padding-adjust": true
		];

	
	;

}