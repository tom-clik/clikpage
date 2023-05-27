/**
 * # Test API
 *
 * 
 */
component extends="clikpage.api.baseApi" {

	private boolean function isLoggedIn() {
		return true;
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