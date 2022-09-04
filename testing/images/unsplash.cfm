<cfscript>


/* Download images from unsplash for testing. 

Provided strictly on an as-is basis

## Usage

1. Configure formats as required.
2. Change outputFolder if needed
3. Create list of unspash ids
4. Run.

This will generate an an image for each format and a json file. See generateDataSet.cfm for using these

*/

// 
cfsetting(requesttimeout="5000" );

idslist = ListToArray('wlNh84JRb2M,Z89kRdt8wFE,OAzh2bBN110,Y1OUQTZRqMo,p70S-sgZtVI,NiOAwBuV8f4');
outputFolder = GetDirectoryFromPath(getCurrentTemplatePath());
formats = [{"name":"main","width":1200,"ext":""},{"name":"thumb","width":600,"ext":"_thumb"}];
outputData = {};

for (photo in idslist) {
	writep(photo);
	local.info = {};
	cfhttp( url="https://unsplash.com/photos/#photo#/download?force=true&w=1920", result="download", path=outputFolder, file="temp.jpg" );
	if (StructKeyExists(download.responseheader,"content-disposition")) {
		local.filename = ListLast(download.responseheader["content-disposition"],"""");
		// photographer name from image
		local.info["caption"] = Replace(Replace(ListFirst(local.filename,"."),"-#photo#-unsplash",""),"-"," ");
		
		local.ext = "." & ListLast(local.filename,".");
		
		source = ImageNew(download.filecontent);
		
		for (format in formats) {

			source.scaleToFit(format.width, format.width,"lanczos");
			local.outputFile = Replace(local.filename, local.ext,format.ext & local.ext);
			cfimage(action="info", source="#source#",structName="info");
			cfimage(action="write", source="#source#" destination="#local.outputFile#", overwrite="true", quality=".6");
			local.info[format.name]["src"] = local.outputFile ;
			local.info[format.name]["width"] = info.width;
			local.info[format.name]["height"] = info.height;
		
		}
	}
	else {
		 writep("Unable to download photo");
	}
	WriteOutput(serializeJSON(local.info));

	FileWrite(outputFolder&photo&".json", SerializeJSON(local.info));
}


FileDelete(outputFolder & "/" & "temp.jpg");

function writep(html) {
	WriteOutput("<p>" & html & "</p>");
}

</cfscript>