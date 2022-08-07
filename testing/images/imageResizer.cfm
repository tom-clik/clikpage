<cfscript>
/**
 * Legacy page for resizing downloaded files.
 * 
 * Deprecated. Please use unsplash.cfm to download sample images
 * 
 */

setting requesttimeout=3000;
local.inputFolder = "D:\unsplash\random";
local.files = DirectoryList(path=local.inputFolder,type="file");

local.outputFolder = local.inputFolder & "\out";
if (!DirectoryExists(local.outputFolder)) {
	DirectoryCreate(local.outputFolder);
}

for (local.file in local.files) {
	local.image = imageRead(local.file);
	

	imageScaleTofit(local.image, 1200, 800);

	local.thumb = duplicate(local.image);
	imageScaleTofit(local.thumb, 600, 400);

	// local.square = duplicate(local.thumb);
	// imageCrop(local.square, 0,0, 240, 240);

	local.filename = ListLast(local.file,"\/");

	imageWrite(name=local.image, destination=local.outputFolder & "\" & local.filename,quality="0.80");
	imageWrite(name=local.thumb, destination=local.outputFolder & "\" & imageName(local.filename,"thumb"),quality="0.80");
	

}


function imageName(filename, suffix) {
	return Replace(filename,"." & ListLast(filename,"."), "_" & suffix & "." & ListLast(filename,"."));
}


</cfscript>