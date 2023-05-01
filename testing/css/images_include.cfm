<cfscript>
/*
Some common functions for including in test pages
*/

/**
 * To use images in a grid content section we need a record of all images
 * as a look up struct ("Data") and an array of ids ("data set").
 *
 * This function uses the sample data to add the complete data to the struct
 *  supplied by reference and adds the ID to the array.
 * and
 */
array function getImages(required struct site, image_path="/images/") {
	
	local.myXML = application.utils.fnReadXML(ExpandPath("../../sample/_data\data\photos.xml"));
	local.images = application.XMLutils.xml2Data(local.myXML);
	arguments.site.images = [=];
	local.image_set = [];

	for (local.image in local.images) {
		local.image.image = image_path & local.image.image_thumb;
		local.image.image_thumb = image_path & local.image.image_thumb;
		arguments.site.images[local.image.id] = local.image;
		ArrayAppend(local.image_set, local.image.id);
	}

	return local.image_set;

}

function contentCSS(required struct cs) {
	local.site_data = { "#arguments.cs.id#" = arguments.cs};
	local.css = contentObj.contentCSS(styles=styles, content_sections=local.site_data, media=styles.media, format=false);
	return local.css;
}

</cfscript>
