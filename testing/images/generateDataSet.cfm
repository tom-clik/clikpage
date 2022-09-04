<cfscript>

/* Use the json data from downloaded files to generate a data set for testing

Provided strictly on an as-is basis

## Usage

Use unsplash.cfm to download images and generate the json files and then run this.

*/

// processes all files in folder
imageFolder = GetDirectoryFromPath(getCurrentTemplatePath());
// tags for data (use list for multiple) - must be defined, leave blank if none
tags = "gallery";
dataFile = imageFolder & "photos3.xml";
identity = 1; // identity seed
if (FileExists(dataFile)) {
	FileDelete(dataFile);
}
fileHandle = FileOpen(file=dataFile, mode="write", charset="UTF-8");

try { 	 

	FileWriteLine(fileHandle, "<?xml version=""1.0"" encoding=""UTF-8""?>");
	FileWriteLine(fileHandle,"<images>");

	dataFiles = DirectoryList(path=imageFolder,filter="*.json");
	dataList = [];
	for (filename in dataFiles) {
		image = false;
		try {
			data = FileRead(filename);
			image = DeserializeJSON(data);
			FileWriteLine(fileHandle,"  <image id='#identity#'>");
			FileWriteLine(fileHandle,"    <image_thumbnail>#image.thumb.src#</image_thumbnail>");
			FileWriteLine(fileHandle,"    <image>#image.main.src#</image>");		
			FileWriteLine(fileHandle,"    <caption>#image.caption#</caption>");	
			if (tags != "") {
				FileWriteLine(fileHandle,"    <tags>#tags#</tags>");	
			}
			FileWriteLine(fileHandle,"  </image>");
		}
		catch (any e) {
			writeOutput("Unable to write data for image #filename#");
			
		}
		identity++;
	}

	FileWriteLine(fileHandle,"</images>");
	
	WriteOutput("File written to #dataFile#");
}
catch (any e) {
	extendedinfo = {"tagcontext"=e.tagcontext};
	throw(
		extendedinfo = SerializeJSON(local.extendedinfo),
		message      = "Unable to save data:" & e.message, 
		detail       = e.detail,
		errorcode    = "generateDataSet.1"		
	);
}
finally {
	try {
		FileClose(fileHandle);
	}
	catch (any e) {
		local.extendedinfo = {"tagcontext"=e.tagcontext};
		throw(
			extendedinfo = SerializeJSON(local.extendedinfo),
			message      = "Unable to close file:" & e.message, 
			detail       = e.detail,
			errorcode    = "generateDataSet.2"		
		);
	}
}



</cfscript>