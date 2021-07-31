/*

Testing object to expose private methods of settingsObj

*/

component extends="clikpage.settings.settingsObj" {

	public function mediaQuery() {
		return super.mediaQuery(argumentCollection = arguments);
	}

}