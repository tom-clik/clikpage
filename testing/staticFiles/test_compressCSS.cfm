<!---

# test_compressCSS

Test pad for testing staticFiles compression method

## Synopsis

Create a staticfiles object and load a def file.

Run the compressPackage Method

## Usage

Preview in testing server context.

By default file names are generated by expanding the path of the files. 

You can specify different folders by supply an ordered struct of mappings.

E.g.

```
[
	"/_assets/js" = "D:\dev\jsoutputfolder"
]
```

Would match a  file specified as `/_assets/js/myscript.js`

Note that all mappings are applied so if there is a potential conflict with the 
output paths, you might need to specify an output folder with a higher priority, e.g.

```
[
	"/_assets/js" = "D:\dev\libraries\assets\js",
	"/_assets/js/min"= "D:\dev\jsoutputfolder"
]
```

A build process would probably also push the files to the cloud or similar.

--->

<cfscript>
mappings = [
	"/_assets/" = ExpandPath("/_assets/"),
	"/_assets/css/_min/" = ExpandPath("_output/"),
	"/_assets/js/_min/" = ExpandPath("_output/")
];

for (opts in ["CSS","JS"]) {
	// defFile = ExpandPath("test_js.json");
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
