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

		this.settingsOptions = {};
		this.settingsOptions["displayblock"] = [
			{"value":"none","name":"Hide","description":""},
			{"value":"block","name":"Show","description":""}
		];
		this.settingsOptions["halign"] = [
			{"value":"left","name":"Left","description":""},
			{"value":"center","name":"Centre","description":""},
			{"value":"right","name":"Right","description":""}
		];
		this.settingsOptions["valign"] = [
			{"value":"top","name":"Top","description":""},
			{"value":"middle","name":"Middle","description":""},
			{"value":"bottom","name":"Bottom","description":""}
		];
		this.settingsOptions["flexgrow"] = [
			{"value":"1","name":"Yes","description":"Item will expand to fit width (if set)"},
			{"value":"0","name":"No","description":"Item will not expand."}
		];
		this.settingsOptions["overflow"] = [
			{"value":"hidden","name":"Hidden","description":""},
			{"value":"show","name":"show","description":""}
		];
		this.settingsOptions["float"] = [
			{"value":"left","name":"Left","description":""},
			{"value":"right","name":"Right","description":""},
			{"value":"none","name":"None","description":""}
		];
		this.settingsOptions["position"] = [
			{"value":"static","name":"Normal","description":""},
			{"value":"fixed","name":"Fixed to screen","description":""},
			{"value":"absolute","name":"Relative to container","description":""},
			{"value":"sticky","name":"Sticky","description":""},
			{"value":"relative","name":"Normal with adjustment","description":""}
		];

		this.styleDefs = [
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
				"description":"",
				"default": ""
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
				"name":"Min height",
				"type":"dimension",
				"description":""
			},
			"max-height": {
				"name":"Max height",
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

	private string function radioSelected(required boolean on) {
		return on ? " selected" : "";
	}

	string function settingsForm(
		required struct contentsection, 
		required string media="main",
		         string type="imagegrid"
		) {
		var retval = "
		<div id='settings_panel' class='settings_panel modal'>
			
			<div id='settings_panel_close' class='button auto'><a href='##settings_panel.close'><svg class='icon' xmlns='http://www.w3.org/2000/svg' viewBox='0 0 357 357' preserveAspectRatio='none'><use href='/_assets/images/close47.svg##close'></use></svg><label>Close</label></a></div>			
			<form id='settingsForm'>	
				<div class='formInner'>
				
				<input type='hidden' name='cs_id' value='#arguments.contentsection.id#'>
					<div class='formBody'>
						<div class='cs-tabs'>
							<div class='tab state_open' id='#arguments.contentsection.id#_tab_settings'>
								<div class='title'>
									Settings
								</div>
								<div class='item wrap'>";
					
		local.settings = arguments.contentsection.settings[arguments.media];

		retval &= "<fieldset>";
		
		retval &= settingsFormFields(
			styleDefs = variables.contentObj.contentSections[arguments.type].styleDefs,
			id = arguments.contentsection.id,
			type = arguments.type
		);

		retval &= "
								</fieldset>
							</div>
						</div>
						<div class='tab' id='#arguments.contentsection.id#_tab_styles'>
							<div class='title'>
								Styles
							</div>
							<div class='item wrap'>
								<fieldset>	";

		retval &= settingsFormFields(
			styleDefs = this.styleDefs,
			id = arguments.contentsection.id,
			type = arguments.type
		);

			retval &= "
									</fieldset>
								</div>
							</div>	
						</div>
					</div>
				
					<div class='submit'>
						<label></label>				
						<div class='button'><input type='submit' value='Update'></div>
					</div>
				</div>
			</form>
			
		</div>";

		return retval;
	}

	private string function settingsFormFields(
		required struct styleDefs, 
		required string id,
		required string type
		) {
		var retVal = "";
		for (local.setting in arguments.styleDefs) {
			local.settingDef = arguments.styleDefs[local.setting];
			local.description = local.settingDef.description? : "No description";
			local.name = local.settingDef.name? : local.setting;
			retval &= "<label title='#encodeForHTMLAttribute(local.description)#'>#local.name#</label>";

			local.value = local.settings[local.setting] ? : "";
			
			switch(local.settingDef.type) {
				
				case "boolean":
					local.selected = isBoolean(local.value) AND local.value;
					local.onOff = {1: " selected", 0: ""};
					local.id_root = "#arguments.id#_#local.setting#";
					retval &= "<div class='field'><input id='#local.id_root#_on' type='radio' name='#local.setting#'#radioSelected(local.selected)# value='1'><label for='#local.id_root#_on'>Yes</label>
						<input type='radio' id='#local.id_root#_off'  name='#local.setting#'#radioSelected(!local.selected)# value='0'><label for='#local.id_root#_off'>No</label>
					</div>";
					break;
				case "list":
					local.options = variables.contentObj.options(arguments.type,local.setting);
					retval &= displayOptions(
						options = local.options,
						setting = local.setting, 
						value   = local.value
					);
					break;
				case "shape":	
					retval &= displayOptions(
						options = variables.contentObj.shapeOptions(),
						setting = local.setting, 
						value   = local.value
					);
					break;
				case "displayblock":
				case "halign": 
				case "valign":
				case "float":
				case "overflow":
				case "flexgrow": 
				case "position":
					retval &= displayOptions(
						options = this.settingsOptions[local.settingDef.type],
						setting = local.setting, 
						value   = local.value
					);
					break;
				default:
					retval &= "<input name='#local.setting#' value='#local.value#'>";
					break;	
			}
			
		}

		return retval;
	}

	/**
	 * @hint Display the on ready JS for the settings form
	 *
	 * Surely could be a plug in?
	 */
	string function settingsFormJS(required string id) {
			return "
			// attach handler to form's submit event 
			$('##settingsForm').submit(function() { 
			    // submit the form 
			    var data = $(this).serializeData();
			    console.log(data); 

			    $.ajax({
			    	url:'api/#variables.api#?method=css',
			    	data: {'cs_id':data.cs_id, 'settings': JSON.stringify(data)},
			    	method: 'post'
			    }).done(function(e) {
			    	if (e.statuscode == 200) {
				    	$('##css').html(e.css);
				    	$#arguments.id#.data('photoGrid').reload();
			    	}
			    	else {
			    		messageHandler.error(e.statustext);
			    	}
			    }).fail(function (request, status, error) {
			    	messageHandler.error(error);
				});

			    return false; 

			});
			";
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

	private string function displayOptions(required array options, required string setting, value="", boolean optional=1) {
		var retval = "<select name='#arguments.setting#'>";
		if (arguments.optional) {
			local.selected = arguments.value eq "" ? " selected": "";
			retval &= "<option value=''#local.selected#></option>";
		}
		for (local.mode in arguments.options) {
			try {
				local.selected = local.mode.value eq arguments.value ? " selected": "";
				local.optionDescription = local.mode.description ? : "";
				local.optionName = local.mode.name ? : local.mode.value;
				retval &= "<option value='#local.mode.value#' #local.selected# title='#encodeForHTMLAttribute(local.optionDescription)#'>#encodeForHTML(local.optionName)#</option>";
			}
			catch (any e) {
				local.extendedinfo = {"tagcontext"=e.tagcontext,mode=local.mode,setting=arguments.setting};
				throw(
					extendedinfo = SerializeJSON(local.extendedinfo),
					message      = "Error in options list:" & e.message, 
					detail       = e.detail
				);
			}
		}
		retval &= "</select>";
		return retVal;
	}

}