component extends="clikpage.testing.api.testingApi" {

	remote function testTransaction() returnformat="json" {
		var ret = checkAuth();
		ret["OK"] = 1;
		ret["MESSAGE"] = "Thank you for your order, #arguments.field1#";
		ret["ARGUMENTS"] = serializeJSON(arguments);
		return ret;
	}

	remote function testInvalid() returnformat="json" {
		var ret = checkAuth();
		ret["field1"] = "This value is no good";
		ret["field3"] = "Nor this one value is no good";
		ret["field4"] = "As for this";
		return ret;
	}
	
}