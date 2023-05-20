component extends="settings_api" {

	request.isAjaxRequest = 0;

	public any function rep(required struct return) {
		return arguments.return ;
	}



}