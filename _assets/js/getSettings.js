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
	
	for (let setting in clik_settings[type]) {
		// problems with things like grid-gap
		// Need a better test than inherit.
		if (true || clik_settings[type][setting].inherit) {
			let val = $elem.css("--" + setting);
			if (val) {
				if (clik_settings[type][setting].type.toLowerCase() == "boolean") {
					let bVal =parseInt(val);
					if (Number.isNaN(bVal)) {
						bVal = (val.toLowerCase() == "true");
					}
					else {
						// keep consistency on booleans
						bVal = bVal ? true : false;
					}
					settings[setting] = bVal;
				}
				else {
					settings[setting] = val;
				}
				
			}
		}
	}

	return settings;
}

