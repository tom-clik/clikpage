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

		variables.settingOptions = {};
		variables.settingOptions["displayblock"] = [
			{"value":"none","name":"Hide","description":""},
			{"value":"block","name":"Show","description":""}
		];
		variables.settingOptions["halign"] = [
			{"value":"left","name":"Left","description":""},
			{"value":"center","name":"Centre","description":""},
			{"value":"right","name":"Right","description":""}
		];
		variables.settingOptions["valign"] = [
			{"value":"top","name":"Top","description":""},
			{"value":"middle","name":"Middle","description":""},
			{"value":"bottom","name":"Bottom","description":""}
		];
		variables.settingOptions["flexgrow"] = [
			{"value":"1","name":"Yes","description":"Item will expand to fit width (if set)"},
			{"value":"0","name":"No","description":"Item will not expand."}
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
		var retval = "	<div id='settings_panel' class='settings_panel modal'>
		<div id='settings_panel_close' class='button auto'><a href='##settings_panel.close'><svg class='icon' xmlns='http://www.w3.org/2000/svg' viewBox='0 0 357 357' preserveAspectRatio='none'><use href='/_assets/images/close47.svg##close'></use></svg><label>Close</label></a></div>
			
		<form id='settingsForm'>
			<input type='hidden' name='cs_id' value='#arguments.contentsection.id#'>
			<div class='formInner'>
				<div class='title'>
					<h2>Settings</h2>
				</div>
				<div class='wrap'>";
					
		local.settings = arguments.contentsection.settings[arguments.media];

		retval &= "<fieldset>";
		for (local.setting in variables.contentObj.contentSections[arguments.type].styleDefs) {
			local.settingDef = variables.contentObj.contentSections[arguments.type].styleDefs[local.setting];
			local.description = local.settingDef.description? : "No description";
			local.name = local.settingDef.name? : local.setting;
			retval &= "<label title='#encodeForHTMLAttribute(local.description)#'>#local.name#</label>";
			local.value = local.settings[local.setting] ? : "";
			
			switch(local.settingDef.type) {
				
				case "boolean":
					local.selected = isBoolean(local.value) AND local.value;
					local.onOff = {1: " selected", 0: ""};
					local.id_root = "#arguments.contentsection.id#_#local.setting#";
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
					/* MUSTDO: add shapeOptions to contentObj */
					retval &= displayOptions(
						options = variables.contentObj.shapeOptions(),
						setting = local.setting, 
						value   = local.value
					);
					break;
				case "displayblock":
				case "halign": 
				case "valign":
				case "flexgrow": 
					retval &= displayOptions(
						options = variables.settingOptions[local.settingDef.type],
						setting = local.setting, 
						value   = local.value
					);
					break;
				default:
					retval &= "<input name='#local.setting#' value='#local.value#'>";
					break;	
			}
			
		}
		retval &= "
					</fieldset>
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
		for (local.setting in variables.contentObj.contentSections[arguments.cs.type].styleDefs) {
			if (structKeyExists(arguments.values, local.setting) AND arguments.values[local.setting] != "") {
				arguments.styles.style[arguments.cs.id][arguments.medium][local.setting] = arguments.values[local.setting];
			}
			
		}
		
		variables.contentObj.settings(content=arguments.cs,styles=arguments.styles.style,media=arguments.styles.media);
	}

	private string function displayOptions(required array options, required string setting, value="") {
		var retval = "<select name='#arguments.setting#'>";
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