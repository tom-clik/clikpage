component extends="item" {

	variables.type = "articlelist";
	variables.title = "Article list";
	variables.description = "List of content items";
	variables.defaults = {
		"title"="Untitled",
		"content"="Undefined content",
	};
	
	function init(required content contentObj) {
		
		super.init(arguments.contentObj);
		
		variables.static_css = {"flickity":1,"items":1,"grids":1};
		variables.static_js = {"flickity":1,"photogrid"=1,};
		
		this.classes = "list grid";

		this.selectors = [
			{"name"="item", "selector"=" .item"},
			{"name"="image", "selector"=" .imageWrap"},
			{"name"="title", "selector"=" .title"},
			{"name"="text", "selector"=" .textWrap"}
		];

		StructAppend(this.styleDefs, {
			"layout": {
				"name":"Layout type","description":"","type":"list","options":[
					{"name":"Standard","description":"Standard grid","value":"standard"},
					{"name":"Carousel","description":"A horizontal scrolling panel","value":"carousel"}
				],
				"default":"standard","setting":1
			},
			"inline" = {"type":"boolean","description":"Display full text of article inline","default"=0}, 
			"carousel" = {"type":"boolean","description":"use carousel for list","default"=0},
			"contain" = {"type":"boolean","description":"contain carousel content","default"=1},
			"freeScroll" = {"type":"boolean","description":"Free scroll","default"=0},
			"wrapAround" = {"type":"boolean","description":"Wrap around carousel scroll","default"=1},
		});
		
		updateDefaults();
		
		this.panels.prepend({"name":"Item","panel":"item","selector":" .item"});

		return this;

	}

	public string function html(required struct content,required struct data) {
		
		var cshtml = "<div class='gridInner'>";
		var classes = {};

		local.textfield = "description";
		local.inline = 0;
		if ( arguments.content.style.main.keyExists("inline") && arguments.content.style.main.inline ) {
			local.textfield = "body";
			local.inline = 1;
		}
		
		local.link_format = arguments.content.link ? : ( local.inline ? "" : "{{link.{{section.id}}.view.{{data.id}}}}" );
		
		for (local.id in arguments.content.data) {
			local.item = arguments.data[local.id];
			classes = {};
			local.link = Replace(local.link_format, "{{data.id}}", local.id);
			local.tmpHTML = variables.contentObj.itemHtml(item=local.item,link=local.link,textfield=local.textfield);
			cshtml &= "<div class='item'>";
			cshtml &= local.tmpHTML;
			cshtml &= "</div>";
		}

		cshtml &= "</div>";

		return cshtml;

	}

	private string function css_settings(required string selector, required struct styles, required struct full_styles, boolean debug=true) {

		return super.css_settings(selector=arguments.selector & " .item",styles=arguments.styles,full_styles=arguments.full_styles,debug=arguments.debug);
	
	}

	public string function onready(required struct content) {
		var js = "";

		// TODO: replace with ClikOnReady functionality
		// 
		// if (arguments.content.settings.main.carousel) {
		// 	js = ["$carousel = $('###arguments.content.id# .list');"]
		// 	.append("$carousel.flickity({")
		//   	.append("  // options")
		//   	.append("  contain: true,")
		//   	.append("  freeScroll: false,")
		//   	.append("  wrapAround: true")
		// 	.append("});").toList(newLine());
		// }

		return js;
	}

	public string function onready(
		required struct content, 
		required struct pageContent,
		required struct data) {

		var js = "$#arguments.content.id# = $('###arguments.content.id#');\n";
		js &= "$#arguments.content.id#.photoGrid({});\n";
		return js;

	}

		
		
	
}
