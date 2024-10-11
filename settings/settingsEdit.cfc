/*

# SettingsEdit

Utilities for editing settings

## Description

Bit of a scratchpad at the minute. Putting all the embryonic work we'd done in the test pages into here to pull into shape.

*/
component {

	settingsEdit function init(
		required any    contentObj,
		         string api = "settings_api.cfc"
		) {
		variables.contentObj = arguments.contentObj;
		variables.api = arguments.api;

		this.settingsTypes = {};
		/* Show or hide an item using this value as is with { display: var(--show)}. We used this a lot when starting this project, but its use gets problematic as so
		many items now have different display values */
		this.settingsTypes["displayblock"] = {
			"options"= [
				{"value":"none","name":"Hide","description":""},
				{"value":"block","name":"Show","description":""}
			]
		};
		this.settingsTypes["halign"] = {
			"options"= [
				{"value":"left","name":"Left","description":""},
				{"value":"center","name":"Centre","description":""},
				{"value":"right","name":"Right","description":""}
			]
		};
		this.settingsTypes["valign"] = {
			"options"= [
			{"value":"top","name":"Top","description":""},
			{"value":"middle","name":"Middle","description":""},
			{"value":"bottom","name":"Bottom","description":""}
			]
		};
		this.settingsTypes["flexgrow"] = {
			"options"= [
			{"value":"1","name":"Yes","description":"Expand"},
			{"value":"0","name":"No","description":"Don't expand."}
			]
		};
		this.settingsTypes["overflow"] = {
			"options"= [
			{"value":"hidden","name":"Hidden","description":""},
			{"value":"show","name":"show","description":""}
			]
		};
		this.settingsTypes["float"] = {
			"options"= [
			{"value":"none","name":"None","description":""},
			{"value":"left","name":"Left","description":""},
			{"value":"right","name":"Right","description":""}
			]
		};
		this.settingsTypes["position"] = {
			"options"= [
			{"value":"static","name":"Normal","description":""},
			{"value":"fixed","name":"Fixed to screen","description":""},
			{"value":"absolute","name":"Relative to container","description":""},
			{"value":"sticky","name":"Sticky","description":""},
			{"value":"relative","name":"Normal with adjustment","description":""}
			]
		};

		this.settings = [
			"font": {
				"name": "Font",
				"type": "font",
				"description": "Font of main text"
			},
			"title-font": {
				"name": "Title Font",
				"type": "font",
				"description": "Font for title of the content section"
			},
			"heading-font": {
				"name": "Title Font",
				"type": "font",
				"description": "Font for title of the content section"
			},
			"padding": {
				"name": "Padding",
				"type": "dimensionlist",
				"description": "Space between the edge of the container and the contents"
			},
			"margin": {
				"name": "Margin",
				"type": "dimensionlist",
				"description": "Space around a container. Use Passing in preference."
			},
			"border": {
				"name": "Border",
				"type": "border",
				"description": "The style, width, and color of the border."
			},
			"color": {
				"name": "Text color",
				"type": "color",
			},
			"show": {
				"name": "Show",
				"type": "boolean"
			},
			"link-color": {
				"name": "Link color",
				"type": "color",
			},
			"position": {
				"name":"position",
				"type":"position",
				"description":""
			},
			"float": {
				"name":"float",
				"type":"float",
				"description":""
			},
			"float-margin": {
				"name":"Float margin",
				"type":"dimension",
				"description":"A simple single value to apply margin to the outside of a float"
			},
			"background": {
				"name":"Background",
				"type":"background",
				"description":""
			},
			"width": {
				"name":"Width",
				"type":"dimension",
				"description":""
			},
			"min-width": {
				"name":"Min Width",
				"type":"dimension",
				"description":""
			},
			"max-width": {
				"name":"Max Width",
				"type":"dimension",
				"description":""
			},
			"height": {
				"name":"Height",
				"type":"dimension",
				"description":""
			},
			"min-height": {
				"name":"Minimum height",
				"type":"dimension",
				"description":""
			},
			"max-height": {
				"name":"Maximum height",
				"type":"dimension",
				"description":""
			},
			"opacity": {
				"name":"Opacity",
				"type":"percent",
				"description":""
			},
			"z-index": {
				"name":"Z-Index",
				"type":"numeric",
				"description":""
			},
			"overflow": {
				"name":"Overflow",
				"type":"overflow",
				"description":""
			},
			"overflow-x": {
				"name":"Overflow (horizontal)",
				"type":"overflow",
				"description":""
			},
			"overflow-y": {
				"name":"Overflow (Vertical)",
				"type":"overflow",
				"description":""
			},
			"box-shadow": {
				"name":"Shadow",
				"type":"text",
				"description":""
			},
			"transform": {
				"name":"Transform",
				"type":"text",
				"description":"CSS transform"
			},
			"transition": {
				"name":"Transition",
				"type":"text",
				"description":"CSS transition"
			},
			"align": {
				"name":"Align",
				"type":"halign",
				"description":"Align can only be used when a width is set on a container. A better way to align items is to put them into a flexible grid and set the grid align contents property"
			}
		];

		return this;
	}

	/**
	 * Update settings for a content section using a set of supplied values
	 * 
	 * @cs      Content section
	 * @styles  Site styles
	 * @values  Values to apply
	 * @medium  Medium to apply values for
	 */
	public void function updateSettings(
		required struct cs, 
		required struct styles, 
		required struct values, 
		         string medium="main"
		) {
		for (local.set in [variables.contentObj.contentSections[arguments.cs.type].styleDefs, this.styleDefs]) {
			for (local.setting in local.set) {
				if (structKeyExists(arguments.values, local.setting) AND arguments.values[local.setting] != "") {
					arguments.styles.style[arguments.cs.id][arguments.medium][local.setting] = arguments.values[local.setting];
				}
				
			}
		}
		
		variables.contentObj.settings(content=arguments.cs,styles=arguments.styles.style,media=arguments.styles.media);
	}

	

}
