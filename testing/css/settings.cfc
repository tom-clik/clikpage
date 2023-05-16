/* WIP. Taken from imagegrid.cfm

This is a funny thing at the minute. It has the cs and styles loaded into it
and will refresh every time.

Next stage is to make it into a singleton and pass in a "data" struct with
the values in it.

It's also hardwired to imagegrids.

*/ 
component {

	public any function init(string testname="") {
		// Style definition -- see link to css file ibid.
		local.settingsDef = ExpandPath("../styles/testStyles.xml");
		variables.settingsObj = new clikpage.settings.settings(debug=1);
		variables.contentObj = new clikpage.content.content(settingsObj=settingsObj);
		variables.contentObj.debug = 1;
		variables.site={};
		variables.image_sets = getImages(variables.site);

		variables.styles = settingsObj.loadStyleSettings(local.settingsDef);

		variables.cs = contentObj.new(id="testgrid",type="imagegrid");
		variables.cs.data = variables.image_sets;
		variables.cs.class = "scheme-grid";
		if (arguments.testname != "") {
			variables.cs.class = ListAppend(variables.cs.class, "scheme-#arguments.testname#", " ");
		}

		updateSettings({});

	}

	string function stylePath() {
		return expandPath("_generated/imagegrid.css");
	}

	string function updateSettings(required struct values, string medium="main") {
		for (local.setting in variables.contentObj.contentSections["imagegrid"].styleDefs) {
			if (structKeyExists(arguments.values, local.setting) AND arguments.values[local.setting] != "") {
				variables.styles.style[variables.cs.id][arguments.medium][local.setting] = arguments.values[local.setting];
			}
		}

		variables.contentObj.settings(content=variables.cs,styles=variables.styles.style,media=variables.styles.media);
	}

	string function css() {

		var css = ":root {\n";
		css &= variables.settingsObj.colorVariablesCSS(variables.styles);
		css &= variables.settingsObj.fontVariablesCSS(variables.styles);
		css &=  "\n}\n";
		css &= variables.settingsObj.CSSCommentHeader("Content styling");
		css &= contentCSS(variables.cs);
		css = variables.settingsObj.outputFormat(css=css,media=variables.styles.media,debug=variables.contentObj.debug);
		return css;
	}

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

	string function contentCSS(required struct cs) {
		local.site_data = { "#arguments.cs.id#" = arguments.cs};
		local.css = variables.contentObj.contentCSS(styles=variables.styles, content_sections=local.site_data, media=variables.styles.media, format=false);
		return local.css;
	}

	struct function pageData() {
		return variables.contentObj.display(content=variables.cs,data=variables.site.images);
	}

	string function settingsForm(required string media="main") {

		var retval = "";
		local.settings = variables.cs.settings[arguments.media];

		retval &= "<fieldset>";
		for (local.setting in variables.contentObj.contentSections["imagegrid"].styleDefs) {
			local.settingDef = variables.contentObj.contentSections["imagegrid"].styleDefs[local.setting];
			local.description = local.settingDef.description? : "No description";

			retval &= "<label title='#encodeForHTMLAttribute(local.description)#'>#local.settingDef.name#</label>";
			local.value = local.settings[local.setting] ? : "";
			
			switch(local.settingDef.type) {
				case "dimension":
				case "dimensionlist":
				case "text":
				case "integer":
					retval &= "<input name='#local.setting#' value='#local.value#'>";
					break;
				case "boolean":
				local.selected = isBoolean(local.value) AND local.value ? " selected": "";
					retval &= "<div class='field'><input type='checkbox' name='#local.setting#'#local.selected# value='1'>Yes</div>";
					break;
				case "list":
					local.options = variables.contentObj.options("imagegrid",local.setting);
					retval &= "<select name='#local.setting#'>";
					for (local.mode in local.options) {
						try {
							local.selected = local.mode.value eq local.value ? " selected": "";
							retval &= "<option value='#local.mode.value#' #local.selected# title='#encodeForHTMLAttribute(local.mode.description)#'>#encodeForHTML(local.mode.name)#</option>";
						}
						catch (any e) {
							local.extendedinfo = {"tagcontext"=e.tagcontext,mode=local.mode};
							throw(
								extendedinfo = SerializeJSON(local.extendedinfo),
								message      = "Error:" & e.message, 
								detail       = e.detail
							);
						}
					}
					retval &= "</select>";
					break;

			}
			
		}
		retval &= "</fieldset>";
		return retval;
	}
}