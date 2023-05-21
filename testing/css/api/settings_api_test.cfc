/*

# Api test

Create testable version of settings_api.

## Synopsis

Extend the api object, turn off isAjaxRequest and redefine the return object.

This allows the api object to be tested locally. See test_api.cfm

*/

component extends="settings_api" {

	request.isAjaxRequest = 0;

	public any function rep(required struct return) {
		return arguments.return ;
	}



}