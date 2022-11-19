component {

	request.prc.isAjaxRequest = 1;

	remote function testError() returnformat="plain" {
		local.extendedinfo = {"Cat":"Gingy","did":[1,2,3,4]};
		
		throw(message="Test message",type="ajaxError",detail="this is the detail",extendedinfo=serializeJson(local.extendedinfo));
	}

	/**
	 * Set http headers for status
	 */
	private void function setStatus(required struct returnData) {
		
		StructAppend(arguments.returnData, {"statuscode":200,"ok":true},false);
		
		cfheader( name="statuscode", value=arguments.returnData.statuscode );
		
		if (structKeyExists(arguments.returnData, "statustext" )) {
			cfheader( name="statustext", value="#arguments.returnData.statustext#" );
		}

	}
	
	/** 
	 * Check auth status of request
	 * 
	 * Only continue after this is status is 200
	 * 
	 */

	remote struct function checkAuth() returnformat="json" {
		
		if(true){
			local.return = {
				'status': 200,
				'statustext': 'ok'
			};
		}
		else {
			local.return = {
				'status': 401,
				'statustext': 'login required'
			};
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
		arguments.return.status = 400;
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
		
		return arguments.status eq 200;

	}

	/**
	remote struct function sampleFunction(
			required string action
		) returnformat="json"
		{
		
		local.return = checkAuth( );
		if (local.return.status == 200) {
			if(ListFind("add,remove", arguments.action)){
				local.return["data"] = {"hello"="world"};
			}
			else {
				local.return = {
					'status': '400',
					'message': 'badrequest'
				};
			}
		}
		
		return local.return;
	
	}
	*/


}