/*

# clikpage Sample App

Skeleton application showing usage of singleton component to render pages

## Usage

## Notes

Why is there redefinition of functions??? THP

## History

|-----------|------|---------------------
|2019-09-19 | THP  | Created

*/


component   extends="clikpage.clikpageApplication" { //
	// Application properties
	this.name = "clikpagesample";
	this.componentpaths=[ExpandPath("../..")];

	// Java Integration
	// this.javaSettings = { 
	// 	loadPaths = [ ".\lib" ], 
	// 	loadColdFusionClassPath = true, 
	// 	reloadOnChange= false 
	// };

	// application start
	this.debug = 1;

	public boolean function startApp(){
		application.config = {
			layoutsFolder=ExpandPath("layouts"),
			siteDef=ExpandPath("_data/sampleSite.xml"),
			styledef=ExpandPath("styles/sample_style.xml")
		};

		return true;

	}

	

}