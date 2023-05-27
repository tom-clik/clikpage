/**
 * # API for the content testing system
 *
 * Mainly WIP. Bit of a scratchpad while I work through how this is all going to
 * work.
 *
 * Will only work from content_test.cfm. That page loads several components that
 * are required here. These will obvs go into application for real application.
 * 
 */
component extends="clikpage.api.baseApi" {

	private boolean function isLoggedIn() {
		return true;
	}
	
	remote function css(required string cs_id, string settings="") {

		var ret = _checkAuth();

		// FileWrite( ExpandPath("_generated/imagegrid.css"), css );
		if ( arguments.keyExists("settings") ) { 
			local.settingsVals = deserializeJSON(arguments.settings);
			application.settingsEdit.updateSettings(
				cs     = application.settingsTest.site.cs[arguments.cs_id],
				styles = application.settingsTest.styles,
				values = local.settingsVals,
				medium = "main"
			);

			ret["css"] = application.settingsTest.css();
		}
		else {
			ret.statuscode = 400;
			ret.statustext = "Bad request";
		}
		
		return rep ( ret );
		
	}

	remote function errorTest() {
		throw("My error");
	}

}