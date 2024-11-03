/*

# clikpage preview

## History

|-----------|------|---------------------
|2022-12-07 | THP  | Created

*/

component extends="clikpage.clikpageApplication" { //
	// Application properties
	this.name = "clikpagepreview";

	this.rootDir = GetCanonicalPath(getCurrentTemplatePath() & "../../../../../../");
	
	this.mappings = [
		"/_assets" = this.rootDir & "clikpage\_assets",
	];
	this.errorsFolder = this.rootDir & "\testing\_errors";
	this.debug = 1;
	
	public boolean function startApp(){
		
		local.path = ExpandPath("./config.json");
		if (NOT FileExists(local.path )) {
			throw(
				message="File ./config.json not found",
				detail="To use the preview app, copy the sample config to config.json and configure. This is gitignored as
					you edit it according to your current project"

			);
		}
		local.fileData = fileRead(local.path );

		application.config = deserializeJSON(local.fileData);

		application.dataObj = new clikpage.data.data_text(application.config);

		return true;

	}

}