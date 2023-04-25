
/**
 * @fileOverview JavaScript required for Article Manager
 *
 * @author  Thomas Peer
 * @author  Michael Thomas
 * 
 * @copyright Copyright 2003 Digital Method Ltd.
 * support@digitalmethod.co.uk
 * 
 * This program is distributed under the terms of the GNU General Public License
 * 
 * @module  articleManager
 */


/**
 * Various jQuery extensions
 * @namespace $
 * @memberOf module:articleManager
 */
/**
 * jQuery Plugin namespace
 * @namespace $.fn
 * @memberOf module:articleManager
 */

/**
 * Provide a field to search a list by primary key.
 * @memberOf module:articleManager.$.fn
 * @deprecated No longer in use by AM4.1
 * @return {jQuery}
 */
$.fn.quickFind = function(){
	return this.each(function(){
		$(this).find('th[data-field]').each(function(){
			var th = $(this), open = false;
			th.append('<span class="quickFind ui-icon ui-icon-search"></span>')
				.bind('click',function(){
					if (!open) {
						open = true;
						var form = $('<form action="' + location.href.replace('_list.cfm','_edit.cfm') + '"/>')
							.appendTo('body')
							.append('<input type="hidden" name="action" value="search">')
							.append('<input type="hidden" name="search_mode" value="replace">')
							.append('<input type="text" name="' + th.data('field') + '">')
							.append('<input type="hidden" name="' + (th.data('field_full') || th.data('field')) + '_search" value="=">')
							.wrap('<div class="quickFindForm"/>')
							.parent()
							.position({
								my: 'left top',
								at: 'left bottom',
								of: th
							});
						
						form.find('input[type=text]').focus();
						
						$('body').bind('click.quickFind', function(e){
							var target = $(e.target);
							if (!target.is('.quickFind') && !target.closest('div').is('.quickFindForm')) {
								form.remove();
								open = false;
								$('body').unbind('click.quickFind');
							}
						});
					}
				});
		});
	});
};


/**
 * Add check/uncheck all functionality, plus shift-based multiple selection of slaves
 * @memberOf module:articleManager.$.fn
 */
$.fn.checkBoxGroups = function(){
	return this.each(function(){
		var master = $(this), groupID = clik.getPrefixedClass(this.className,"checkBoxMaster_"),
			slaves = $(this.form).children().find(':checkbox.checkBoxSlave_'+groupID),
			first = false, last = false,
			setFirst = function(el){
				if (el.attr('checked')) {
					first = el;
					last = false;
				} else {
					first = false;
				}
			},
			setMaster = function(){
				var checked = slaves.getSum(function(){return $(this).attr('checked');});
				master.attr('checked',checked>0);
				master.attr('indeterminate',checked>0&&checked<slaves.length);
			};
		setMaster();
		master.bind('change', function(){
			var c = $(this).attr('checked'),
				vs = slaves.filter(':visible');
			if( c ) {
				vs.attr('checked',true).trigger('change');
				vs.parent().addClass('checked');
			} else {
				vs.attr('checked',false).trigger('change');
				vs.parent().removeClass('checked');
			}
		});
		slaves.bind('click', function(e){
			var $this = $(this), firstI = slaves.index(first), thisI = slaves.index($this), lastI = slaves.index(last);
			if (first && first.length) {
				if (e.shiftKey) {
					if (last.length) {
						if (firstI < thisI && thisI < lastI) {
							slaves.slice(thisI,lastI+1).attr('checked',0).trigger('change')
							.parent().removeClass('checked');
						} else if (lastI < thisI && thisI < firstI) {
							slaves.slice(lastI,thisI+1).attr('checked',0).trigger('change')
							.parent().removeClass('checked');
						} else if (thisI < firstI && firstI < lastI) {
							slaves.slice(thisI, firstI+1).attr('checked',0).trigger('change')
							.parent().removeClass('checked');
							first = last;
						} else if (lastI < firstI && firstI < thisI) {
							slaves.slice(thisI, lastI+1).attr('checked',0).trigger('change')
							.parent().removeClass('checked');
							first = last;
						}
					}
					slaves.slice(Math.min(firstI,thisI),Math.max(firstI,thisI)+1).attr('checked',1).trigger('change')
					.parent().addClass('checked');
					last = $this;
				} else {
					setFirst($this);
				}
			} else {
				setFirst($this);
			}
			setMaster();
		});
	});
};
$(function(){
	$('.checkBoxMaster').checkBoxGroups();
});

/**
 * Collapse a field and add a button to expand/collapse it.
 * this function is also duplicated in am_preview.js
 * @memberOf module:articleManager.$.fn
 */
$.fn.fieldCollapse = function(){
	return $(this).unbind('click.fieldCollapse').bind('click.fieldCollapse', function(){
		$(this).find('.ui-icon').toggleClass('ui-icon-plus ui-icon-minus').end()
			.next('.fieldCollapsed').toggle()
			// a bit of a pain, but we need to re-init chosen ...
			.find('select[multiple]').chosen('destroy').chosen();
		return false;
	}).each(function(){
		var $this = $(this);
		$this.button({icons:{primary:'ui-icon-plus'}}).next('.fieldCollapsed').hide();
		$this.button({text:$.trim($this.button('option','label')) != '+'});
	});
};
$(function(){
	$('.fieldCollapse').fieldCollapse();
});

/**
 * single deletion confirmation
 * @param  {string} URL
 * @memberOf module:articleManager
 */
function confirmDelete(URL) {
	if (confirm('Are you sure you want to delete this record')) {
		window.location.href = URL ;
	} 
}


$(function(){
	 /**
     * Bound to `.button.imagePopupThumbnail` to popup a full size image
     *
     * @event click
     *
     * @memberOf module:articleManager
     */
	$('body').delegate('.button.imagePopupThumbnail', 'click', function(){
		var $this = $(this),
			imagePopup = $this.data('imagePopup'),
			form, recrop, crop, maxWidth, maxHeight, preview;
		if (!imagePopup) {
			form = $this.closest('form');
			recrop = $this.hasClass('imagePopupRecrop');
			imagePopup = $this.siblings('.imagePopupContainer');
			
			//resize main image, so that it fits on screen comfortably
			imagePopup.find('.imagePopupImage').each(function(){
				var height = this.attributes.height.value,
					width = this.attributes.width.value,
					scale = (height / Math.min(height, (parseInt($(window).height(),10)||0) / 2)) || 1;
				$(this).css({
					width: width / scale || '',
					height: height / scale || ''
				}).data('scale',scale);
			});
			
			if (recrop) {
				maxWidth = parseInt(form.find('[name=recrop_max_width]').val()||0,10);
				maxHeight = parseInt(form.find('[name=recrop_max_height]').val()||0,10);
			}
			
			imagePopup.show().dialog({
				autoOpen: false,
				buttons: recrop && {
					'Cancel': function(){
						$(this).dialog('close');
					},
					'Save': function(){
						//save data into main form, and submit
						var s = recrop.getSelection(),
							fields = form.find('[name^=recrop_thumbnail_]'),
							scale = imagePopup.find('.imagePopupImage').data('scale');
						$.each(['x1','y1','width','height'], function(){
							fields.filter('[name$=' + this + ']').val(s[this] * scale);
						});
						form.find('[name^=remake_thumbnail_]').val(1);
						$this.parent().css('opacity',0.5);
						$(this).dialog('close');
						form[0].submit();
					}
				},
				open: function(e, ui){
					$(this).dialog('widget').find('button:last').focus();
				},
				width: Math.max((recrop?maxWidth:0)+145,imagePopup.width()) + 16,
				resizable: false
			});
			
			if (recrop) {
				preview = imagePopup.find('img.imagePopupPreview');
				crop = imagePopup.find('[name=fix_aspect_ratio]').bind('change',function(){
					crop = $(this).is(':checked');
					if (crop) {
						maxWidth = preview.parent().width() || maxWidth;
						maxHeight = preview.parent().height() || maxHeight;
					} else {
						maxWidth = parseInt(form.find('[name=recrop_max_width]').val()||0,10);
						maxHeight = parseInt(form.find('[name=recrop_max_height]').val()||0,10);
					}
					$.cookie && $.cookie('fix_aspect_ratio',crop,{expires:365*10});
					recrop.setOptions({
						aspectRatio: crop && (maxWidth + ':' + maxHeight)
					});
				}).is(':checked');
				
				recrop = imagePopup.find('.imagePopupImage').imgAreaSelect({
					onSelectChange: function(img, s){
						//work out how image needs to be scaled to create preview thumbnail
						var width = maxWidth,
							height = maxHeight || s.height || 1,
							scaleX = width / (s.width || 1),
							scaleY = height / (s.height || 1);
						
						//hide preview placeholder (old thumbnail image)
						preview.show().siblings().hide();
						if (!crop) {
							//if either dimension is greater than max, use smallest scale factor of the two
							if (s.width > maxWidth || maxHeight && s.height > maxHeight) {
								scaleX = scaleY = Math.min(scaleX,scaleY);
							//otherwise, use 
							} else {
								scaleX = scaleY = Math.max(Math.max(maxWidth/img.width,maxHeight/img.height),Math.min(scaleX,scaleY));
							}
							width = scaleX * s.width;
							height = scaleY * s.height;
						}
						
						//resize preview image
						preview.css({
							width: Math.round(scaleX * img.width) + 'px',
        					height: Math.round(scaleY * img.height) + 'px',
        					marginLeft: '-' + Math.round(scaleX * s.x1) + 'px',
        					marginTop: '-' + Math.round(scaleY * s.y1) + 'px'
						});
						
						//and its container, if necessary
						if (!crop) {
							preview.parent().css({
								width: width,
								height: height
							});
						}
					},
					parent: imagePopup,
					aspectRatio: crop && (maxWidth + ':' + maxHeight),
					instance: true
				});
			}
			
			$this.data('imagePopup',imagePopup);
		}
		imagePopup.dialog('open');
		return false;
	});
});

//A few helper functions required for swapbox and dependsOn. Also in jquery.clikUtils.js, but moved here to remove dependencies
window.clik = window.clik || {};

/**
 * Utility method for use where a value can be static or a function
 * @param {Object} ref - the array/function/value 
 * @param {String} value - an optional array key/function argument
 *
 * @memberOf module:articleManager
 */
clik.getValue = function(ref,value) {
  switch (typeof(ref)) {
  case 'function':
    return value != null ? ref(value) : ref();
  case 'array': case 'object':
    return value != null ? ref[value] : ref;
  default:
    return ref;
  }
};

/**
 * As CF listAppend
 * @param {string} list
 * @param {string} value
 * @param {string} delims
 * @memberOf module:articleManager
 */
clik.listAppend = function(list, value, delims) {
  delims = delims || ',';
  var arr = list ? list.split(delims) : [];
  arr.push(value);
  return arr.join(delims);
};

/**
 * As CF ListLen
 *  @memberOf module:articleManager
 */
clik.listLen = function(list,delims){
  delims = delims || ',';
  var arr = list.split(delims);
  return arr.length > 1 || arr[0] !== '' ? arr.length : 0;
};

/**
 * As CF listPrepend
	 * @memberOf module:articleManager
 * @param {string} list
 * @param {string} value
 * @param {string} delims
 */
clik.listPrepend = function(list, value, delims) {
  return clik.listAppend(value, list, delims);
};

/**
 * Remove all occurences of an item from a list
 * @memberOf module:articleManager
 * @param {string} list
 * @param {string} value
 * @param {string} delims
 */
clik.listRemove = function(list, value, delims) {
  delims = delims || ',';
  value = value + '';
  return $.map(list ? list.split(delims) : [], function(test){
      return test === value ? null : test;
  }).join(delims);
};

/**
 * As CF listFind (ie first item is 1, not found is zero)
 * @memberOf module:articleManager
 * @param {string} list
 * @param {string} value
 * @param {string} delims
 */
clik.listFind = function(list, value, delims) {
  delims = delims || ',';
  value = value + '';
  return $.inArray(value, list ? list.split(delims) : []) + 1;
};

/**
 * Article manager swapbox functionality
 *
 * A swapbox is made up of two multiple selects (fieldname_main,fieldname_current),
 * a hidden field (fieldname) to contain the actual values and buttons to move from available
 * to current. 
 * 
 *
 * @memberOf module:articleManager.$.fn
 * @param {boolean} options.filter Show a filter field
 */
$.fn.amSwapbox = function(options){
	var defaults = {filter: false},
		op = $.extend({}, defaults, options);
	return this.each(function(){
		var $this = $(this),
			field = $this.find(':input[type=hidden]')[0],
			main = $this.find(':input[name=' + field.name + '_main]')[0],
			current = $this.find(':input[name=' + field.name + '_current]')[0];
		$this.bind('moveElements', function(e, elements){
			if (!$.isArray(elements)) {
				elements = [elements];
			}
			$.each(elements, function(){
				if ($(this).closest('select')[0] == main) {
					field.value = clik.listAppend(field.value,this.value);
				} else {
					field.value = clik.listRemove(field.value,this.value);
				}
			});
			$this.trigger('rebuild');
		}).bind('rebuild', function(){
			var toMove = [], fieldValue = field.value, fieldValueFull = fieldValue;
			$.each(main.options, function(){
				if (this.value && clik.listFind(fieldValue, this.value)) {
					toMove.push(this);
          			fieldValue = clik.listRemove(fieldValue, this.value);
				}
			});
			$(toMove).appendTo(current).attr('selected',false);
			if (toMove.length) {
				$(main).trigger('change',[true]);//pass true to force swapbox change event
			}
			
			toMove = [];
      		fieldValue = field.value;
			$.each(current.options, function(){
				if (this.value && !clik.listFind(fieldValue, this.value)) {
					toMove.push(this);
				} else {
          			fieldValue = clik.listRemove(fieldValue, this.value);
        		}
			});
			$(toMove).appendTo(main).attr('selected',false);
      		if (toMove.length) {
        		$(current).trigger('change',[true]);//pass true to force swapbox change event
      		}
			
			$.each([main,current],function(){
				if (!this.options.length) {
					//add placeholder to empty selects
					$('<option value="" disabled="true">(no values)</option>').appendTo(this);
				} else if (this.options.length > 1) {
					//and remove from non-empty
					$(this).find('option[value=""]').remove();
				}
			});
			
			if ($(main).data('originalrows')) {
				$(main).data('originalrows', $(main).data('originalrows').filter(function(){
					return !clik.listFind(fieldValueFull, this.value);
				}));
			}
		}).delegate('option', 'dblclick', function(){
			$this.trigger('moveElements', [this]);
		}).delegate(':button[name=right]', 'click', function(){
			$this.trigger('moveElements', [$.map(main.options, function(option){
				return option.selected ? option : null;
			})]);
		}).delegate(':button[name=left]', 'click', function(){
			$this.trigger('moveElements', [$.map(current.options, function(option){
				return option.selected ? option : null;
			})]);
		});
		
		if (op.filter) {
			$(main).filterselect({inputClass: 'swapBoxFilter',hide:true
			});
			$this.hover(function(){
				$(this).find('input.swapBoxFilter').show().unbind('blur.swapBox');
			}, function(){
				var input = $(this).find('input.swapBoxFilter');
				if (input[0] != document.activeElement) {
					input.val('').trigger('processKey').hide();
				} else {
					input.bind('blur.swapBox', function(){
						input.val('').trigger('processKey').hide().unbind('blur.swapBox');
					});
				}
			});
		}
	});
};

/**
 * Initialise a boolean checkbox. In the AM system a boolean checkbox is actually a hidden input field with values `1` or `0`, and a checkbox to control this.
 * This function initialises the checkbox
 * @memberOf module:articleManager
 * @param {string} control The jQuery selector for the control checkbox
 */
function AMBooleanCheckbox(control) {
	var $box = $(control),
		name=$box.attr('name').replace(/_control$/,''),
		field=$box.closest('.inputContainer').find('input[name='+name+']');
	field.val( $box.is(':checked') ? 1 : 0 );
};

/**
 * Set the value of an element depending on the value of a select control.
 * The option 'title' attribute will be used unless a data struct is specified
 * @memberOf module:articleManager.$.fn
 * @param {Object} [target] (optional) - the element to change. A `div.optionDescriptionTarget` will be appended if this is blank
 * @param {Object} [data] (optional) - a data struct from which to get values, keyed by the values of the select control 
 */
$.fn.amOptionDescription = function(target, data){
  if (!data && $.isPlainObject(target)) {
    data = target;
    target = null;
  }
  return this.each(function(){
    var $this = $(this), _target = target, after;
    //create target div if not specified and doesn't already exist
    if (!_target && !(_target = $this.next('div.optionDescriptionTarget')).length) {
      // after = $this.nextAll('.helpicon');
      _target = $('<div class="optionDescriptionTarget"></div>').appendTo($this.closest('.inputContainer'));
    }
    $(_target).dependsOn({dependsOn: $this, updatesOn: function(value){
      if (data && data[value]) {
        return {html: $.isPlainObject(data[value]) ? data[value].DESCRIPTION : data[value]};
      } else {
        return {html: $this.find('option:selected').attr('title')};
      }
    }});
  });
};


/**
 * @memberOf module:articleManager.$.fn
 * 
 * very crude filter for multiple select fields. Inserts a text field before the select
 * and filters the value on key up
 *
 * @param options {object} The options
 * @param {int} [options.minChars = 3]   Minimum characters before filter starts
 * @param  {string} [options.inputClass = 'filter'] Class applied to filter input
 * @param  {boolean} [options.hide = 'false'] Hide the filter input. Need to manually add show() on hover (see inputClass)
 * @return {jQuery} 
 */
$.fn.filterselect = function (options) {
	var defaults = { minChars: 3, inputClass: 'filter',hide:false } ;
	var $this = $(this);
	var op = $.extend({}, defaults, options); 
	
	this.each(function() {
		
		var select = $(this);
		var prevLength = 0;
		var timeout = false;
		
		select.data('originalrows', select.find('option'));
		
		var $input = $('<input type="text" id="i_' + select.attr('name') + '" class="' + op.inputClass + '" placeholder="Filter:"/>');
		if (op.hide) $input.hide();
		$input.insertBefore(select);

		if ($.browser.mozilla) {
			$input.keypress(processKey); // onkeypress repeats arrow keys in Mozilla/Opera
		} else {
			$input.keyup(processKey); // onkeydown repeats arrow keys in IE/Safari
		}
		
		function processKey(e) {
			//console.log("Field value is " + $input.val());
			//console.log($input.val().length + " vs: " + prevLength);
			if ($input.val().length != prevLength) {
				if (timeout) {
					clearTimeout(timeout);
				}
				//console.log("Setting filter timeout");
				timeout = setTimeout(filtre, 300);
				prevLength = $input.val().length;	
			}		
			
			// Keep the "good" option tags
			function filtre() {	
				var q = $.trim($input.val());
				var rows = select.data('originalrows');
				//console.log("Filtering for " + q);
				if (q.length >= op.minChars) {
					rows = parseRows(rows, q);
				}
				select.empty().append(rows);
			}
			
			function parseRows(or, q) {
				var re = new RegExp(q, 'ig');
				return or.filter(function () {
					return re.test($(this).text()) ? this : false;
				});
			}
					
		}
	});
	return this;
};

/**
 *  an object to hold the values of a pull down menu.
 * This gets used in swapboxes and pull downs that depend on other pulldowns
 *
 * @memberOf module:articleManager
 * 
 * @param  {type} value    [description]
 * @param  {type} display  [description]
 * @param  {type} selected [description]
 * @return {type}          [description]
 */
function amOption(value,display,selected) {
	if (selected == null) {
		selected = 0;
	} 
	this.value = value;
	this.display = display;
	this.selected = selected;
}



/* These scripts taken from the ColdFusion 4.5 Help Files */



/**
 * From quirksmode.org
 * @memberOf module:articleManager
 * @param {type}   obj [description]
 * @param {type}   evt [description]
 * @param {Function} fn  [description]
 */
function addEventSimple(obj,evt,fn) {
	if (obj.addEventListener)
		obj.addEventListener(evt,fn,false);
	else if (obj.attachEvent)
		obj.attachEvent('on'+evt,fn);
}

/**
 * @memberOf module:articleManager
 * @param  {type}   obj [description]
 * @param  {type}   evt [description]
 * @param  {Function} fn  [description]
 */
function removeEventSimple(obj,evt,fn) {
	if (obj.removeEventListener)
		obj.removeEventListener(evt,fn,false);
	else if (obj.detachEvent)
		obj.detachEvent('on'+evt,fn);
}

/**
 * @deprecated ?
 * @namespace
 * @memberOf module:articleManager
 */
dragDrop = {
	initialMouseX: undefined,
	initialMouseY: undefined,
	startX: undefined,
	startY: undefined,
	draggedObject: undefined,
	/**
	 * 
	 * @param   element    [description]
	 * @param   moveParent [description]
	 */
	initElement: function (element,moveParent) {
		if (typeof element == 'string'){
			element = document.getElementById(element);
		}
		if(moveParent == 1){
			element.onmousedown = dragDrop.startDragMouseParent;
		}
		else{
			element.onmousedown = dragDrop.startDragMouse;
		}		
	},
	/**	
	 * Drags the parent object - used when input elements are involved.
	 * @param   e [description]
	 */
	startDragMouseParent: function (e) {// Drags the parent object - used when input elements are involved.
		dragDrop.startDrag(this.parentNode);
		var evt = e || window.event;
		dragDrop.initialMouseX = evt.clientX;
		dragDrop.initialMouseY = evt.clientY;
		addEventSimple(document,'mousemove',dragDrop.dragMouse);
		addEventSimple(document,'mouseup',dragDrop.releaseElement);
		return false;
	},	
	/**
	 * @param   e [description]
	 */
	startDragMouse: function (e) {
		dragDrop.startDrag(this);
		var evt = e || window.event;
		dragDrop.initialMouseX = evt.clientX;
		dragDrop.initialMouseY = evt.clientY;
		addEventSimple(document,'mousemove',dragDrop.dragMouse);
		addEventSimple(document,'mouseup',dragDrop.releaseElement);
		return false;
	},
	/**
	 * @param   obj [description]
	 */
	startDrag: function (obj) {
		if (dragDrop.draggedObject)
			dragDrop.releaseElement();
		dragDrop.startX = obj.offsetLeft;
		dragDrop.startY = obj.offsetTop;
		dragDrop.draggedObject = obj;
		obj.className += ' dragged';
	},
	/**
	 * @param   e [description]
	 */
	dragMouse: function (e) {
		var evt = e || window.event;
		var dX = evt.clientX - dragDrop.initialMouseX;
		var dY = evt.clientY - dragDrop.initialMouseY;
		dragDrop.setPosition(dX,dY);
		return false;
	},
	/**
	 * @param  dx [description]
	 */
	setPosition: function (dx,dy) {
		dragDrop.draggedObject.style.left = dragDrop.startX + dx + 'px';
		dragDrop.draggedObject.style.top = dragDrop.startY + dy + 'px';
	},
	/**
	 */
	releaseElement: function() {
		removeEventSimple(document,'mousemove',dragDrop.dragMouse);
		removeEventSimple(document,'mouseup',dragDrop.releaseElement);
		dragDrop.draggedObject.className = dragDrop.draggedObject.className.replace(/dragged/,'');
		dragDrop.draggedObject = null;
	}
}


/**
 * Namespace for some Article Manager functions
 * @memberOf module:articleManager
 * @namespace
 */
AM = {
	/**
	 * A simple function to process a record row with an AJAX call. Designed to  be used as an event handler with addition data to pass in
	 * Bind this to an a-tag, and the href for this tag will be called, after an optional confirm dialog is displayed. 
	 * @param  {obj} event jQuery event object. Should contain a 'data' key with some further options (see inline)
	 */
	itemAjaxProcess : function(event) {
		var $this = $(this),
			defaults = {
				confirm : true, 				// Do you want to display a confirm dialog before actually doing the action?
				confirmText: 'Are you sure?', 	// text to display in the confirm dialog, if confirm == true
				callback : function(){return;}, // function to call after successfull AJAX call. Will receive two arguments:
												// the first is the op object (event.data + defaults), the second is the event object
				url : $this.attr('href')		// You can overwrite the URL to call here
			},
			op = $.extend({},defaults,event.data),
			actionNow = function() {
				op.row.disableWithOverlay();
				$.getJSON(op.url, function(data){
					op.ajaxData = data;
					op.row.disableWithOverlay(false);
					if( !data.SUCCESS ) {
						switch( typeof data.ERRORS ) {
							case 'object':
								$.each(data.ERRORS, function(){
						          clik.showAdminMessage({message: this, type: 'error'});
						        });
						   		break;
						   	case 'string':
						   		clik.showAdminMessage({message: data.ERRORS, type: 'error'});
						   		break;
						}
					} else {
						op.callback(op,event);
					}
				});
				return false;
			};
		if( !op.cell ) op.cell = $this.closest('td');
		if( !op.row ) op.row = $this.closest('tr,.gridItem');
		if( !op.table ) op.table = op.row.closest('table.recordlist,div.recordgrid');
		if( !op.id ) op.id = op.table.is('table') ? op.table.attr('id').replace(/_recordtable$/,'') : op.table.attr('id').replace(/_recordgrid$/,'');

		$this.trigger('mouseleave'); // hide any tooltips
		
		if( op.confirm ) {
			if( !op.confirmDialog ) op.confirmDialog = $('#'+op.id+'_confirmDialog');
			op.confirmDialog
			.html(op.confirmText)
			.dialog('option','buttons',[{
				text : 'Yes',
				'class' : 'bluishBtn',
				click : function() {
					actionNow();
					$(this).dialog('close');
				}
			},{
				text : 'No',
				click : function() {
					$(this).dialog('close');
				}
			}])
			.dialog('open');
		} else {
			actionNow();
		};
		return false;
	},
	/**
	 * basically a wrapper for AM.itemAjaxProcess
	 */
	deleteItem : function() {
		AM.itemAjaxProcess.call(this,{ data : {
			callback : function( data ) {
				data.row.addClass('deleted')
				.find(':input').attr('disabled','disabled').addClass('ui-state-disabled').end()
				.find('.data_actions,.button').remove();
			},
			confirmText : 'Are you sure you want to delete this item?'
		}});
		return false;
	},
	/**
	 * Event callback to process marked records.
	 * The event is to be bound to an 'a' elemnt, and the 'href' attribute of this determines the action
	 * Define `$(this).data('confirm')` as a question to ask if the action needs confirmation before performing it
	 * @param  {obj}  	  e        The event object
	 * @param  {Function} callback callback to call after processing has finished
	 */
	processMarked : function(e, callback) {
		var $this = $(this),
			$form = $this.closest('form'),
			section = $this.data('section'),
			confirm = $this.data('confirm') || '',
			data = {
				id : AM.getChecked($form),
				listedIds : AM.getListedIds($form)
			},
			$confirmDialog = $('#'+section+'_confirmDialog');
		e.preventDefault();
		e.stopPropagation();
		if( confirm != '' ) { // If we have a confirm text then show a dialog before taking any action
			$confirmDialog
			.html(confirm)
			.dialog('option','buttons',[{
				text : 'Yes',
				'class' : 'bluishBtn',
				click : function() {
					AM.reloadTableData( $this.attr('href')+'&record_id='+$form.attr('data_record_id'), section , data , true, callback);
					$(this).dialog('close');
				}
			},{
				text : 'No',
				click : function() {
					$(this).dialog('close');
				}
			}])
			.dialog('open');
		} else {
			AM.reloadTableData( $this.attr('href')+'&record_id='+$form.attr('data_record_id'), section , data , true, callback);
		}
	},
	/**
	 * Get a comma seperated list of primariy keys for ticked/unticked records.
	 * @param  {jquery} form      
	 * @param  {boolean} [unchecked] Provide `true` if you want to get unchecked, rather than checked items
	 * @return {string}           Comma separated list of primary keys
	 */
	getChecked : function ( form, unchecked ) {
		return (form.find('table.recordlist').data('ticked_records')||[]).join(',');
	},
	/**
	 * Get list of all displayed items
	 * @param  {jQuery} form 
	 * @return {string}           Comma separated list of primary keys
	 */
	getListedIds : function(form) {
		return form.find('input[name=listedids]').val() || '';
	},
	/**
	 * Event callback to check whether any records are ticked
	 * To be bound to `a` elements. Will proceed to the `a`s href attribute after check
	 */
	checkTickedRecords : function(e) {
		var $this = $(this),
			id = $(this).data('recordId'),
			$form = $('#'+id+'_form'),
			checked = AM.getChecked($form),
			$confirmDialog = $('#'+id+'_confirmDialog');
		e.preventDefault();
		e.stopPropagation();

		if( checked != '' && checked != AM.getListedIds($form) ) {
			$confirmDialog
			.html('Which records do you want to change?')
			.dialog('option','width',375)
			.dialog('option','buttons',[{
				text : 'Change marked records',
				'class' : 'bluishBtn',
				click : function() {
					/* get only the first one as there may be multiple */
					$form.find('.amAction-omitunmarked').eq(0).trigger('click', function(){window.location = $this.attr('href');});
					$(this).dialog('close');
				}
			},{
				text : 'Change all records',
				click : function() {
					window.location = $this.attr('href');
					$(this).dialog('close');
				}
			}])
			.dialog('open');

		} else {
			window.location = $this.attr('href');
		}
	},
	/**
	 * Function to reload a dataTable. Can accept either a URL to reload from, or data to reload directly
	 * @param  {string|obj} url     If this is a string, it will be the URL from which to get new data. Otherwise it will be expected to be a TABLEDATA object, and the table will be reloaded with this data
	 * @param  {string} section 	the 'section' attribute of the corresponding cf_record tag
	 * @param  {obj} data    		additional data to POST to url (if url is string)
	 * @param  {bool} resetPage 	should the page be reset (default: false)
	 * @param  {func} callback	 	callback after table has been reloaded
	 * @return {void}         
	 */
	reloadTableData : function(url,section,data,resetPage, callback) {
		var action_loading = $('#'+section+'_form').find('.action_loading').show(),
			reload = function(JSON) {
				window[section+'_data'].rowClasses = JSON.TABLEDATA.rowClasses;
				window[section+'_data'].rowId = JSON.TABLEDATA.rowId;
				window[section+'_table'].fnReload(JSON.TABLEDATA,JSON.AM_ACTION_MENU,JSON.EDITABLE);
				$('#'+section+'_recordcount').text(JSON.TABLEDATA.aaData.length);
				action_loading.hide();
				if( JSON.SUCCESS == false ) {
					switch( typeof JSON.ERRORS ) {
						case 'object':
							$.each(JSON.ERRORS, function(){
					          clik.showAdminMessage({message: this, type: 'error'});
					        });
					   		break;
					   	default:
					   		clik.showAdminMessage({message: JSON.ERRORS, type: 'error'});
					   		break;
					}
				}
				if( resetPage ) window[section+'_table'].fnDisplayStart(iDisplayStart);
				if( typeof callback == 'function' ) callback.call();
			},
			iDisplayStart = 0;
		if( !data ) data = {};
		if( typeof resetPage == 'undefined' ) resetPage = false;

		if( resetPage ) iDisplayStart = window[section+'_table'].fnDisplayStart();
		
		switch( typeof url ) {
			case 'string': // get the data from the url provided, using the data provided, then reload table
				if( 'clik' in window && 'checkLogin' in clik ) {
					clik.checkLogin(function() {
						$.post( url, data, reload ,'json' )
					});
				} else {
					$.post( url, data, reload ,'json' )
				}
				break;
			default: // we have the required data to reload the table - just reload it now.
				reload(url);
		};
	},

	/**
	 * Function to reload a grid. Can accept either a URL to reload from, or data to reload directly
	 * @param  {string/obj} url     If this is a string, it will be the URL from which to get new data. Otherwise it will be expected to be a TABLEDATA object, and the table will be reloaded with this data
	 * @param  {string} section 	the 'section' attribute of the corresponding cf_record tag
	 * @param  {obj} data    		additional data to POST to url (if url is string)
	 * @return {void}         
	 */
	reloadGrid : function(url,section,data) {
		var action_loading = $('#'+section+'_form').find('.action_loading').show(),
			reload = function(JSON) {
				$('#'+section+'_nav').replaceWith(JSON.NAVOPTIONS);
				$('#'+section+'_recordgrid').children(':not(.controls)').remove()
				.end()
				.append(JSON.GRIDDATA);
				if( JSON.AM_ACTION_MENU ) {
					$('#am_action_menu').replaceWith(JSON.AM_ACTION_MENU);
				}
			};
		if( !data ) data = {};
		
		switch( typeof url ) {
			case 'string': // get the data from the url provided, using the data provided, then reload table
				clik.checkLogin(function() {
					$.post( url, data, reload ,'json' )
				});
				// $.post( url, data, reload ,'json' );
				break;
			default: // we have the required data to reload the table - just reload it now.
				reload(url);
		};
	},
	/**
	 * Not sure. Looks like a wrapper around {@linkcode module:articleManager.AM.reloadTableData}
	 * @param  {Event} e 
	 */
	findAll : function(e) {
		e.preventDefault();
		e.stopPropagation();
		AM.reloadTableData( $(this).attr('href'), $(this).attr('data-section') );
	},

	/**
	 * Check/uncheck all.
	 * @param  {Event} e 
	 */
	toggleCheckAll : function(e) {
		e.preventDefault();
		e.stopPropagation();
		var check = $(this).is(':checked'),
			checkboxes = $(this).closest('table').find('input[name=id]');
		if( check ) {
			checkboxes.attr('checked', 'checked').trigger('change').parent().addClass('checked');
		} else {
			checkboxes.removeAttr('checked').trigger('change').parent().removeClass('checked');
		}
	}
}

/**
 * Threshold for triggering AM's mobile interface. There must be a better way ...
 * @memberOf module:articleManager
 * @type {Number}
 */
AMmobileInterfaceThreshold = 500;
/**
 * some defaults for initialization of some scripts.
 *
 * this can be used either by initializing like this: `$(element).init($.extend({},AMdefaults.pluginDefaults,{otheroptions}))`
 * @namespace
 * @memberOf module:articleManager
 */
AMdefaults = {
	// some stuff that we'll need repeatedly for the various date sorting methods
	/**
	 * Generic date/time sorting to be used by dataTables plugin, the basis for various 
	 * date/time sorting logic for various locales.
	 *
	 * @see  module:dataTables.DataTable.models.ext.oSort
	 * 
	 * @param  {string} input the value
	 * @param  {Object} ops
	 * @param {String} ops.separator Date separator
	 * @param {Int} ops.day 0-based position of day in date in the input string
	 * @param {Int} ops.month 0-based position of month in date in the input string
	 * @param {Int} ops.year 0-based position of year in date in the input string
	 */
	"datetime-generic-pre": function (input,ops) {	
	    if ($.trim(input) != '') {
	        var aDateTime = $.trim(input).split(' '),aTime,aDate,x;
	        // no time: this is a date only
	        if( aDateTime.length < 2 ) aDateTime[1] = '00:00:00';
	        aTime = aDateTime[1].split(':');
	        // no seconds: assume 00
	        if( aTime.length < 3 ) aTime[2] = '00';
	        aDate = aDateTime[0].split(ops.separator);
	        x = (aDate[ops.year] + aDate[ops.month] + aDate[ops.day] + aTime[0] + aTime[1] + aTime[2]) * 1;
	    } else {
	        var x = 10000000000000; // = year 1000 ...
	    }
	    return x
	},
	/**
	 * Sort date/time ascending
	 *
	 * @see  module:dataTables.DataTable.models.ext.oSort
	 */
	"datetime-generic-asc": function (a,b) {
		return a - b;
	},
	/**
	 * Sort date/time descending
	 *
	 * @see  module:dataTables.DataTable.models.ext.oSort
	 */
	"datetime-generic-desc": function (a,b) {
		return b - a;
	},

	/**
	 * Defaults for the {@linkcode clik.recordGrid}
	 * @type {Object}
	 */
	recordGrid : {
		minWidth: AMmobileInterfaceThreshold // if window is narrower than this: click on grid item will open edit page
	},
	/**
	 * defaults for {@linkcode module:dataTablesEditable}.
	 * @type {Object}
	 */
	editable : {
		minWidth : AMmobileInterfaceThreshold, // if the window is narrower than this, inline editing will be disabled
		fnShowError : function(errorText, action) {
			clik.showAdminMessage({type:'error',message:errorText});
		},
		aoColumns : { //NB: This will be merged to every single column using a loop! (will probably want to do this server side, but for debug it's easier this way)
			placeholder : '',
			submit : '<a class="button_small dblueBtn"><i class="icon-save"></i></a>',
			cancel : '<a class="button_small whitishBtn"><i class="icon-undo"></i></a>',
			'event' : 'click',
			width : 'auto',
			onblur :'ignore',
			callback : function( value , settings ) {
				var data = JSON.parse(value),
					aPos = window[settings.oTable].fnGetPosition(this);

				// window[settings.oTable].fnUpdate(data.VALUE, aPos[0], aPos[2]);
				if( data.SUCCESS ) {
					$(this).addClass('changesSaved');
					// clik.showAdminMessage({type:'success',message:'Changes saved',selector : $(this)});
				} else if ( "ERRORS" in data ) {
					$.each( data.ERRORS, function(code,message){
						clik.showAdminMessage({type:'error',message:message});
						delete data.ERRORS[code]; // make sure error is only thrown once!
					})
				}
				if( "LOCATION" in data ) {
					$(this).html(data.value);
					AM.reloadTableData(data.LOCATION,$(this).closest('table').attr('id').replace('_recordtable',''),false,true);
					return false;
				} else {
					AM.reloadTableData(data,$(this).closest('table').attr('id').replace('_recordtable',''),false,true);
				};
			},
			onsubmit : function(settings, td) {
				var valid, form = this;
		        var input = $(td).find("input"),
		        	validatorSettings = {
			            rules: {value : settings.rule}
			        };
			    if( settings.message ) validatorSettings.messages = { value : settings.message }
		        $(form).validate(validatorSettings);
		    	valid = $(form).valid();

				if( !valid ) return false;
				
				if( !settings.loginChecked ) {
					clik.checkLogin(function(){
						// This is ridiculous. Need to insert this here, and remove it after a while so we can recheck if need be.
						settings.loginChecked = true;
						window.setTimeout(function(){
							settings.loginChecked = false;
						},100)
						form.triggerHandler('submit');
					})
					return false;
				}
		    }
		}
	},
	/**
	 * Date picker defaults
	 * @type {Object}
	 */
	datepicker : {
		dateFormat: 'dd/mm/yy' ,
		showButtonPanel : true
	},
	// 
	/**
	 * {@linkcode module:dataTables} defaults
	 * @type {Object}
	 */
	dataTables: {
		bJQueryUI: true, //we are using jquery UI styling
		sPaginationType: 'full_numbers',
		asStripeClasses : [],// this can be used to alternate classe, but we do this with :nth-of-type to make sorting a bit easier
		// don't use labels: use only icons
		oLanguage : {
			oPaginate : { 
				sFirst : '',
				sLast : '',
				sNext : '',
				sPrevious : ''
			},
			sZeroRecords : 'No records in '+$('#sectiontitle h3.sectiontitle').text()+'.',
			sSearch : 'Filter: '
		},
		bAutoWidth:false,
		//some callbacks
		fnInitComplete: function(oSettings, json) {
		    $.each( oSettings.aoColumns , function(i,col){
		    	if( col.data ) {
			    	$(oSettings.nTHead).find('th').eq(i).data(JSON.parse(col.data));
			    }
			    if( col.attr ) {
			    	$(oSettings.nTHead).find('th').eq(i).attr(JSON.parse(col.attr));
				}
			    if( col.sClassHead ) {
			    	$(oSettings.nTHead).find('th').eq(i).addClass(col.sClassHead);
				}
			});
			$(oSettings.nTHead)
			.clikInitFormElements()
			.clikInitTipsy();
			$(oSettings.nTable).parent().siblings('.loading').hide();
			$(oSettings.nTable).bind('filter',function(e,o){
				// replace list of listed ids
				var ids = '';
				$(this).dataTable().$('tr', {"filter": "applied"}).each(function(){
					ids = ids + $(this).attr('id') + ',';
				})
				ids = ids.replace(/,$/,'');
				$(this).closest('form').find('input[name=listedids]').val(ids);
			}).on('change.amDataTable','input[name=id]',function(){
				var $table = $(oSettings.nTable),
					ticked_records = $table.data('ticked_records') || [],
					thisId = $(this).val(),
					thisTicked = $(this).is(':checked'),
					index = $.inArray(thisId, ticked_records);
				if( thisTicked ) {
					if( index == -1 ) {
						ticked_records.push(thisId)
					}
				} else {
					ticked_records.splice(index,1);
				}
				$table.data('ticked_records',ticked_records);
			});
			/* If we are using 'mobile': click on a row leads to edit (there won't be enough room to display the right column) */
			if( $(window).width() < AMmobileInterfaceThreshold ) {
				$(this).off('click.amEditRow').on('click.amEditRow','tr:has(span.action_edit)',function(e){
					if( !$(e.target).is('a') ) {
						window.location = $(this).find('span.action_edit a').attr('href');
					}
				})
			}
	    },
	    fnDrawCallback : function( oSettings ){
	    	var $table = $(oSettings.nTable);
	    	$table.find('.checkBoxMaster').checkBoxGroups();
	    	// re-init master check box
			$table.find('.checkBoxMaster').removeAttr('checked').parent().removeClass('checked');
			$table.trigger('updated.dataTable',oSettings);
	    },
	    fnRowCallback : function( nRow, aData, iDisplayIndex, iDisplayIndexFull ) {
	    	var $cb = $(nRow).find('input[name=id]'),
	    		tr;
	    	if( $cb.length ) {
	    		tr = this.data('ticked_records') || this.data('ticked_records',[]).data('ticked_records');
	    		if( $cb.is(':checked') ) tr.push($cb.val());
	    	}
	    }
	},
	/**
	 *  validation defaults (sfor some types of fields the error message has to appear at differnt positions)
	 * @type {Object}
	 */
	validate : {
		ignore: ':hidden:not(.has_chosen)',
		errorPlacement: function(error, element) {
			// we need searchModifier here for bulk changes
			error.appendTo($(element).closest('.inputContainer,.searchModifier'));
		},
		highlight: function(element, errorClass) {
			var $element = $(element),$p = $element.closest('.inputContainer,.searchModifier'),
				type = clik.getPrefixedClass($p.closest('.fieldContainer').attr('class'),'type_'),
				$tab;
			if( $p.hasClass('searchModifier') ) { //bulk change modifier: is always a list
				$p.find('.chosen-single').addClass(errorClass);
			} else {
				switch( type ) {
					case 'radio':
					case 'checkbox':
						$p.addClass(errorClass);
						break;
					case 'list':
						$p.find('.chosen-single').addClass(errorClass);
						break;
					case 'multi':
						$p.find('ul.chosen-choices').addClass(errorClass);
						break;
					default:
						$element.addClass(errorClass);
				}
			}
			// we also must do something if it has tabs or accordion to highlight the appropriate tab/accordion segment
			if( ($tab = $(element).closest('.tab')).length ) {
				$tab.closest('.ui-tabs').find('.ui-tabs-nav li').has('a[href="#'+$tab.attr('id')+'"]').addClass('hasError');
			} else if ( ($tab = $(element).closest('.ui-accordion-content')).length ) {
				$tab.prev('.ui-accordion-header').addClass('hasError');
			}
		},
		unhighlight: function(element, errorClass) {//bulk change modifier: is always a list
			var $element = $(element),$p = $element.closest('.inputContainer,.searchModifier'),
				type = clik.getPrefixedClass($p.closest('.fieldContainer').attr('class'),'type_'),
				$tab;
			if( $p.hasClass('searchModifier') ) {
				$p.find('.chosen-single').removeClass(errorClass);
			} 
			switch( type ) {
				case 'radio':
				case 'checkbox':
					$p.removeClass(errorClass);
					break;
				case 'list':
					$p.find('.chosen-single').removeClass(errorClass);
					break;
				case 'multi':
					$p.find('ul.chosen-choices').removeClass(errorClass);
					break;
				default:
					$element.removeClass(errorClass);
			}
			// we also must do something if it has tabs or accordion to highlight the appropriate tab/accordion segment
			if( ($tab = $(element).closest('.tab')).length && !$tab.find('.'+errorClass).not('label').length ) {
				$tab.closest('.ui-tabs').find('.ui-tabs-nav li').has('a[href="#'+$tab.attr('id')+'"]').removeClass('hasError');
			} else if ( ($tab = $(element).closest('.ui-accordion-content')).length && !$tab.find('.'+errorClass).not('label').length ) {
				$tab.prev('.ui-accordion-header').removeClass('hasError');
			}
		}
	},
	/**
	 *  this may be overwritten on the page!
	 * @type {Object}
	 */
	dateValidateOptions : {
		separator: '/',
		day: 0,
		month: 1,
		year: 2
	}
}

/* Set this as default. I have no idea why, but for some reason Chrome on iOS will ignore the options otherwise. See ticket 167751 */
/*$.datepicker.setDefaults({
   dateFormat: 'mm/dd/yy'
});*/

if( 'editable' in $ ) {

	/**
	 * @memberOf module:articleManager
	 * @see {@linkcode module:editable.$.editable}
	 * @namespace $.editable
	 */

	/**
	 * Providing custom types to the editable plugin. See {@linkcode module:editable.$.editable}
	 * @memberOf module:articleManager
	 * @namespace $.editable.types
	 */

	/**
	 * add 'plugin' to text edit: remove indicator
	 * @memberOf module:articleManager.$.editable.types
	 * @param  {Object} settings 
	 * @param  {noe} original 
	 */
	$.editable.types.text.plugin = function(settings,original) {
		var $input = $(this).find('input');
		if( $input.val() == '&nbsp;' ) $input.val('');
		$(original).removeClass('changesSaved');
	}
	/**
	 * add 'plugin' to textarea edit: remove indicator
	 * @memberOf module:articleManager.$.editable.types
	 * @param  {Object} settings 
	 * @param  {noe} original 
	 */
	$.editable.types.textarea.plugin = function(settings,original) {
		var $input = $(this).find('textarea');
		if( $input.val() == '&nbsp;' ) $input.val('');
		$input.elastic({minRows:0,maxRows:20}).closest('td').removeClass('changesSaved');
	}
	/*
		add some custom types to editable
	 */
	/**
	 * @name list
	 *
	 * @description 
	 * Similar to `select`, but:
	 *  - uses `chosen`
	 *  - allows data to be provided as object or as array. 
	 *
	 * @example
	 * //If data is an object the key will be used as value, and the value to display, e.g.
	 * {'E':'Letter E','F':'Letter F',‘G':'Letter G'}
	 *
	 * @example
	 * // if provided as array each element must be an object containing a VALUE and a DISPLAY key (uppercase for easier integration with CF), e.g.
	 * 	[{
	 * 		VALUE : 'E',
	 * 		DISPLAY : 'Letter E'
	 * 	},{
	 * 		VALUE : 'F',
	 * 		DISPLAY : 'Letter F'
	 * 	},{
	 * 		VALUE : 'G',
	 * 		DISPLAY : 'Letter G'
	 * 	}]
	 * 
	 * @memberOf module:articleManager.$.editable.types
	 * @type Object
	 */
	$.editable.addInputType('list', $.extend($.editable.types.select,{
		element : function(settings, original) {
			var select = $('<select />');
			$(this).append(select);
			return(select);
		},
		plugin:function(settings, original) {
	    	$(original).clikInitFormElements()
	    	.removeClass('changesSaved');
		},
		content : function(data,settings,original) {
	        /* If it is string assume it is json. */
			if (String == data.constructor) {      
				eval ('var json = ' + data);
	        } else {
	        /* Otherwise assume it is a hash already. */
	            var json = data;
	        }
	        var isArray = $.isArray(json);
	        for (var key in json) {
	            if (!json.hasOwnProperty(key)) {
	                continue;
	            }
	            if ('selected' == key) {
	                continue;
	            } 
	            var option = $('<option />').val(isArray ? json[key].VALUE : key).append(isArray ? json[key].DISPLAY : json[key]);
	            $('select', this).append(option);    
	        }                    
	        /* Loop option again to set selected. IE needed this... */ 
	        $('select', this).children().each(function() {
	            if ($(this).val() == json['selected'] || 
	                $(this).text() == $.trim(original.revert)) {
	                    $(this).attr('selected', 'selected');
	            }
	        });
		}
	}));
	/**
	 * @name integer
	 *
	 * @description 
	 * Integer input: use some html5 for those who support it
	 * 
	 * @memberOf module:articleManager.$.editable.types
	 * @type Object
	 */
	$.editable.addInputType('integer', {
		element : function(settings, original) {
			var input = $('<input type="number" step="1">');
			$(this).append(input);
			return(input);
		},
		plugin :function(settings,original) {
			var $input = $(this).find('input');
			if( $input.val() == '&nbsp;' ) $input.val('');
			$(original).removeClass('changesSaved');
		}
	});
	/**
	 * @name numeric
	 *
	 * @description 
	 * numeric input: use some html5 for those who support it
	 * 
	 * @memberOf module:articleManager.$.editable.types
	 * @type Object
	 */
	$.editable.addInputType('numeric', {
		element : function(settings, original) {
			var input = $('<input type="number">');
			$(this).append(input);
			return(input);
		},
		plugin : function(settings,original) {
			$(original).removeClass('changesSaved');
		}
	});
	/**
	 * @name currency
	 *
	 * @description 
	 * Positive numeric with 2 decimal places
	 * 
	 * @memberOf module:articleManager.$.editable.types
	 * @type Object
	 */
	$.editable.addInputType('currency', {
		element : function(settings, original) {
			var input = $('<input type="number" step="0.01" min="0">');
			$(this).append(input);
			return(input);
		},
		plugin : function(settings,original) {
			$(original).removeClass('changesSaved');
		}
	});

	/**
	 * @name date
	 *
	 * @description 
	 * show datepicke.
	 * 
	 * @memberOf module:articleManager.$.editable.types
	 * @type Object
	 */
	$.editable.addInputType('date', {
		element : function(settings, original) {
			var input = $('<input type="text">');
			$(this).append(input);
			return(input);
		},
		plugin: function(settings,original) {
			$(this).find('input').datepicker($.extend({},AMdefaults.datepicker,{dateFormat:settings.datePicker}))
	    	.closest('td').removeClass('changesSaved');
		}
	});
	// boolean

	/**
	 * @name boolean
	 *
	 * @description 
	 * Hidden input field with values `1` or `0` and control `checkbox
	 * 
	 * @memberOf module:articleManager.$.editable.types
	 * @type Object
	 */
	$.editable.addInputType('boolean', {
		element : function(settings, original) {
			var input = $('<input type="hidden" >');
			$(this).append(input).append('<input type="checkbox" name="checkMe" value="1"/>');
			return(input);
		},
		content :  function(string, settings, original) {
			var oTable = $(original).closest('table').dataTable(),
				pos = oTable.fnGetPosition(original),
				data = oTable.fnGetData(original),
				isChecked = oTable.fnSettings().aoColumns[pos[2]].oBooleanFormat.reverse[data];
			$(this).find('input[type=checkbox]').attr('checked', isChecked);
		},
		submit : function ( settings, original ) {
			var val = $(this).find('input[type=checkbox]').is(':checked') ? 1 : 0;
			$(this).find('input[type=hidden]').val(val);
		},
		plugin: function(settings,original) {
			$(this)
			.find('input').uniform()
			.closest('td').removeClass('changesSaved')
		}
	});

}


/** 
* Add some jquery validation rules
*/
if ('validator' in $) {
	/**
	 * Some custom jquery Validator methods
	 * @namespace $.validator
	 * @memberOf module:articleManager
	 */
	
	/**
	 * @name  listLen
	 * @memberOf module:articleManager.$.validator
	 * @type {Function}
	 */
	$.validator.addMethod('listLen',function(value, element, params){
		var length = clik.listLen(value);
		return this.optional(element) === true || length >= params[0] && length <= params[1];
	},'This input must contain between {0} and {1} elements');


	/**
	 * @name  regex
	 * @memberOf module:articleManager.$.validator
	 * @type {Function}
	 */
	$.validator.addMethod('regex',function(value, element, regexp) {
		var re = new RegExp(regexp);
		return this.optional(element) || re.test(value);
	},'Please check your input.');

	/**
	 * @name clientside
	 * @type {Function}
	 * @description 
	 * Adds CLIENTSIDE validation compatible with onvalidate on `cfinput`
	 *
	 * Use this by providing the following attributes to the `cf_recordfield` tag:
	 *
	 * @example
	 * <cf_recordfield
	 *   validation = 'clientside'
	 *   message    = '[string]'       <!--- Message to display if validation fails --->
	 *   onvalidate = '[string]'       <!---  function to call. this functions received the input element, the form element and the current value as  
	 *                                 arguments (compatible with cfinput) and must return true|false
	 *                                 You can use namespaces in the functionname (e.g clik.validate.doSomething) --->
	 * >
	 * 
	 * @memberOf module:articleManager.$.validator
	 */
	$.validator.addMethod('clientside',function(value,element,functionName){
		var namespaces = functionName.split("."),func;
		for(var i = 0; i < namespaces.length; i++) {
			func = window[namespaces[i]];
		}
		console.log(func);
		return /*this.optional(element) || */func.apply(element,[$(element).closest('form')[0],element,value]);
	})
	/**
	 * @name pattern
	 * @type {Function}
	 * @description 
	 * simple regex based validation
	 * 
	 * use this by providing the following attributes to the cf_recordfield tag:
	 * 
	 * @example
	 * <cf_recordfield
	 *   validation = 'pattern'
	 *   message    = '[string]'    <!--- Message to display if validation fails --->
	 *   pattern    = 'string]'     <!--- the pattern to validate. Ensure this conforms to BOTH coldfusion and JS regex syntax
	 *                              as check is also performed server side --->
	 * >
	 *                              
	 * @memberOf module:articleManager.$.validator
	 */
	$.validator.addMethod('pattern',function(value,element,regexp){
		var re = new RegExp(regexp);
	    return this.optional(element) || re.test(value);
	});
	
	/**
	 * @name integer
	 * @type {Function}
	 * @description 
	 * integer validation (use type=integer)
	 *
	 * @memberOf module:articleManager.$.validator
	 */
	$.validator.addMethod('integer',function(value,element,params){
		return this.optional(element) || value.match(/^\-?\d+$/)
	},'Please enter an integer number.');
	
	/**
	 * @name date
	 * @type {Function}
	 * @description 
	 * date validation (use type=date)

	 * @memberOf module:articleManager.$.validator
	 */
	$.validator.addMethod('date',function(value,element,params){
		if( this.optional(element) ) return true;
		var aoDate,           // needed for creating array and object
	        ms,               // date in milliseconds
	        dateValidateOptions = params || AMdefaults.dateValidateOptions,
	        month, day, year; // (integer) month, day and year
	    // split input date to month, day and year
	    aoDate = value.split(dateValidateOptions.separator);
	    // array length should be exactly 3 (no more no less)
	    if (aoDate.length !== 3) {
	        return false;
	    }
	    // define month, day and year from array (expected format is d/m/yyyy)
	    // subtraction will cast variables to integer implicitly
	    day = aoDate[dateValidateOptions.day] - 0;
	    month = aoDate[dateValidateOptions.month] - 1; // because months in JS start from 0
	    year = aoDate[dateValidateOptions.year] - 0;
	    // test year range
	    if (year < 1000 || year > 3000) {
	        return false;
	    }
	    // convert input date to milliseconds
	    ms = (new Date(year, month, day)).getTime();
	    // initialize Date() object from milliseconds (reuse aoDate variable)
	    aoDate = new Date();
	    aoDate.setTime(ms);
	    // compare input date and parts from Date() object
	    // if difference exists then input date is not valid
	    if (aoDate.getFullYear() !== year ||
	        aoDate.getMonth() !== month ||
	        aoDate.getDate() !== day) {
	        return false;
	    }
	    // date is OK, return true
	    return true;
	},function(params,element) {
		var op = params || AMdefaults.dateValidateOptions,
			s = op.separator, sortable = [],map={month:'MM',day:'DD',year:'YYYY'},
			mask = '';
		/* get the month/day/year in the correct order */
		for( var i in op ) {
			if( i in map ) sortable[op[i]]=i;
		}
		/* now piece together the mask */
		for( var j in sortable ) {
			mask += mask !== '' ? op.separator+map[sortable[j]] : map[sortable[j]];
		}
		return 'Please enter a date in the form '+mask;
	});
	/**
	 * @name file_required
	 * @type {Function}
	 * @description 
	 * required files need special validation: filename mustn't be empty AND delete mustn't be 1
	 * use this by providing the following attributes to the cf_recordfield tag
	 *
	 * @example
	 * <cf_recordfield
	 *   type = 'file'
	 *   required = 'true'
	 * >
	 *
	 * @memberOf module:articleManager.$.validator
	 */
	$.validator.addMethod('file_required',function(value,element,params){
		var name = $(element).attr('name'),
			del = $(element).siblings('[name='+name+'_delete]').val();
		return (value != '' && del != 1);
	});
	/**
	 * @name bulk_change_modifier
	 * @type {Function}
	 * @description 
	 * Method to validate the bulk change modifier: This will be required if the value of the connected field is not empty
	 *
	 * @memberOf module:articleManager.$.validator
	 */
	$.validator.addMethod('bulk_change_modifier',function(value,element){
		var fieldName = $(element).attr('name').replace(/_change$/,''),
			$field = $(element).closest('form').find('[name='+fieldName+']'),
			type = clik.getPrefixedClass($(element).closest('.fieldContainer').attr('class'),'type_'),
			fieldValue;
		switch( type ) {
			case 'bit':
			case 'boolean':
			case 'radio':
			case 'checkbox':
				$field = $field.filter(':checked');
				break;	
		}
		fieldValue = $field.val() || '';
		return !(value == '' && fieldValue != '');
	},'Choose an operation or unset the values')
	
}
/**
 * validate change form: enable and disabled client side validation if the modifier is null/not null
 * @param  {obj} rules rules obj.
 * @return {jQuery}       $(this)
 * @memberOf module:articleManager.$.fn
 */
$.fn.changeValidate = function(rules) {
	var $form = $(this);
	$form.on('change.changeValidate','select[name$=_change]',function(e){
		var fieldName = $(this).attr('name').replace(/_change$/,''),
			$field = $form.find('[name='+fieldName+']'),
			fieldRules = rules[fieldName];
		if( $field.length && fieldRules ) {
			if ( $(this).val() != '' ) {
				$field.rules('add',fieldRules);
			} else {
				var rulesStr = ''; // unfortunately 'remove' expects rule names as a space separated string ...
				$.each(fieldRules,function(name,details){
					rulesStr += ' '+name;
				})
				$field.rules('remove',rulesStr);
			}
		}
	});
	return $form;
}

if( 'dataTableExt' in $.fn ) {
/**
	 * Various dataTables extensions
	 * @see  module:dataTables
	 * @namespace $.fn.dataTableExt
	 * @memberOf module:articleManager
	 */

	/**
	 * Reload table data
	 * @param  {obj} oSettings      The dataTables settings (you don't need to pass this in when calling)
	 * @param  {obj} data           The data for the table must contain at least the following keys
	 *                              aaData - the data to display
	 *                              LISTEDIDS - the string of listed ids to update hidden input field
	 * @param  {string} am_action_menu (optional) the string for the new am_action_menu
	 * @param  {obj} editable       (optional) pass in if you want to make the table editable again. needs to have two keeys:
	 *                              URL - the url to submit to
	 *                              DEF - the name of the element in the window scope that would contain the editable definition
	 * @return {void}           
	 *
	 * 
	 * @memberOf module:articleManager.$.fn.dataTableExt
	 */
	$.fn.dataTableExt.oApi.fnReload = function(oSettings,data,am_action_menu,editable) {
		// clear table
		this.data('ticked_records',[]).fnClearTable(this);
		this.oApi._fnProcessingDisplay(oSettings, true );
		var that = this, opt;

		/* add data to table */
		for (var i=0; i<data.aaData.length; i++)
		{
		that.oApi._fnAddData(oSettings, data.aaData[i]);
		}

		oSettings.aiDisplay = oSettings.aiDisplayMaster.slice();
		// redraw table
		that.fnDraw(false);
		// if aaSorting is provided this is a tab request: resort and hide/show columns as needed
		if( 'aaSorting' in data ) {
			$.each(data.aoColumns,function(i,col) {
				if( 'bVisible' in col ) that.fnSetColumnVis(i,col.bVisible);
			});
			that.fnSort( data.aaSorting );
		}
		that.oApi._fnProcessingDisplay(oSettings, false);
		// replace action_menu if passed in
		if( am_action_menu ) {
			$('#am_action_menu').replaceWith(am_action_menu);
		}
		// make new table editable
		if( editable ) {
			opt = $.extend(
				{ sUpdateURL : editable.URL },
				AMdefaults.editable,
				window[editable.DEF]
			);
			that.makeEditable(opt);
		}
		// update hidden input with listed ids
		$(this).closest('form').find('input[name=listedids]').val(data.LISTEDIDS);
	}

	/**
	* Set the point at which DataTables will start it's display of data in the
	* table.
	*
	* @summary Change the table's paging display start.
	* @author [Allan Jardine](http://sprymedia.co.uk) with modifications by MT
	* @deprecated
	*
	* @param {integer} iStart Display start index. 
	* @param {boolean} [bRedraw=false] Indicate if the table should do a redraw or not.
	*
	* @example
	* var table = $('#example').dataTable();
	* table.fnDisplayStart( 21 );
	* 
	* @example
	* var table = $('#example').dataTable();
	* table.fnDisplayStart( ); // returns current value
	 * @see  {module:dataTables}
	 * 
	 * @memberOf module:articleManager.$.fn.dataTableExt
	*/

	$.fn.dataTableExt.oApi.fnDisplayStart = function ( oSettings, iStart, bRedraw )
	{
	    if( typeof iStart == 'undefined' ) {
	    	return oSettings._iDisplayStart;
	    }

	    if ( typeof bRedraw == 'undefined' ) {
	        bRedraw = true;
	    }

	    var max = oSettings.fnRecordsDisplay();

	    if( iStart >= max ) {
	    	iStart = max - oSettings._iDisplayLength;
	    }

	    if( iStart < 0 ) iStart = 0;

	    oSettings._iDisplayStart = iStart;

	    if ( oSettings.oApi._fnCalculateEnd ) {
	        oSettings.oApi._fnCalculateEnd( oSettings );
	    }

	    if ( bRedraw ) {
	        oSettings.oApi._fnDraw( oSettings );
	    }
	};

	/**
	 * @name oSort
	 * @type {Object}
	 * @description Provide sorting for a range of date / datetime locales
	 * 
	 * @see  module:dataTables.DataTable.models.ext.oSort
	 *
	 * @memberOf module:articleManager.$.fn.dataTableExt
	 */
	jQuery.extend( jQuery.fn.dataTableExt.oSort, {
	    "datetime-uk-pre": function ( a ) {
	        return AMdefaults['datetime-generic-pre'](a,{
	        	separator:'/',
	        	day:0,
	        	month:1,
	        	year:2
	       	})
	    }, 
	    "datetime-uk-asc": AMdefaults['datetime-generic-asc'], 
	    "datetime-uk-desc": AMdefaults['datetime-generic-desc'],

	    // some mask-specific sorts

	    "datetime-dd/mm/yy-pre": function ( a ) {
	        return AMdefaults['datetime-generic-pre'](a,{
	        	separator:'/',
	        	day:0,
	        	month:1,
	        	year:2
	       	})
	    },
	    "datetime-dd/mm/yy-asc": AMdefaults['datetime-generic-asc'], 
		"datetime-dd/mm/yy-desc": AMdefaults['datetime-generic-desc'],

	    "datetime-mm/dd/yy-pre": function ( a ) {
	        return AMdefaults['datetime-generic-pre'](a,{
	        	separator:'/',
	        	day:1,
	        	month:0,
	        	year:2
	       	})
	    },
	    "datetime-mm/dd/yy-asc": AMdefaults['datetime-generic-asc'],
	    "datetime-mm/dd/yy-desc": AMdefaults['datetime-generic-desc'],

	    "datetime-yy/dd/mm-pre": function ( a ) {
	        return AMdefaults['datetime-generic-pre'](a,{
	        	separator:'/',
	        	day:1,
	        	month:2,
	        	year:0
	       	})
	    },
	    "datetime-yy/dd/mm-asc": AMdefaults['datetime-generic-asc'],
	    "datetime-yy/dd/mm-desc": AMdefaults['datetime-generic-desc'],

	    "datetime-yy/mm/dd-pre": function ( a ) {
	        return AMdefaults['datetime-generic-pre'](a,{
	        	separator:'/',
	        	day:2,
	        	month:1,
	        	year:0
	       	})
	    },
	    "datetime-yy/mm/dd-asc": AMdefaults['datetime-generic-asc'],
	    "datetime-yy/mm/dd-desc": AMdefaults['datetime-generic-desc'],

	    "datetime-dd.mm.yy-pre": function ( a ) {
	        return AMdefaults['datetime-generic-pre'](a,{
	        	separator:'.',
	        	day:0,
	        	month:1,
	        	year:2
	       	})
	    },
	    "datetime-dd.mm.yy-asc": AMdefaults['datetime-generic-asc'], 
		"datetime-dd.mm.yy-desc": AMdefaults['datetime-generic-desc'],

	    "datetime-mm.dd.yy-pre": function ( a ) {
	        return AMdefaults['datetime-generic-pre'](a,{
	        	separator:'.',
	        	day:1,
	        	month:0,
	        	year:2
	       	})
	    },
	    "datetime-mm.dd.yy-asc": AMdefaults['datetime-generic-asc'],
	    "datetime-mm.dd.yy-desc": AMdefaults['datetime-generic-desc'],

	    "datetime-yy.dd.mm-pre": function ( a ) {
	        return AMdefaults['datetime-generic-pre'](a,{
	        	separator:'.',
	        	day:1,
	        	month:2,
	        	year:0
	       	})
	    },
	    "datetime-yy.dd.mm-asc": AMdefaults['datetime-generic-asc'],
	    "datetime-yy.dd.mm-desc": AMdefaults['datetime-generic-desc'],

	    "datetime-yy.mm.dd-pre": function ( a ) {
	        return AMdefaults['datetime-generic-pre'](a,{
	        	separator:'.',
	        	day:2,
	        	month:1,
	        	year:0
	       	})
	    },
	    "datetime-yy.mm.dd-asc": AMdefaults['datetime-generic-asc'],
	    "datetime-yy.mm.dd-desc": AMdefaults['datetime-generic-desc'],
	    
	    "datetime-dd-mm-yy-pre": function ( a ) {
	        return AMdefaults['datetime-generic-pre'](a,{
	        	separator:'-',
	        	day:0,
	        	month:1,
	        	year:2
	       	})
	    },
	    "datetime-dd-mm-yy-asc": AMdefaults['datetime-generic-asc'], 
		"datetime-dd-mm-yy-desc": AMdefaults['datetime-generic-desc'],

	    "datetime-mm-dd-yy-pre": function ( a ) {
	        return AMdefaults['datetime-generic-pre'](a,{
	        	separator:'-',
	        	day:1,
	        	month:0,
	        	year:2
	       	})
	    },
	    "datetime-mm-dd-yy-asc": AMdefaults['datetime-generic-asc'],
	    "datetime-mm-dd-yy-desc": AMdefaults['datetime-generic-desc'],

	    "datetime-yy-dd-mm-pre": function ( a ) {
	        return AMdefaults['datetime-generic-pre'](a,{
	        	separator:'-',
	        	day:1,
	        	month:2,
	        	year:0
	       	})
	    },
	    "datetime-yy-dd-mm-asc": AMdefaults['datetime-generic-asc'],
	    "datetime-yy-dd-mm-desc": AMdefaults['datetime-generic-desc'],

	    "datetime-yy-mm-dd-pre": function ( a ) {
	        return AMdefaults['datetime-generic-pre'](a,{
	        	separator:'-',
	        	day:2,
	        	month:1,
	        	year:0
	       	})
	    },
	    "datetime-yy-mm-dd-asc": AMdefaults['datetime-generic-asc'],
	    "datetime-yy-mm-dd-desc": AMdefaults['datetime-generic-desc']
	} );
}

/**
 * initalization function for the 'tabs' that can be used to narrow down a record list (or grid) by the 'sortableUnique' column
 * @param  {obj} settings the settings
 * @return {jQuery}    
 * @memberOf module:articleManager.$.fn
 * 
 */
$.fn.amSortTab = function(settings) {
	return $(this).each(function(){
		var $this = $(this),
			defaults = {
				tabLabels : 'ul.tabLabels li',
				activeClass : 'ui-tabs-selected',
				hoverClass : 'ui-state-hover'
			},
			op = $.extend({}, defaults, settings),
			markActiveLabel = function( tabCount ) {
				op.$tabLabels
				.removeClass(op.activeClass)
				.eq(tabCount).addClass(op.activeClass);
			},
			bindLabelEvents = function() {
				$this.on('mouseenter', op.tabLabels, function(event) {
					op.$tabLabels.removeClass(op.hoverClass);
					$(this).addClass(op.hoverClass);
				})
				.on('mouseleave', op.tabLabels, function(event) {
					$(this).removeClass(op.hoverClass);
				})
				.on('click',op.tabLabels,function(e){
					var href=$(this).find('a').attr('href'),
						waiting = clik.delayedAjax('check');
					// make sure that there isn't a request queued
					if( !waiting || confirm(window.onbeforeunload()) ) {
						clik.delayedAjax('cancel');
						markActiveLabel($(this).index());
						switch( op.list_format ) {
							case 'table':
								AM.reloadTableData(href,op.section);
								break;
							case 'grid':
								AM.reloadGrid(href,op.section);
								break;
						};
					}
					return false;
				});
			};
		op.$tabLabels = $this.find(op.tabLabels);
		if( op.selected !== undefined ) {
			markActiveLabel(op.selected);
		}
		bindLabelEvents();
	})
}
/**
 * initalization function for the 'select' box that can be used to narrow down a record list (or grid) by the 'sortableUnique' column
 * @param  {obj} settings the settings
 * @return {jquery}
 * 
 */
$.fn.amSortSelect = function(settings) {
	return $(this).each(function(){
		var $this = $(this),
		defaults = {},
		op = $.extend({}, defaults,settings);
		$this.bind('change',function(e){
			var href = $this.val(),
				waiting = clik.delayedAjax('check');
			// make sure that there isn't a request queued
			if( !waiting || confirm(window.onbeforeunload()) ) {
				clik.delayedAjax('cancel');
				switch( op.list_format ) {
					case 'table':
						AM.reloadTableData(href,op.section);
						break;
					case 'grid':
						AM.reloadGrid(href,op.section);
						break;
				};
			}
			return false;
		})
	});
}

/**
 * Initialise the dialog for article manage record settings
 * @memberOf module:articleManager.$.fn
 * @param {Object} settings 
 */
$.fn.AMInidEditSettingsForm = function(settings){
	var defaults = {
			button: '',
			id:''
		},
		op = $.extend({},defaults,settings);
	return $(this).each(function(){
		var $this = $(this);
		$this.dialog({
			autoOpen: false,
			modal: true,
			open : function(e,ui){
    			$(this).clikInitFormElements();
    		},
    		width: '400px',
    		resizable : false,
			buttons: [{
				text : 'Save',
				'class' : 'dblueBtn',
				click : function() {
					$this.find('form').submit();
				}
			},{
				text : 'Cancel',
				click : function() {
					$this.dialog('close');
				}
			}]
		});
		$(op.button).bind('click.AMInidEditSettingsForm',function(){
			$this.dialog('open');
			return false;
		})
	})
}


/**
 * Our positions map component
 * @memberOf module:articleManager
 * @namespace AM.positionsMap
 */
$.widget('AM.positionsMap',{
	/**                                                                                                                                                                                   
	* @name module:articleManager.AM.positionsMap#options
	* @property  {string} [options.sort_orderInout = 'input[name=sort_order]'] The selector for the sort order field
	* @property {string} [options.field = 'input[name=position_code]'] The selector for the actual field
	* @property {string} [options.initVal = 'auto'] Value with which to initialize the map. (default: auto, i.e. value of associated input element)
	*/     
	options: {
		sort_orderInput : 'input[name=sort_order]',
		field: 'input[name=position_code]',
		initVal : 'auto',
		hideCols: false,
		sort_order: undefined
	},
	/** 
	* function for the initialization of the positions map:
	* Align and resize divs and a-tags inside map, and select the currently active position
	* this function can be called in two variants: either it can be passed an object of options, or a string. 
	*
	 * @name module:articleManager.AM.positionsMap._create
	 * @function
	*/
	_create: function() {
		var self = this;
		
		// store some jQuery references to the corresponding fields
		self.options.$form = self.element.closest('form');
		self.options.$sort_orderInput = self.options.$form.find(self.options.sort_orderInput);
		self.options.$field = self.options.$form.find(self.options.field);

		self.element.find('.hiddenPosition').removeClass('hiddenPosition');
		
		switch(typeof self.options.omit_content_sections) { // this can be either an array of contentsection ids, or a string (or number) with a specific id
			case 'object':
			$.each(self.options.omit_content_sections,function(i,id){
				self.element.find('[id=' + id + '_PM]').find('a.positionMap').addBack().addClass('hiddenPosition');
			})
			break;
			case 'string':
			case 'number':
			self.element.find('[id=' + self.options.omit_content_sections + '_PM]').find('a.positionMap').addBack().addClass('hiddenPosition');
			break;
		}

		self.firstAlign();
		
	},

	/** 
	* Does the original alignment of stuff. out here so it can be called when the tab becomes active
	*
	 * @name module:articleManager.AM.positionsMap.firstAlign
	 * @function
	*/
	firstAlign: function() {
		var self = this;
		//only do something if map is visible and hasn't been initialized before
		if( !self.element.is(':hidden') && !self.initialized) {
			var $lp = self.element.find('[id=logopanel_PM]');

			
			//some resizing if logopanel is shown
			if( $lp.length > 0 ) {
				//if subcol is hidden: hide logopanel and associated panels as well
				if( self.options.hideCols && $.inArray('subcol',hiddenCols) > -1 ) {
					self.element.find('#logopanel_PM,#xpanel_PM,#left_divider_PM,#x_divider_PM')
						.css('display','none');
				} else {
					//adjust topnav and location panels
					self.element.find('#topnav_PM')
						.height($lp.outerHeight())
						.width(self.element.width()-$lp.outerWidth());
					self.element.find('#location_PM')
						.width(self.element.width()-$lp.outerWidth());
				}
			}
			
			//bind click event to a tags
			self.element.delegate('a','click.positionMap',function(e) {
				e.preventDefault();
				self.update( $(this) );
			})
			
			//set flag to ensure scheme is only initialized once.
			self.initialized = true;
		
		
			if (self.options.initVal === 'auto') {
				self.options.initVal = self.options.$field.val();
			}
			//initialize map with correct value
			if( self.element.find('#'+self.options.initVal+'_PM>a').length ) {
				self.element.find('#'+self.options.initVal+'_PM>a').trigger('click.positionMap');
			} else {
				// make sure stuff is aligned, even if (for whatever reason) the current position_code doesn't appear in the map
				self.element.find('div[hascontent]').filter(function(){
					return $(this).children('.contentsection-container').addClass('hidden').length;
				})
				self.alignPositionsTexts();
			}
			//adjust for sort order
			if( self.options.$sort_orderInput.length ) { //if field is provided: attach and trigger change event
				self.options.$sort_orderInput.on('change.positionMap',function() {
					self.adjustSortOrder();
				})
			} else if (self.options.sort_order !== undefined) { //if value is submitted: initialize with this value
				self.adjustSortOrder( self.options.sort_order )
			}
		}
	},

	/**
	*   Update positions map and corrseponding input on click 
	* also adjusts heights, paddings and width to accomodate for larger borders in active class
	 * @name module:articleManager.AM.positionsMap.update
	 * @param {jQuery} $el The link that has been clicked
	 * @function
	*/
	update: function( $el ) {
		var self = this,
			$position = $el.closest('.position'),
			oldVal = self.options.$field.val(),
			val = $position.attr('id').replace('_PM',''),
			$oldAct = self.element.find('.position.active'),
			withChildren = $(),
			showCurrent = function($current) { //recursively show child containers of the currently active container
				if( $current.hasClass('contentsection-container') ) { //recurse up the tree
					showCurrent($current.parent());
				}
				$current
				.children('.position').not('.hiddenPosition')
				.removeClass('hidden');
			}
			;
		if (oldVal != val) {
			self.options.$field.val(val).trigger('change');
		}
		if ($oldAct.length != 0) {
			$oldAct
				.removeClass('active');
		}
		
		// hide irrelevant container content sections
		self.element.find('div[hascontent]').filter(function(){
			return $(this).children('.contentsection-container').addClass('hidden').length;
		})
		//but show those which are child of the current one
		showCurrent($position);
		var oldH = $el.outerHeight(true),
			oldW = $el.outerWidth(true);
		
		$position.addClass('active');
		self.adjustSortOrder();
		self.alignPositionsTexts();
	},



	/**
	 * function to adjust display of label of current position relativ to it's child container content section based on its sort order.
	 * 
	 * @name module:articleManager.AM.positionsMap.adjustSortOrder
	 * @param {jQuery|numeric} sort_order - if jQuery: event object from triggering change. if string: current sort order
	 * @function
	 */ 

	adjustSortOrder: function( sort_order, $current ) {
		var self = this;
		if( !$current ) $current = self.element.find('.position.active');
		var $childContainers = $current.children('.position').not('.hiddenPosition'),
			childCount = $childContainers.length,
			done = false;
		switch( typeof sort_order ) {
			case 'object':
				sort_order = self.element.find(sort_order.target).val();
				self.element.data('sort_order',sort_order);  
			break;
			case 'string': case 'number':
				self.element.data('sort_order',sort_order);
			default:
				sort_order = self.options.$sort_orderInput.val();
		}

		sort_order = parseInt(sort_order);

		if( sort_order !== undefined  ) {
			$childContainers.each(function(){
				var $c = $(this),
					cSort = parseInt($c.attr('sort_order')) || 100000000000000000000000000,
					cID;
				if( cSort > sort_order ) {
					$current.children('a').insertBefore($c);
					done = true;
					return false;
				}  else if ( cSort == sort_order ) {
					$current.children('a').insertBefore($c);
					done = true;
					return false;
				}
					
			})
			if( !done ) {
				$current.children('a').insertAfter($childContainers.last());
			}
		}
	},

	/**
	* Iteratively align text elements vertically centered inside their container divs in positions maps. When done adjust column heights as needed
	* @name module:articleManager.AM.positionsMap#alignPositionsTexts
	* @function
	*/
	alignPositionsTexts: function() {		
		var self = this,
			maincolLeftRightMinHeight = 60,
			wrapH = 0, 
			childMargins = 2, //margin to be inserted around child container content sections;
			expandParent = function($el) {
				var $parent = $el.parent().closest('.position');
				if( $parent.length ) {
					$parent.height( $parent.children().getSum(function(){return $(this).outerHeight(true)}) );
					if( $parent.closest('.positions_map').length ) expandParent($parent);
				}
			},
			/** the function that does the actual work: recursively go through $el and align it, when it's an a-tag, otherwise recurse through it's children. */
			alignPosition = function($el,minHeight) {
				if( $el.length > 1 ) {
					$el.each(function(){alignPosition($(this),minHeight)});
				} else if( $el.is('a') ) {
					var $a = $el,
						$text = $a.children('.nameHolder'),
						$position = $a.closest('.position'),
						$children = $position.children(':not(.hidden)').not($a),
						position_code = $position.attr('id').replace('_PM',''),
						dimensions = {
							children: {
								height: position_code == 'maincol_grid' ? $children.getMax(function(){return $(this).outerHeight(true)}) : $children.getSum(function(){return $(this).outerHeight(true)})
							},
							text: {},
							a: {},
							position: {}
						},
						minHeights = {
							maincol_right : 60,
							maincol_left : 60
						}
						minH = minHeight || minHeights[position_code] || 20;

					dimensions.a.height = Math.max(minH, $a.height() );
					dimensions.text.height = $text.outerHeight(true);

					// reset inline styling
					$a.attr('style','');
					$text.attr('style','');
					$position.attr('style','');

					$a.height(dimensions.a.height);
					$text.css({'position':'absolute',width: $text.width()}).position({
						my: 'center center',
						at: 'center center',
						of: $a
					});
					$position.height($a.outerHeight(true) + dimensions.children.height);
				} else if( $el.children().length ) {
					alignPosition( $el.children('div:not(.hidden)') , minHeight );
					alignPosition( $el.children('a') , minHeight );
				}
			},
			cI = self.element.find('#contentInner_PM');
		self.element.find('*').attr('style','');
		//align queue
		alignPosition(self.element);
		//fix subcol, xcol, wrap and content to maincol height
		wrapH = self.element.find('#maincol_PM,#subcol_PM,#xcol_PM').getMax(function(){return $(this).height()});
		self.element.find('#wrap,#subcol_PM,#xcol_PM,#maincol_PM').height(wrapH);
		alignPosition( self.element.find('#subcol_PM>a,#xcol_PM>a'), wrapH )
		expandParent(self.element.find('#wrap'));
	}
})

