<!---

# compressCSS

Compress static files

--->

<cfscript>
mappings = [
	"/_assets/" = ExpandPath("../_assets/"),
	"/articlemanager/_assets/" = ExpandPath("../../articlemanager/_assets/")
];

for (opts in ["CSS","JS"]) {
	defFile = ExpandPath("../staticFiles/static#opts#.json");
	try {
		jsonData = deserializeJSON( FileRead(defFile) );
	}
	catch (any e) {
		local.extendedinfo = {"tagcontext"=e.tagcontext,"mappings":mappings,"opts":opts};
		throw(
			extendedinfo = SerializeJSON(local.extendedinfo),
			message      = "Unable to parse static files definition file #defFile#:" & e.message, 
			detail       = e.detail
		);
	}
	staticFilesObj = new clikpage.staticFiles.staticFiles(staticDef=jsonData);

	packages = staticFilesObj.compressPackage(type=opts,overwrite=false,mappings=mappings,minify=true);

	for (res in packages) {
		writeDump(res);
	}
}

</cfscript>
