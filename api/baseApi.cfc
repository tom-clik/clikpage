component {

	request.prc.isAjaxRequest = 1;

	remote function testError() returnformat="plain" {
		local.extendedinfo = {"Cat":"Gingy","did":[1,2,3,4]};
		
		throw(message="Test message",type="ajaxError",detail="this is the detail",extendedinfo=serializeJson(local.extendedinfo));
	}

	struct function checkAuth() {
		return {"status":200}
	} 

}