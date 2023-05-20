/*

# SettingsEdit

Utilities for editing settings

## Description

Bit of a scratchpad at the minute. Putting all the embryonic work we'd done in the test pages into here to pull into shape.

*/
component {

	settingsEdit function init(
		required any    contentObj,
		         string api       = "settings_api.cfc"
		) {
		variables.contentObj = arguments.contentObj;
		variables.api = arguments.api;
		return this;
	}

	string function settingsForm(required struct contentsection, required string media="main") {

		var retval = "<form id='settingsForm' action='imagegrid.cfm'>
						<input type='hidden' name='cs_id' value='#arguments.contentsection.id#'>
						<div class='formInner'>
							<div class='title'>
								<h2>Settings</h2>
							</div>
							<div class='wrap'>";
					
		local.settings = arguments.contentsection.settings[arguments.media];

		retval &= "<fieldset>";
		for (local.setting in variables.contentObj.contentSections["imagegrid"].styleDefs) {
			local.settingDef = variables.contentObj.contentSections["imagegrid"].styleDefs[local.setting];
			local.description = local.settingDef.description? : "No description";

			retval &= "<label title='#encodeForHTMLAttribute(local.description)#'>#local.settingDef.name#</label>";
			local.value = local.settings[local.setting] ? : "";
			
			switch(local.settingDef.type) {
				case "dimension":
				case "dimensionlist":
				case "text":
				case "integer":
					retval &= "<input name='#local.setting#' value='#local.value#'>";
					break;
				case "boolean":
				local.selected = isBoolean(local.value) AND local.value ? " selected": "";
					retval &= "<div class='field'><input type='checkbox' name='#local.setting#'#local.selected# value='1'>Yes</div>";
					break;
				case "list":
					local.options = variables.contentObj.options("imagegrid",local.setting);
					retval &= "<select name='#local.setting#'>";
					for (local.mode in local.options) {
						try {
							local.selected = local.mode.value eq local.value ? " selected": "";
							retval &= "<option value='#local.mode.value#' #local.selected# title='#encodeForHTMLAttribute(local.mode.description)#'>#encodeForHTML(local.mode.name)#</option>";
						}
						catch (any e) {
							local.extendedinfo = {"tagcontext"=e.tagcontext,mode=local.mode};
							throw(
								extendedinfo = SerializeJSON(local.extendedinfo),
								message      = "Error:" & e.message, 
								detail       = e.detail
							);
						}
					}
					retval &= "</select>";
					break;

			}
			
		}
		retval &= "</fieldset>
				</div>
				<div class='submit'>
					<label></label>				
					<div class='button'><input type='submit' value='Update'></div>
				</div>
			</div>
		</form>";

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
			    	url:'#variables.api#?method=css',
			    	data: {'cs_id':data.cs_id, 'settings': JSON.stringify(data)},
			    	method: 'post'
			    }).done(function(e) {
			    	$('##css').html(e.css);
			    	console.log($('##css').html()); 
			    	console.log('we have updated');
			    	$#arguments.id#.data('photoGrid').reload();
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

}