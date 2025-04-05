/*
Expose some private methods for testing
*/

component extends="clikpage.settings.settings" {

	

	public function mediaQuery() {
		return super.mediaQuery(argumentcollection=arguments);
	}

}