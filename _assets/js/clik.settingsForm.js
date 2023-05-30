/*

# Settings Form

Display a form for editing Content section and Container settings and styles.

## Synopsis

A content section will have "settings" which are unique to the cs type, and "panels" which are the containers that can be styles with normal styling such as font, color etc. E.g. for a news list, the panels will be "item", "title", "image", and "text wrap".

The settings definitions are saved to a JavaScript file.

### Settings

Settings are defined in `clik_settings.js`. This file is autogenerated from the component definitions (see testing/tools/saveSettingsData.cfm)

This defines an object clik_settings which has the cs properties defined for each object type.

#### styleDefs

collection of setting definitions. Each setting has the following keys:

type    Settings type
name    Display name
description Help description of the setting
default Default value
options Array of options for list value. NB Many types have list values defined in `clik_settings.settingsOptions`.
inherit Explicity apply value to all media sizes. Required for any properties that aren't explicit CSS properties and can't just inherit through the standard browser functionality. NB this is now almost deprecated and all the JS should read custom properties from the CSS.

#### Panels

Collection of panel definitions. General styling is applied to the panel. Only these keys are relevant:

* panel
* name

#### States

Collection of state definitions, e.g. "hover", "hi", or "disable". Each panel can have settings specifically for that state. Only these keys are relevant:

* state
* name

*/
(function($) {

	$.settingsForm = function(element, options) {

		var defaults = {

			id: 'undefined',
			settings: {},
			type: 'text',
			api: "undefined"

		}

		var plugin = this;

		plugin.settings = {}

		var $element = $(element), 
					   element = element,
					   $cs; 

		plugin.init = function() {

			if (! messageHandler) {
				console.error("messageHandler not defined");
				return;
			}
			if (! clik_settings) {
				console.error("clik_settings not defined");
				return;
			}

			plugin.settings = $.extend({}, defaults, options);
			
			$cs = $("#" + plugin.settings.id);

			displayForm();

			$('#settingsForm').submit(function() { 
			    // submit the form 
			    var data = $(this).serializeData();
			    console.log(data); 

			    $.ajax({
			    	url:`${plugin.settings.api}?method=css`,
			    	data: {'cs_id':data.cs_id, 'settings': JSON.stringify(data)},
			    	method: 'post'
			    }).done(function(e) {
			    	console.log(e);
			    	if (e.statuscode == 200) {
				    	$('#css').html(e.css);
				    	// TODO: generic reference to this -- if they need it
				    	//$cs.data('photoGrid').reload();
			    	}
			    	else {
			    		messageHandler.error(e.statustext);
			    	}
			    }).fail(function (request, status, error) {
			    	messageHandler.error(error);
				});

			    return false; 

			});

			clik.clikContent();
		}

		var displayForm = function() {
			var  settings = settingsFormFields(clik_settings[plugin.settings.type].styleDefs)
				,styles = settingsFormFields(clik_settings["panel"].styleDefs);
			var html = `<div id='settings_panel_close' class='button auto'><a href='#settings_panel.close'><svg class='icon' xmlns='http://www.w3.org/2000/svg' viewBox='0 0 357 357' preserveAspectRatio='none'><use href='/_assets/images/close47.svg#close'></use></svg><label>Close</label></a></div>
			<form id='settingsForm'>	
				<div class='formInner'>
				
				<input type='hidden' name='cs_id' value='${plugin.settings.id}'>
					<div class='formBody'>
						<div class='cs-tabs'>
							<div class='tab state_open' id='${plugin.settings.id}_tab_settings'>
								<div class='title'>
									Settings
								</div>
								<div class='item wrap'>
								${settings}
								</div>
							</div>
							<div class='tab' id='${plugin.settings.id}_tab_styles'>
								<div class='title'>
									Styles
								</div>
								<div class='item wrap'>
								${styles}
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
			</div>`;

			$element.html(html);

		}

		var settingsFormFields = function(styleDefs) {
			console.log(styleDefs);
			var retval = "<fieldset>";
			for (let setting in styleDefs) {
				let settingDef = styleDefs[setting];
				let description = settingDef.description || "No description";
				let name = settingDef.name || setting;
				retval += `<label title='${name}'>${name}</label>`;

				let value = plugin.settings.settings[setting]  || "";
				
				switch(settingDef.type) {
					
					case "boolean":
						let selected = Boolean(value);
						let onOff = {1: " selected", 0: ""};
						let id_root = `${plugin.settings.id}_${setting}`;
						retval += `<div class='field'><input id='${id_root}_on' type='radio' name='${setting}'` + inputSelected(selected) + `value='1'><label for='${id_root}_on'>Yes</label>
							<input type='radio' id='${id_root}_off' name='${setting}'` + inputSelected(!selected) + ` value='0'><label for='${id_root}_off'>No</label>
						</div>`;
						break;
					case "list":
						let options = settingDef.options;
						retval += displayOptions(
							options,
							setting, 
							value,
							("default" in settingDef)
						);
						break;
					case "shape":	
						retval += displayOptions(
							settingsOptions.shapes,
							setting, 
							value,
							true
						);
						break;
					case "displayblock":
					case "halign": 
					case "valign":
					case "float":
					case "overflow":
					case "flexgrow": 
					case "position":
						console.log("setting:" + setting, settingDef,("default" in settingDef));
						retval += displayOptions(
							settingsOptions[settingDef.type],
							setting, 
							value,
							("default" in settingDef)
						);
						break;
					default:
						retval += `<input name='${setting}' value='${value}'>`;
						break;	
				}
				
			}
			
			retval += "</fieldset>";

			return retval;

		}

		var inputSelected = function(value) {
			return value ? " selected" : "";
		}

		var displayOptions = function (options, setting, value, required) {
			if ( required == undefined) required = true;
			console.log(required);
			
			var retval = `<select name='${setting}'>`;
			if (!required) {
				let selected = arguments.value == "" ? " selected": "";
				retval += `<option value="${selected}"></option>`;
			}
			for (let mode of options) {
				
				let selected = mode.value == value ? " selected": "";
				let optionDescription = mode.description ? clik.htmlEscape(mode.description) : "";
				let optionName = mode.name ? clik.htmlEscape(mode.name) : mode.value;
				retval += `<option value='${mode.value}' ${selected} title='${optionDescription}'>${optionName}</option>`;
				
			}
			retval += "</select>";
			return retval;
		}

		// fire up the plugin!
		// call the "constructor" method
		plugin.init();

	}

	 // add the plugin to the jQuery.fn object
	$.fn.settingsForm = function(options) {

		// iterate through the DOM elements we are attaching the plugin to
		return this.each(function() {

			if (undefined == $(this).data('settingsForm')) {

				var plugin = new $.settingsForm(this, options);

				$(this).data('settingsForm', plugin);

			}

		});

	}

})(jQuery);