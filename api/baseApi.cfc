component {

	request.isAjaxRequest = 1;
	
	// VIRTUAL
	private boolean function isLoggedIn() {
		throw("You need to create your own isLoggedIn() method.");
	}
	/**
	 * Set http headers for status
	 */
	private void function setStatus(required struct returnData) {
		
		StructAppend(arguments.returnData, {"statuscode":200},false);
		
		cfheader( statuscode=arguments.returnData.statuscode );
		
		if (structKeyExists(arguments.returnData, "statustext" )) {
			cfheader( statustext="#arguments.returnData.statustext#" );
		}

	}

	/**
	 * Check user is logged in
	 */
	remote string function checkAuth() {
		return rep( _checkAuth() );
	}
	/** 
	 * @hint Check auth status of request
	 * 
	 * Only continue after this is status is 200
	 * 
	 */
	private struct function _checkAuth() {
		
		if ( isLoggedIn() ) {
			local.return = {
				'statuscode': 200,
				'statustext': 'ok'
			};
		}
		else {
			local.return = {
				'statuscode': 401,
				'statustext': 'login required'
			};
			rep ( local.return )
		}

		return local.return;
	}

	/** Add an error to a return struct 

	@return the api return struct
	@error error to add
	*/
	private void function addError(required struct return, required string error) {
		
		if (! StructKeyExists(arguments.return, "errors")) {
			arguments.return["errors"] = [];
		}
		arguments.return.statuscode = 400;
		arguments.return.statustext = 'badrequest';

		ArrayAppend(arguments.return["errors"], arguments.error);

	}

	/** Update the message in the return struct 
	
	@return the api return struct
	@error message to add

	*/
	private void function addMessage(required struct return, required string message, string type="success", string placement="auto") {
		
		if (! StructKeyExists(arguments.return, "message")) {
			arguments.return["message"] = [];
		}
		
		ArrayAppend(arguments.return["message"], {
			"type" = arguments.type,
			"message" = arguments.message,
			"placement" = arguments.placement
		});


	}

	/** Check the status of a return struct is ok to continue
	*/
	private boolean function statusOk(required struct return) {
		
		return arguments.return.statuscode eq 200;

	}

	private string function rep(required struct return) {
		setJSON();
		setStatus(arguments.return);
		writeOutput( serializeJSON( arguments.return ) );
		abort;
	}

	private void function setJSON() {
		content type="application/json; charset=utf-8";
	}
	/**
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
		
		
		rep (local.return);
	
	}
	*/


}