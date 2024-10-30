/*
Return settings for a CS item from the CSS

## Synopsis

For every property defined in styledefs (these are saved in clik_settings.js)
we check if it's a "setting" as opposed to a plain style and then fetch
it from the CSS if it is.

*/
function getSettings($elem, type) {
	if (! clik_settings || ! type in clik_settings) {
		console.warn("Settings not defined");
		return;
	}
	
	let settings = {};
	
	for (let setting in clik_settings[type].styleDefs) {
		// problems with things like grid-gap
		// Need a better test than inherit.
		if (true || clik_settings[type][setting].inherit) {
			let val = $elem.css("--" + setting);
			if (val) {
				settings[setting] = parseCssVar(val, clik_settings[type].styleDefs[setting].type.toLowerCase() );
			}
		}
	}
		
	return settings;
}

/* just get named settings -- no control over the type */
function getCssSettings($elem, names) {
	settings = {};
	for (let setting of names.split(",")) {
		let val = $elem.css("--" + setting);
		if (val) {
			settings[setting] = val;
		}
	
	}
	return settings;
}

function parseCssVar(stringVal, type) {
	let val = stringVal;
	if (type == "boolean") {
		val = parseInt(stringVal);
		if (Number.isNaN(val)) {
			val = (stringVal.toLowerCase() == "true");
		}
		else {
			// keep consistency on booleans
			val = val ? true : false;
		}
		
	}
	
	return val;
}
