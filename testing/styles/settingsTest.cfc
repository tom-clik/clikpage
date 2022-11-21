/*

Testing object to expose private methods of settingsObj

*/

component extends="clikpage.settings.settings" {
	
	public function mediaQuery() {
		return super.mediaQuery(argumentCollection = arguments);
	}

}