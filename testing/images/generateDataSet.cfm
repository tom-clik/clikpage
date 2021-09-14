<cfscript>

/* Use the json data from downloaded files to generate a data set for testing

Provided strictly on an as-is basis

## Usage

Use unsplash.cfm and then run this.

*/

outputFolder = getDirectoryFromPath(getCurrentTemplatePath());

dataFiles = directoryList(path=outputFolder,filter="*.json");
dataList = [];
for (filename in dataFiles) {
	data = fileRead(filename);
	image = deserializeJSON(data);
	arrayAppend(dataList, {"src":"/images/#image.thumb.src#","caption"=image.caption,"link"=image.main.src});
}

WriteDump(dataList);



</cfscript>