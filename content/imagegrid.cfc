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
		
		this.classes = ListAppend(this.classes, "cs-grid", " ");	

		variables.static_css = {"images"=1,"flickity"=1,"grids"=1,"justifiedGallery"=1};
		variables.static_js = {"masonry"=1,"popup"=1,"flickity"=1,"photogrid"=1,"getSettings"=1,"justifiedGallery"=1};
		
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

		StructDelete(this.styleDefs,"justify-content");
		StructDelete(this.styleDefs,"align-items");

		StructAppend(this.styleDefs, [
			"layout": {
				"name":"Layout type","description":"","type":"list","options":[
					{"name":"Standard","description":"Standard grid","value":"standard"},
					{"name":"Masonry","description":"Arrange images in a best fit alignment according to their height","value":"masonry"},
					{"name":"Carousel","description":"A horizontal scrolling panel","value":"carousel"},
					{"name":"Justified Gallery","description":"Justify images horizontally","value":"justifiedGallery"}
				],
				"default":"standard","setting":1
			},
			"popup" : {"name":"Popup","description":"Link to pop up image","type":"boolean","default":0,"setting":1},
			"grid-max-height": {"name":"Max image height","description":"","type":"dimension","setting":1},
			"caption-position": {
				"name":"Caption position","description":"","type":"list","options":[
					{"name":"Top","description":"","value":"top"},
					{"name":"Bottom","description":"","value":"bottom"},
					{"name":"Above","description":"","value":"above"},
					{"name":"Under","description":"","value":"under"},
					{"name":"Overlay","description":"","value":"overlay"}
				],
				"default":"bottom","setting":1
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
			},
			"subcaptions" : {"name":"Subcaption","description":"Add sub caption to html. This will be deprecated in favour of a caption template system","type":"boolean","default":0},
			"contain" : {"name":"Contain","type":"boolean","default":false,"dependson":"layout","dependvalue":"carousel"},
			"freeScroll" : {"name":"Free Scroll","type":"boolean","default":true,"dependson":"layout","dependvalue":"carousel"},
			"wrapAround" : {"name":"Wrap Around","type":"boolean","default":true,"dependson":"layout","dependvalue":"carousel"},
			"pageDots" : {"name":"Page Dots","type":"boolean","default":false,"dependson":"layout","dependvalue":"carousel"},
			"prevNextButtons" : {"name":"Previous Next Buttons","type":"boolean","default":true,"dependson":"layout","dependvalue":"carousel"},
			"rowHeight" : {"name":"Row height","type":"dimension","description":"Only for justified gallery layout mode"}

		]);
		
		removeOptions("grid-mode","templateareas,flex");

		updateDefaults();

		return this;
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

		local.html = "<div class='grid'>";

		for (local.id in arguments.content.data) {
			local.image = arguments.data[local.id];
			
			// TODO: this is all a mess
			// 1. specify image type e.g. thumbnail
			// 2. Popups proper target for open
			// 3. Link types: none, gallery etc
			if ( StructKeyExists( arguments.content, "link" )) {
				// TODO: link for section detail page 
				// local.link = " href='{{link.{{section.id}}.view.#local.id#}}'";
				local.link = " href='" & Replace(arguments.content.link, "{{data.id}}",local.id,"all") & "'" ;
			}
			else {
				local.link = local.image.image;
				
			}
			
			local.html &= "<a class='frame'#local.link#>";
			
			local.image_src = local.image.image_thumb ? : local.image.image;
			
			local.html &= "<div class='image'><img src='#local.image_src#'></div>";

			if (local.image.title NEQ "") {
				local.html &= "<div class='caption'>#local.image.title#";
				if (local.image.description NEQ "") {
					local.html &= "<div class='subcaption'>#local.image.description#</div>";
				}
				local.html &= "</div>";
			}
			
			local.html &= "</a>";

		}

		local.html &= "</div>";

		if (arguments.content.popup ? : false) {
			local.html &= variables.contentObj.popupHTML("#arguments.content.id#_popUp");
		}

		return local.html;
		
	}
	/* TODO: remove once new plug in is working */
	public string function onready(
		required struct content, 
		required struct pageContent,
		required struct data) {

		var js = "$#arguments.content.id# = $('###arguments.content.id#');\n";
		js &= "$#arguments.content.id#.photoGrid({dataset:#serializeJSON(arguments.content.data)#});\n";
		return js;

	}
	/* TODO: remove once new plug in is working */
	public string function onreadyOLD(
		required struct content, 
		required struct pageContent,
		required struct data) {

		if (arguments.content.settings.main.layout eq "masonry") {
			js &= "$#arguments.content.id#Grid = $('###arguments.content.id#').isotope({\n";
			js &= "\t/* options*/\n";
			// js &= "\titemSelector: 'figure',\n";
			js &= "layoutMode: 'masonry',\n";
			js &= "itemSelector: '.frame',\n";
			js &= "masonry: {\n";
			js &= "	columnWidth: '###arguments.content.id# .frame'";
			if (StructKeyExists(arguments.content.settings.main,"grid-gap")) {
				js &= ",\n\tgutter: " & Val(arguments.content.settings.main["grid-gap"]);
			}
			js &= "\n\t},\n";
			js &= "});\n";
			js &= "/* layout Masonry after images loaded */\n";
			js &= "$#arguments.content.id#Grid.imagesLoaded( function() {\n";
			js &= "\t$#arguments.content.id#Grid.isotope();\n";
			js &= "});\n";
		}
		else if (arguments.content.settings.main.layout eq "carousel") {
			local.elem = "$carousel_#arguments.content.id#";
			js &= "#local.elem# = $('###arguments.content.id#');\n";
			js &= "#local.elem#.flickity({\n";
			js &= "    contain: #arguments.content.settings.main.contain#,\n";
			js &= "	   freeScroll: #arguments.content.settings.main.freeScroll#,\n";
			js &= "	   wrapAround: #arguments.content.settings.main.wrapAround#,\n";
			js &= "	   pageDots: #arguments.content.settings.main.pageDots#,\n";
			js &= "	   prevNextButtons: #arguments.content.settings.main.prevNextButtons#\n";
			js &= "	 }).on( 'change.flickity', function( event, index ) {\n";
			js &= "	  console.log( 'Slide changed to ' + index );\n";
			js &= "	  var cellElements = #local.elem#.flickity('getCellElements')\n";
			js &= "	}).on( 'staticClick.flickity', function( event, pointer,cellElement, cellIndex ) {\n";
			js &= "	  // dismiss if cell was not clicked\n";
			js &= "	  if ( !cellElement ) {\n";
			js &= "	    return;\n";
			js &= "	  }\n";
			js &= "	  #local.elem#.flickity(""select"", cellIndex,true);\n";
			js &= "	});\n";
		}

		if (arguments.content.settings.main.popup) {
			js &= "$('###arguments.content.id#_popUp').popup({\n";
			js &= "	imagepath : '',\n";
			js &= "	data:#Replace(SerializeJSON(getData(cs_data=arguments.content.data, data=arguments.data ) ),"\n","","all")#,\n";
			js &= "});\n";
			js &= "$popup = $('###arguments.content.id#_popUp').data('popup');\n";
			js &= "count = 0;\n";
			js &= "$('###arguments.content.id# a').each(function() {\n";
			js &= "	$(this).data('index', count++);\n";
			js &= "})\n";
			js &= "$('###arguments.content.id# > a').on('click',function(e) {\n";
			js &= "	console.log('clicked');";
			js &= "	e.preventDefault();\n";
			js &= "	e.stopPropagation();\n";
			js &= "	$popup.goTo($(this).data('index'));\n";
			js &= "	$popup.open();\n";
			js &= "});\n";
		}
		
		return js;
	}

	// the pass data by reference thing isn't working for the popups
	// we need to somehow extend this client side possibly with options
	// for lazy load.
	// In the meantime, for a popup, create an array of data to
	// supply to the js plug in.
	private array function getData(required array cs_data, required struct data) {
		local.dataRet = [];
		for (local.id in arguments.cs_data) {
			ArrayAppend(local.dataRet, arguments.data[local.id]);
		}
		return local.dataRet;
	}
	
}