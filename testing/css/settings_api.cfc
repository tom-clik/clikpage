component {

	remote struct function css(settings) returnformat="json" {

		// FileWrite( ExpandPath("_generated/imagegrid.css"), css );
		
		try {
			var ret = {"status":"200"};
			
			if ( arguments.keyExists("settings") ) { 
				local.settingsVals = deserializeJSON(arguments.settings);
				var settingsObj = new settings();
				settingsObj.updateSettings(local.settingsVals);
				ret["css"] = settingsObj.css();
			}
			else {
				ret.status = 400;
			}
		}
		catch (any e) {
			writeDump(var=e,output=ExpandPath("ajax_error.html"),format="html");
			ret.status = 500;
		}

		return ret;
		
	}

}