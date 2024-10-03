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
			$container,// wrap ement in this to add e.g. drad handles
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
			$element.wrap("<div class='container' style='position:relative'></div>");
			$container = $element.parent();
			$thead = $element.find("thead");
			tablewidth = $element.width();
			tableOffset = $element.offset();
			
			getData();
			
			addHandles();
			_setSortable();

			$container.on("mousemove",".dragHandle",function(e) {
				if (mousedown) {
					var mouseX = e.pageX - tableOffset.left;
					var $handle = $(this);
					var col = $handle.data("col");
					var offset = 0;
					var pos = columnOrder.indexOf(col);

					for (let i of columnOrder.slice(0,pos)) {
						offset += widths[i];
					}

					var d = offset + widths[col] - mouseX;
					console.log(d);

					widths[col] -= d;
					widths[columnOrder[pos+1]] += d;

					$handle.css("left",mouseX - 6 + "px");
					setSizes();
				}
			});
			
			$container.on("mousedown","thead,.dragHandle", function(e) {
				e.stopPropagation();
			    mousedown = true;
			}).on("mouseup", function(e) {
				e.stopPropagation();
			});

			$thead.on("mousedown","i", function(e) {
				e.stopPropagation();
			});

		}
		
		$(window).on(plugin.settings.resize,function() {
			$element.trigger("resize");
		});
		
		$element.on("resize",function(e) {
			e.stopPropagation();
			addHandles();
		});

		// Add the cell data to column arrays and get initial widths
		getData = function() {
			var count = 1;
			$thead.find("th").each(function() {
				var $cell = $(this);
				var sclass;
				const className = $cell.attr("class");
				var flex = false;
				if (className == undefined) {
					sclass = "column" + count;
					$cell.attr("class",sclass);
				}
				else {
					let classes = className.split(/\s+/);
					sclass = classes[0];
					if ( $cell.hasClass("flex") ) {
						flex = true;
					}
				}
				count++;
				columnNodes[sclass] = $cell;
				columnOrder.push(sclass);
				$cell.data("column", sclass);
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
		}

		// create table element with data in correct order
		render = function(bodyOnly) {
			bodyOnly = bodyOnly || false;
			var html = "";
			
			for (let row = 1; row < rowcount; row++ ) {
				html += "<tr>";
				for (let column of columnOrder) {
					html += `<td>${columnData[column][row]}</td>`;
				}
				html += "</tr>";				
			}

			if (! bodyOnly) {
				let header = "<thead><tr>";
				for (let column of columnOrder) {
					header += `<th><div class='moveHandle'>${columnData[column][0]}</div></th>`;
				}
				header += "</tr></thead>";

				html = header + "<tbody>" + html + "</tbody>";

				$element.html(html);
				$thead = $element.find("$thead");
				_setSortable();
			}
			else {
				$element.find("tbody").html(html);
			}
		}
		_setSortable = function() {
			$thead.find("tr").sortable({
				cursor: "move",
				containment: "parent",
				cancel: "i",
				axis: "x",
				update: function( event, ui ) {
					columnOrder = [];
					$thead.find("th").each( function( index ) {
						let column = $(this).data("column");
						// careful. ui clone will be in there.
						if (column != undefined) {
							columnOrder.push(column);
						}
					});
					render(true);
					addHandles();
				}
			});
		}

		// add coumn resize handles position absolutely in th
		addHandles = function() {
			let offset = 0;
			$container.find(".dragHandle").remove();
			let order = columnOrder.slice(0,-1);
			for (let column of order) {
				offset += widths[column];
				$(`<div class='dragHandle' data-col='${column}'></div>`).appendTo($container).css({position:"absolute",top:0,left:`${offset - 12}px`,width:"24px",height:"20px",cursor:"col-resize","z-index":1000});
			}
		}
		
		setSizes = function() {
			for (let col in widths) {
				console.log(columnNodes[col].html());
				columnNodes[col].css({"width":widths[col] + "px"});
			}
		}

		update = function() {
			plugin.settings.onUpdate();
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