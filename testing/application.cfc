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
		
		// remember to add path for logs !!! this.mappings["/logs/"]=[outside your web root!];
		local.args = {
			e=e,
			debug=1,
			isAjaxRequest=request.prc.isAjaxRequest ? : 0,
			pageTemplate=application.errorTemplate ? : "",
			logger= application.errorLogger ? : new cferrorHandler.textLogger( ExpandPath( "/logs/errors" ) )
		};

		try {
			new cferrorHandler.ErrorHandler(argumentcollection=local.args);
		}
		catch (any n) {
			throw(object=e);
		}
	}

}



