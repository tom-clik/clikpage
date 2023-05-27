/*

# Api test

Create testable version of testingApi.

## Synopsis

Just extend the api object, turn off isAjaxRequest and redefine the return object.

*/
component extends="testingApi" {

	request.isAjaxRequest = 0;

	public any function rep(required struct return) {
		return arguments.return ;
	}

	function testError() returnformat="plain" {
		local.extendedinfo = {"Cat":"Gingy","did":[1,2,3,4]};
		
		throw(message="Test message",type="custom",detail="this is the detail",extendedinfo=serializeJson(local.extendedinfo));
		
	}


}