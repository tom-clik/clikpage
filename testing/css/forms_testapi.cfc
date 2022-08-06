component extends="clikpic.api.baseApi" {

	remote function testTransaction() returnformat="json" {
		var ret = checkAuth();
		ret["OK"] = 1;
		ret["MESSAGE"] = "Thank you for your order, #arguments.field1#";
		ret["ARGUMENTS"] = serializeJSON(arguments);
		return ret;
	}
	
}