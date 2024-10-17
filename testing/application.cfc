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
		param name="request.rc.reload" type="boolean" default="0";
		if (request.rc.reload) {
			server.utils = StructNew();
		}
	}

	function onError(e,method) {
		
		param name="request.isAjaxRequest" type="boolean" default="0";
		try {
			new clikpage.errors.ErrorHandler(e=e,isAjaxRequest=request.isAjaxRequest,errorsFolder=this.errorsFolder,debug=this.debug);
		}
		catch (any n) {
			writeDump(n);
			writeDump(e);
		}
	}

}



