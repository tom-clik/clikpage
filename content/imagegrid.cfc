component extends="grid" {

	variables.type = "imagegrid";
	variables.title = "Image grid";
	variables.description = "Images in grid";
	variables.defaults = {
		"title"="Untitled",
		"content"="Undefined content",
	};

	function init(required content contentObj) {
		
		super.init(arguments.contentObj);
		
		variables.static_css = {"images"=1,"jbox"=1};
		variables.static_js = {"masonry"=1,"jbox"=1};
		
		this.selectors = [
			{"name"="main", "selector"=""},
			{"name"="item", "selector"=" .frame"},
			{"name"="image", "selector"=" .image"},
			{"name"="caption", "selector"=" .caption"}			
		];

		this.panels = [
			{"name":"Item","panel":"item","selector":" .frame"},
			{"name":"Caption","panel":"caption","selector":" .caption"},
			{"name"="image","panel":"image", "selector"=" .image"},
			{"name"="subcaption","panel":"subcaption", "selector"=" .subcaption"}
		];

		StructAppend(this.styleDefs, [
			"masonry" : {"name":"Masonry","description":"","type":"boolean","default":0},
			"popup" : {"name":"Popup","description":"","type":"boolean","default":0},
			"image-max-height": {"name":"Max image height","description":"","type":"dimension"},
			"caption-position": {
				"name":"Caption position","description":"","type":"list","options":[
					{"name":"Top","description":"","value":"top"},
					{"name":"Bottom","description":"","value":"bottom"},
					{"name":"Above","description":"","value":"above"},
					{"name":"Under","description":"","value":"under"},
					{"name":"Overlay","description":"","value":"overlay"}
				],
				"default":"bottom"
			},
			"align-frame": {
				"name":"Image Align (horzontal)","default":"middle","description":"","type":"list","options":[
					{"name":"Left","description":"","value":"start"},
					{"name":"Center","description":"","value":"center"},
					{"name":"Right","description":"","value":"end"}
				]
			},
			"justify-frame": {
				"name":"Image Align (vertical)","default":"start","description":"","type":"list","options":[
					{"name":"Top","description":"","value":"start"},
					{"name":"Center","description":"","value":"center"},
					{"name":"Bottom","description":"","value":"end"}
				]
			},
			"object-fit": {
				"name":"Image fit","default":"scale-down","description":"","type":"list","options":[
					{"name":"Crop","description":"","value":"cover"},
					{"name":"Shrink","description":"","value":"scale-down"},
					{"name":"Stretch","description":"","value":"fill"}
				]
			}
		]);

		StructAppend(this.settings, {
			"masonry" :0,
			"popup" : 0,
			"caption-position": "top",
			"justify-frame":"top"
		});

		return this;
	}

	private string function css_settings(required string selector, required struct styles) {
		
		var data = getSelectorStruct();
		
		if (arguments.styles.masonry) {
			data.main &= "\tdisplay:block;\n";
			data.item &= "\twidth:var(--grid-width);\n";
		}
		else {
			// image positions require some quite funny logic
			// if caption is top or bottom, we need automargin on the image
			// to fill the space if the image is top or bottom.
			

			local.imagegrow = 0;
			switch(arguments.styles["caption-position"]){
				case "top":
				case "bottom":
					local.imagegrow = (arguments.styles["justify-frame"] eq "center");
					if (! local.imagegrow) {
						if (arguments.styles["caption-position"] eq "top"){
							data.image &= "/* caption at the top. */\n";
							if (arguments.styles["justify-frame"] eq "end") {
								data.image &= "\tmargin-top:auto;\n\tmargin-bottom:0;";
							}
						}
						else {
							data.image &= "/* caption at the bottom. */\n";
							// caption at the bottom.
							if (arguments.styles["justify-frame"] eq "start") {
								data.image &= "\tmargin-top:0;\n\tmargin-bottom:auto;";
							}
						}
					}
					local.reverse = arguments.styles["caption-position"] eq "top" ? "-reverse" : "";
					data.main &= "\t--frame-flex-direction:column" & (local.reverse) & ";\n";
					data.main &= "\t--image-grow:#(local.imagegrow ? 1 : 0)#;\n";
					
					break;
				
				case "under":
				case "above":
					local.reverse = arguments.styles["caption-position"] eq "above" ? "-reverse" : "";
					data.main &= "\t--frame-flex-direction:column#local.reverse#;\n";
					data.image &= "\tmargin:0;";
					data.main &= "\t--image-grow:0";
					break;
				case "overlay":
					data.main &= "--justify-frame:start;\n";
					data.main &= "--justify-caption:center;\n";
					data.caption &= "position: absolute;\n";
					data.caption &= "top:0;";
					data.caption &= "left:0;";
					data.caption &= "width: 100%;";
					data.caption &= "height: 100%;";
					data.caption &= "opacity: 0;";
					break;
			}

			

			local.gridstyles = {};
			variables.contentObj.settingsObj.grid(arguments.styles,local.gridstyles);
			for (local.item in local.gridstyles) {
				data[local.item] &= local.gridstyles[local.item];
			}
		}

		return selectorQualifiedCSS(selector=arguments.selector, css_data=data);

	}
	

	public string function html(required struct content,required struct data) {
		
		if (! StructKeyExists(arguments.content,"data")) {
			local.extendedinfo = {"content"=arguments.content};
			throw(
				extendedinfo = SerializeJSON(local.extendedinfo),
				message      = "No data defined for content section",
				errorcode    = "content.imagegrid.1"		
			);
		}

		local.html = "";

		for (local.id in arguments.content.data) {
			local.image = arguments.data[local.id];
			
			// TODO: this is all a mess
			// 1. specify image type e.g. thumbnail
			// 2. Popups proper target for open
			// 3. Link types: none, gallery etc
			local.link = "";
			if (arguments.content.settings.main.popup) {
				local.link = " href='" & ( arguments.content.link ? : local.image.image ) & "'";
			}
			else {
				local.link = " href='{link.{section.id}.view.#local.id#}'";
			}

			local.html &= "<a class='frame'#local.link#>";
			
			local.image_src = local.image.image_thumb ? : local.image.image;
			
			local.html &= "<img src='#local.image_src#'>";

			if (local.image.title NEQ "") {
				local.html &= "<div class='caption'>#local.image.title#</div>";
			}
			
			local.html &= "</a>";

		}		
		

		return local.html;
		
	}

	public string function onready(required struct content) {

		var js = "";

		if (arguments.content.settings.main.masonry) {
			js &= "$#arguments.content.id#Grid = $('###arguments.content.id#').masonry({\n";
			js &= "\t/* options*/\n";
			// js &= "\titemSelector: 'figure',\n";
			js &= "\tcolumnWidth: '###arguments.content.id# figure',\n";
			js &= "\tinitLayout: false,\n";
			js &= "\tpercentPosition: true\n";
			if (StructKeyExists(arguments.content.settings.main,"gridgap")) {
				js &= "\tgutter: #Val(arguments.content.settings.main.gridgap)#\n";
			}
			js &= "});\n";

			js &= "/* layout Masonry after each image loads*/\n";
			// js &= "$#arguments.content.id#Grid.imagesLoaded().progress( function() {\n";
			js &= "$#arguments.content.id#Grid.imagesLoaded( function() {\n";
			js &= "\t$#arguments.content.id#Grid.masonry('layout');\n";
			js &= "});\n";
		}

		// if (arguments.content.settings.main.popup) {

		// 	js &= "new jBox('Image');";
		// }
		
		return js;
	}
	
}