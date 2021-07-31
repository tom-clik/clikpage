<cfscript>


/* Download images from unsplash for testing. 

Provided strictly on an as-is basis

## Usage

Create list of unspash ids and run.

*/

// DKWjcMHF54E,jSqrSrtjB80,wlNh84JRb2M,Z89kRdt8wFE,OAzh2bBN110,Y1OUQTZRqMo,p70S-sgZtVI,t03o51DDV8Q,NiOAwBuV8f4

idslist = ListToArray('bgacbJ4DQq8,HMhRTbuSEhY');
outputFolder = getDirectoryFromPath(getCurrentTemplatePath());
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
		
		source = imageNew(download.filecontent);
				

		for (format in formats) {

		
			// write(local.filename);
			// try {
			// 	cffile( action="move",source=outputFolder & "temp.jpg");
			// 	local.info[format.name] = {"src"=local.filename};
			// }
			// catch (Any e) {
			// 	writeDump(outputFolder & "temp.jpg");
			// 	writeDump(outputFolder & local.filename);
			// 	writeDump(e);
			// }

			
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
	writeOutput(serializeJSON(local.info));

	FileWrite(outputFolder&photo&".json", serializeJSON(local.info));
	// writeDump(download);
}



function writep(html) {
	writeOutput("<p>" & html & "</p>");
}

</cfscript>