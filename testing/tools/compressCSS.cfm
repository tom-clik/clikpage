<!---

# compressCSS

Compress static file packages for Clikpage

## Usage

After you have adjusted the static file definitions (../../staticFiles/static*.json), bump the number of the packages and use this to save them
--->

<cfscript>
mappings = [
	"/_assets/" = ExpandPath("/_assets/")
];

for (opts in ["CSS","JS"]) {
	defFile = ExpandPath("../../staticFiles/static#opts#.json");
	tempData = FileRead(defFile);
	try {
		jsonData = deserializeJSON(tempData);
	}
	catch (Any e) {
		throw("Unable to parse static files definition file #arguments.defFile#");	
	}

	staticFilesObj = new clikpage.staticFiles.staticFiles(staticDef=jsonData);

	packages = staticFilesObj.compressPackage(type=opts,overwrite=true,mappings=mappings);

	for (res in packages) {
		writeDump(res);
	}
}

</cfscript>
