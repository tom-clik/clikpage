/*

# Error handler


## Usage

Used as a proper object.

```cfml
onError(e) {
	new errors.ErrorHandler(e=e,isAjaxRequest=request.isAjaxRequest,errorsFolder=this.errorsFolder);
}
```


 */ 
component {

	public void function init(e, boolean isAjaxRequest=0, errorsFolder="",debug=0) {
		
		this.errorsFolder = arguments.errorsFolder;
		var niceError = [
			"usermessage"="Sorry, an error has occurred",
			"message"=arguments.e.message,
			"detail"=arguments.e.detail,
			"code"=arguments.e.errorcode,
			"ExtendedInfo"=deserializeJSON(arguments.e.ExtendedInfo),
			"type"=arguments.e.type,
			"statuscode"=500,
			"statustext"="Error",
			"report"=1,
			"id"=createUUID()
		];

		// supply original tag context in extended info
		if (IsDefined("niceError.ExtendedInfo.tagcontext")) {
			niceError["tagcontext"] =  niceError.ExtendedInfo.tagcontext;
			StructDelete(niceError.ExtendedInfo,"tagcontext");
		}
		else {
			niceError["tagcontext"] =  e.TagContext;
		}
		
		switch ( niceError.type ) {
			case  "badrequest": case "validation":
				niceError.statuscode="400";
				niceError.statustext="Bad Request";
				niceError.report = 0;
				break;
			case  "forbidden":
				niceError.statuscode="403";
				niceError.statustext="Forbidden";
				niceError.report = 0;
				break;
			case  "Unauthorized":
				niceError.statuscode="401";
				niceError.statustext="Unauthorized";
				niceError.report = 0;
				break;

			case "missinginclude": case  "notfound": case  "notfounddetail":case "not found":
				niceError.statuscode="410";
				niceError.statustext="Page not found";
				niceError.report = 0;
				break;
			case "ajaxerror":
				// avoid throwing ajaxerror. better to set isAjaxRequest
				// and throw normal error
				arguments.isAjaxRequest = 1;
				break;
			case  "custom":
				// custom error messages show thrown message
				niceError.usermessage  = niceError.message;
				break;
		}
		
		if (arguments.isAjaxRequest) {

			local.error = {
				"statustext": niceError.statustext,
				"statuscode": niceError.statuscode,
				"message" : arguments.debug ? niceError.message : niceError.usermessage
			}
			
			if (niceError.report) {
				local.error["id"] = niceError.id;
				logError(niceError);
			}
			content type="application/json; charset=utf-8";
			WriteOutput(serializeJSON(local.error));
		}
		else {
			if (arguments.debug) {
				cfheader( statuscode=niceError.statuscode, statustext=niceError.statustext );
				writeDump(var=niceError,label="Error");
			}
			else {
				cfheader( statuscode=niceError.statuscode, statustext=niceError.statustext );
				if (! niceError.report) {
					abort;
				}

				logError(niceError);
				
				var errortext = "<h1>Error</h1>";
				errortext &= "<p>Please contact support quoting ref #niceError.id#</p>";
				
				// try to write nice page
				local.pageWritten = false;
				
				// TODO: don't do this. Use the system to write out
				// a template and use that.
				if (IsDefined("application.pageObj")) {

					try {
						request.content.body = errortext;
						writeOutput(application.pageObj.buildPage(request.content));
						local.pageWritten = true;
					}
					catch (any e) {

					}
				}
				if (NOT local.pageWritten) {
					writeOutput(errortext);
				}

			}
			
		}
		
	}

	public boolean function logError(required struct error) {
		local.errorCode = 0;
		if (this.errorsFolder != "")  {
			try {
				local.filename = this.errorsFolder & "/" & arguments.error.id & ".html";
				writeDump(var=error,output=local.filename,format="html");
				local.errorCode = 1;
			}
			catch (any e) {
				// ignore failure to write to log
			}
		}

		return local.errorCode;

	}
}