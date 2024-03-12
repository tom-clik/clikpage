/*

Allow sort of table columns, adjustment of widths and removal of columns by dragging
headers.

## Synopsis

First create data objects to hold the html of the cells.

We name each column according to the first class of the th. If there is no class we make one e.g. column1. The order is an array of these classes. It can be changed by dragging the cells. Rows can be removed from the order by dragging the header out of the table.

The we create arrays FOR EACH column: remember we want to move the columns around.

columns[columnname] = [];

### Re-ordering

When we drag the table headers, on "drop" we rebuild the table according the new order.

### Removing field

A table header dropped outside the thead removes it from the list

### Resizing

After rendering the table, we add "handles" positioned absolutely on top of the column edges. These are "draggable" and used to adjust the widths. 

### Flex width columns. 

Columns assigned a class of `flex` will expand if needed. Others will have a width fixed.

Note columns are assigned a set pixel width. Using percentages doesn't work well. It generally works best with one column set to be flexible.

*/
(function($) {

	// here we go!
	$.adjustableTable = function(element, options) {

		var defaults = {
			remove: true,// allow column removal
			resize: "resize", // window event to trigger resize. use e.g. throttledresize
			onUpdate: function() {}
		}

		var plugin = this;

		plugin.settings = {};

		var $element = $(element), // reference to the jQuery version of DOM element
			element = element, // reference to the actual DOM element
			$thead,
			columnData = {},
			columnNodes = {},
			columnOrder = [],
			widths = {},
			oldwidths = {},
			tablewidth,
			tableOffset,
			mode = "drag",// resize||drag
			mousedown = false,
			column,
			rowcount;

		plugin.init = function() {

			plugin.settings = $.extend({}, defaults, options);
			$thead = $element.find("thead");
			tablewidth = $element.width();
			tableOffset = $element.offset();
			
			getData();
			// Add resize handles to right of each column (not 0)
			addHandles();

			console.log(columnData);
			console.log(columnOrder);
			console.log(widths);

			render();

			// console.log(widths);
			
			// $thead.on("mousemove",function(e) {
			// 	e.stopPropagation();
			// 	var mouseX = e.pageX - tableOffset.left;
			// 	if (mousedown) {
			// 		if (mode == "drag") {
			// 			console.log("moving");
			// 		}
			// 		else {
			// 			let w = oldwidths[column];
			// 			let offset = oldwidths.slice(0,column + 1).reduce((a, b) => a + b, 0);
			// 			let d = mouseX - offset;
			// 			if (mode = "resize") {
			// 				widths[column] += d;
			// 				widths[column + 1] -= d;
			// 			}
			// 			console.log(widths);
			// 			resize();
			// 		}
			// 	}
			// 	else {
			// 		let cursor = "move";
			// 		mode="drag";
			// 		column = 0;
			// 		let offset = 0;
			// 		for (let count=0; count < oldwidths.length; count++ ) {
			// 			let w = oldwidths[count] + offset;
			// 			offset += oldwidths[count];

			// 			let d = Math.abs(mouseX - w);
			// 			if ( d < 12 ) {
			// 				column = count;
			// 				cursor = "col-resize";
			// 				mode="resize";
			// 				break;
			// 			}
			// 			else if ( mouseX > w ) {
			// 				column = count;
			// 			}
			// 		}
			// 		console.log(cursor,"-",column);
			// 		$thead.css("cursor", cursor);
			// 	}
			// });

			// $thead.on("mousedown", function(e) {
			// 	e.stopPropagation();
			//     mousedown = true;
			// }).on("mouseup", function(e) {
			// 	e.stopPropagation();
			// 	console.log("Mouseup");
			// 	oldwidths = widths;
			//     mousedown = false;  
			// }).on("mouseleave", function(e) {
			// 	e.stopPropagation();
			// 	if (mode = "resize") {
			// 		console.log("Mouseout",$(this).prop("tagName"));
			// 		mousedown = false; 
			// 		mode = "move";
			// 		widths = oldwidths;
			// 		resize();
			// 	}
			// });

			
		}
		
		$(window).on(plugin.settings.resize,function() {
				$element.trigger("resize");
			});
		
		$element.on("resize",function(e) {
			e.stopPropagation();
			getCssSettings();
			let $tab = $element.find(".state_open").first();
			setHeight($tab);
		});

		// Add the cell data to column arrays.
		getData = function() {
			var count = 1;
			$thead.find("th").each(function() {
				let $cell = $(this);

				let className = $cell.attr("class");
				let flex = false;
				if (className == undefined) {
					var sclass = "column" + count;
					$cell.attr("class",sclass);
				}
				else {
					let classes = className.split(/\s+/);
					var sclass = classes[0];
					if ( $cell.hasClass("flex") ) {
						flex = true;
					}
				}
				count++;
				columnNodes[sclass] = $cell;
				columnOrder.push(sclass);
				widths[sclass] = (flex ? "auto" : $cell.outerWidth());
			
			});
			
			for (let column of columnOrder) {
				columnData[column] = [];
			}
			rowcount = 0;
			var rows = $element.find("tr").each(function(index, element){
				var $row = $(this);
				var rownum = index;
				$row.find("td,th").each(function(sindex, selement){
					let col = columnOrder[sindex];
					columnData[col].push($(this).html());
				});
				rowcount++;
			});
			
			oldwidths = widths;

		}
		resize = function() {
			console.log(widths);
			for (let count=0; count < widths.length; count++ ) {
				let width = widths[count] ;
				columns[count].css("width",width + "px");
			}
		}

		update = function() {
			plugin.settings.onUpdate();
		}

		render = function() {
			var html = "<thead><tr>";
			for (let column of columnOrder) {
				html += `<th>${columnData[column][0]}</th>`;
			}
			html += "</tr></thead><tbody>";
			for (let row = 1; row < rowcount; row++ ) {
				html += "<tr>";
				for (let column of columnOrder) {
					html += `<td>${columnData[column][row]}</td>`;
				}
				html += "</tr>";				
			}
			html += "</tbody>";
			$element.html(html);
		}

		plugin.init();

	}

	// add the plugin to the jQuery.fn object
	$.fn.adjustableTable = function(options) {

		return this.each(function() {

		  if (undefined == $(this).data('adjustableTable')) {

			  var plugin = new $.adjustableTable(this, options);

			  $(this).data('adjustableTable', plugin);

		   }

		});

	}

})(jQuery);