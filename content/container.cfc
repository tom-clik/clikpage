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

	/**
	 * @hint Update settings with required values
	 * 
	 * This is one of the key functions to understand. Say for instance you have a required 
	 * setting "orientation" for a menu. This will have a default value, but this might be 
	 * overridden in "main". When we want to get the value for mobile, it should inherit 
	 * from main or mid.
	 *
	 * At the same time, we don't want to create settings for a medium where there are none.
	 *
	 * If you want a default for mobile that's different, use the styling to inherit from a base value.
	 * 
	 */
	public void function settings(required struct content, required array media ) {
		
		if (NOT StructKeyExists(arguments.content,"settings")) {
			arguments.content["settings"] = {
			};	
		}
		else {
			variables.contentObj.DeepStructAppend(arguments.content["settings"], {}, false);
		}

		var currentSettings = Duplicate(variables.settings);

		for (local.medium in arguments.media) {
			// need to use root if main.
			if (StructKeyExists(arguments.content["settings"],local.medium.name)) {
				variables.contentObj.DeepStructAppend(arguments.content["settings"][local.medium.name],currentSettings,false);
				/** if a value is defined in the styling, use it for this and subsequent media */
				variables.contentObj.DeepStructUpdate(currentSettings,arguments.content["settings"][local.medium.name]);
				
			}
		}
		
	}
}