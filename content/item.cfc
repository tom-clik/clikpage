component extends="contentSection" {
	
	variables.type = "item";
	variables.title = "General content";
	variables.description = "HTML with optional title and text";
	variables.defaults = {
		"title"="Untitled",
		"content"="Undefined content",
	};
	
	function init(required content contentObj) {
		
		super.init(arguments.contentObj);

		variables.static_css = {"panels":1, "images":1};
		this.classes = "item clear";
		
		this.selectors = [
			{"name"="item", "selector"=""},
			{"name"="image", "selector"=" figure"},
			{"name"="title", "selector"=" .title"},
			{"name"="text", "selector"=" .textWrap"}
		];it

		this.panels = [
			{"name":"title","panel":"title","selector":" .title"},
			{"name":"image","panel":"image","selector":" figure"},
			{"name":"text","panel":"text","selector":" .textWrap"}
		];
		
		this.styleDefs = [
			"htop":{"title":"title position", "type":"list","options": [
				{"value":"1","name"="Title before image"},
				{"value":"0","name"="Title after image"}
				],
				"description":"Where to place the title in the item layout",
				"default"="false",
				"setting":1
			},
			"image-align":{"title":"Image alignment", "type":"halign","default":"center","setting":1},
			"wrap":{"title":"Wrap text", "type":"boolean","default":"0","setting":1},
			"item-gridgap":{"title":"Image margin", "type":"dimension","description":"Gap between image and text when aligned left or right. Use margins on the panels for other instances","default":"10px","setting":1},
			"image-width":{"title":"Image width", "type":"dimension","default":"40%"},
			"titletag":{"title":"", "type":"list","options": [
				{"value":"h1"},
				{"value":"h2"},
				{"value":"h3"},
				{"value":"h4"},
				{"value":"h5"},
				{"value":"h6"}
			],"default":"h3","hidden"=1},
			"show-title":{"title":"Show title", "type":"boolean","default"="1","setting":1},
			"show-image":{"title":"Show image", "type":"boolean","default"="1","setting":1},
			"imagespace":{"title":"Always show image space", "type":"boolean","default"="0","setting":1},
			"caption-display":{"title":"Show caption", "type":"displayblock","default"="none"}
		];

		updateDefaults();

		return this;
	}

	/** Create a new content section */
	public struct function new(required string id, string title, string content, string image, string caption, string link) {
		
		var cs =super.new(argumentCollection = arguments);

		if (StructKeyExists(arguments,"image")) {
			cs["image"] = arguments.image;
		}
		
		if (StructKeyExists(arguments,"caption")) {
			cs["caption"] = arguments.caption;
		}
		
		if (StructKeyExists(arguments,"link")) {
			cs["link"] = arguments.link;
		}

		return cs;
	}


	private string function css_settings(required string selector, required struct styles, required struct full_styles, boolean debug=true) {
		
		var css = [arguments.selector & " {"];
		var tab = arguments.debug ? "	": "";
		
		var settings = {};

		settings["grid-template-columns"] = "auto";

		css.append("/* htop: #arguments.full_styles.htop# */");
		
		if (! arguments.full_styles.htop) {
			settings["grid-template-areas"] = """imageWrap"" ""title"" ""textWrap""";
			settings["grid-template-rows"] = "min-content 1fr";
		}

		css.append("/* image-align: #arguments.full_styles["image-align"]# */");

		if (arguments.full_styles["image-align"] eq "left") {
			settings["grid-template-columns"] = " var(--image-width) auto";
			settings["grid-template-areas"] = """title title"" ""imageWrap  textWrap""";
		}
		else if (arguments.full_styles["image-align"] eq "right") { 
			settings["grid-template-columns"] = "auto var(--image-width)";
			settings["grid-template-areas"] = """title title"" ""textWrap imageWrap""";
		}
		
		if (! arguments.full_styles.htop && arguments.full_styles["image-align"]  eq "left") {
			settings["grid-template-areas"] = """imageWrap title"" ""imageWrap textWrap""";
		}
		else if (! arguments.full_styles.htop && arguments.full_styles["image-align"]  eq "right") {
			settings["grid-template-areas"] = """title imageWrap"" ""textWrap imageWrap""";
		}

		css.append("/* show-title: #arguments.full_styles["show-title"]# */");

		if ( ( ! arguments.full_styles["show-title"] ) && arguments.full_styles["image-align"] eq "right") {
			settings["grid-template-areas"] = """textWrap imageWrap""";
		}
		else if ( ( ! arguments.full_styles["show-title"] ) && arguments.full_styles["image-align"] eq "right") {
			settings["grid-template-areas"] = """imageWrap textWrap """;
		}

		css.append("/* show-image: #arguments.full_styles["show-image"]# */");
		if (! arguments.full_styles["show-image"] ) {
			settings["grid-template-areas"] = """title"" ""textWrap """;
			settings["grid-template-columns"] = "1fr";
			settings["grid-template-rows"] = "min-content auto";
		}
		
		for (setting in ["grid-template-areas","grid-template-columns","grid-template-rows"] ) {
			if (settings.keyExists(setting)) {
				css.append(setting & ":" & settings[setting] & ";");
			}
		}

		css.append("}");

		/* noimage class needs to be applied to item if there is no image. This is for removing
		the space in a list of items with the same class */

		// if (! arguments.full_styles["imagespace"] ) {
		// 	.item.noimage.imagespace-0, .list.imagespace-0 .item.noimage {
		// 		grid-template-areas:  "title" "textWrap";
		// 		grid-template-rows: min-content auto;
		// 		grid-template-columns:   1fr;
		// 	}
		// }

		css.append(arguments.selector & " .title {");
		css.append("#tab#display:" & ( arguments.full_styles["show-title"] ? "block": "none" ) & ";");
		css.append("}");
	

		css.append(arguments.selector & " .imageWrap {");
		css.append("#tab#display:" & ( arguments.full_styles["show-image"] ? "block": "none" ) & ";");
		css.append("}");
		
		// TODO: apply clearing to all items and then remove this commented code

		// .item.wrap-1:after, .list.wrap-1 .item:after {
		//   content: " ";
		//   display: block;
		//   height: 0;
		//   clear: both;
		//   visibility: hidden;
		//   overflow: hidden;
		// }

		// TODO: resurrect this

		// .item.wrap-1 .imageWrap, .list.wrap-1 .item .imageWrap {
		// 	width: var(--image-width);
		// }

		// .item.noimage.wrap-1 .imageWrap, .list.wrap-1 .item.noimage .imageWrap {
		// 	display: none;
		// }

		// .item.wrap-1["image-align"] -left .imageWrap, .list.wrap-1["image-align"] -left .item .imageWrap {
		// 	float: left;
		// 	margin-right: var(--item-gridgap);
		// 	margin-bottom: var(--item-gridgap);
		// }

		// .item.wrap-1["image-align"] -right .imageWrap, .list.wrap-1["image-align"] -right .item .imageWrap {
		// 	float: right;
		// 	margin-left: var(--item-gridgap);
		// 	margin-bottom: var(--item-gridgap);
		// }

		// DON'T DO FOR NOW
		
		// .item.wrap-1.htop-0 > h3, .list.wrap-1.htop-0 .item > h3  {
		// 	display: none;
		// }

		// .item.wrap-1.htop-0 .wraptitle, .list.wrap-1.htop-0 .item .wraptitle {
		// 	display: block;
		// }
			
		
		css.append("");

		return css.toList(arguments.debug ? newLine() : "");
	
	}



	
	public string function html(required struct content) {
		
		var classes = {};
		
		arguments.content.class = ListAppend(arguments.content.class, "item"," ");
		arguments.content.description = arguments.content.content;
		local.link = arguments.content.link ? : "";
		var cshtml = variables.contentObj.itemHtml(item=arguments.content, link=local.link, settings = arguments.content.settings.main, classes=classes);
		
		return cshtml;

	}

	
}