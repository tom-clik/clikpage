/*

# clikpage Sample App

## History

|-----------|------|---------------------
|2019-09-19 | THP  | Created

*/

component extends="clikpage.clikpageApplication" { //
	// Application properties
	this.name = "clikpagesample";

	this.rootDir = GetCanonicalPath(getCurrentTemplatePath() & "../../../..");
	this.mappings = [
		"/_assets" = this.rootDir & "clikpage\_assets",
	];
	
	this.debug = 1;
	
	public boolean function startApp(){
		application.config = {
			layoutsFolder=ExpandPath("_data/layouts"),
			siteDef=ExpandPath("_data/sampleSite.xml")
		};

		return true;

	}

	

}