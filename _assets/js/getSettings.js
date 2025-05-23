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
		if ( clik_settings[type].styleDefs[setting].setting ) {
			let val = $elem.css("--" + setting);
			if (! val) {
				if ("default" in clik_settings[type].styleDefs[setting]) {
					val = clik_settings[type].styleDefs[setting].default;
				}
			}
			if ( val ) {
				settings[setting] = clik.parseCssVar(val, clik_settings[type].styleDefs[setting].type.toLowerCase() );
			}
		}
	}
		
	return settings;
}
