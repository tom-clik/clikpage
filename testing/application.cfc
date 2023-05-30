component {

	this.sessionManagement = false;
	this.debug = true;
	this.baseDir = ExpandPath("..\..\..");
	this.componentPaths=[this.baseDir];

	this.rootDir = Replace(getDirectoryFromPath(getCurrentTemplatePath()),"\testing","");
	this.mappings = [
		"/_assets" = this.baseDir & "\clikpage\_assets",
	];

	this.errorsFolder = this.rootDir & "\testing\_errors";
	
	public void function onApplicationStart()  output=false {
		application.utils = new utils.utils();
		application.XMLutils = new utils.XML();
	}

	public void function onRequestStart() output=false {

		request.rc = Duplicate(url);
		StructAppend(request.rc,form,true);
		request.prc = {};
		onApplicationStart();
	}

	

}



