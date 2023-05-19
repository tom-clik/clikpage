component extends="clikpage.api.baseApi" {

	private boolean function isLoggedIn() {
		return true;
	}
	
	remote function css(settings) {

		var ret = _checkAuth();

		// FileWrite( ExpandPath("_generated/imagegrid.css"), css );
		
		try {
			
			if ( arguments.keyExists("settings") ) { 
				local.settingsVals = deserializeJSON(arguments.settings);
				var settingsObj = new settings();
				settingsObj.updateSettings(local.settingsVals);
				ret["css"] = settingsObj.css();
			}
			else {
				ret.statuscode = 400;
			}
		}
		catch (any e) {
			writeDump(var=e,output=ExpandPath("ajax_error.html"),format="html");
			ret.statuscode = 500;
		}

		return rep ( ret );
		
	}

	remote function sampleFunction(
			string action
		)
		{
		
		local.return = _checkAuth();
		
		if(ListFind("add,remove", arguments.action)){
			local.return["data"] = {"hello"="world"};
		}
		else {
			addError(local.return,"Action is required");
		}
		
		
		return rep (local.return);
	
	}

}