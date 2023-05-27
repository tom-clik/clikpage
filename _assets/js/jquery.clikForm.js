
/**
 * @fileOverview Marries jQuery Form and jQuery Validate to provide validation and AJAX submission, with
 * some default error message positioning
 * 
 * @author Tom Peer
 *
 * @module  clikForm
   @version 1.0
 */

/**
* Return true if the field value matches the given format RegExp
*
* @memberOf module:clikForm
*
* @example $.validator.methods.pattern("AR1004",element,/^AR\d{4}$/)
* @result true
*
* @example $.validator.methods.pattern("BR1004",element,/^AR\d{4}$/)
* @result false
*
* @name $.validator.methods.pattern
* @type Boolean
* @cat Plugins/Validate/Methods
*/
$.validator.addMethod( "pattern", function( value, element, param ) {
	if ( this.optional( element ) && value == '') {
		return true;
	}
	if ( typeof param === "string" ) {
		param = new RegExp( param );
	}
	return param.test( value );
}, "Invalid format." );


/**
* Shorthand for pattern validation of [A-Za-z0-9_]
*
* @example $.validator.methods.pattern("AR1004",element)
* @result true
*
* @example $.validator.methods.pattern("BR1004",element)
* @result false
*
* @name $.validator.methods.code
* @type Boolean
* @cat Plugins/Validate/Methods
*/
$.validator.addMethod("code",function(value,element){
	var re = new RegExp("^[A-Za-z0-9_]*$");
    return (this.optional(element) && value == '') || re.test(value);
},'Please enter only letters, numbers or the underscore character');


(function($){

	/**
	 * Validates a form and submits it through AJAX.
	 *
	 * If the AJAX response is `true` the submission is deemed to have been successfull, and a success message is displayed. 
	 * Else, the AJAX response is deemed to be an object where the keys are the `name`s of the failed form fields, and 
	 * the values are error messages.
	 *
	 * @memberOf module:clikForm
	 * 
	 * @param  {object} ops Options
	 * @param {string} [ops.finish_copy] Success message to show on successfull submission
	 * @param {string} [ops.error_message] Error message to show if submission wasn't successful
	 * @return {jQuery}     Returns `this` for easy chaining
	 */
	$.fn.clikForm = function(ops){
		var defaults = {
				debug: false,
				rules: {},
				message: "Thank you",
				messages: {},
				error_message: "Sorry, an network error occurred"
			},
			options = $.extend({},defaults,ops);

		function showErrors($form, validator, errorMap, errorlist) {
			console.log("Show error running");
			// console.log(errorMap);
			console.log(errorlist);
			// issue here with it showing every error 
			// simple fix of showing only the first won't clear older errors.
			
			let data = $form.serializeData();
			console.log(data);
			for (let field in data) {
				let val = data[field];
				let $input = $form.find("[name=" + field + "]");
				let type = $input.attr("type");
				if ((type && type == "hidden") || $input.is(":hidden")) {
					continue;
				}
				else {
					console.log("type  is ", type);
				}
				let $row = $input.closest(".fieldrow");
				// #DEBUG
				if (options.debug) {
					console.log(field, val);
				}
				// /#DEBUG
				// errorMap may contain only subset of fields
				// This happens when you focus our or keyup or click an invalid
				// field to correct the error
				
				if (! (field in errorMap) && validator.check($input[0])) {
					console.log("removing error");
					$row.removeClass("error").addClass("valid");
					$row.find(".error").remove();
				}
				else {
					$row.find(".error").remove();
					console.log("adding error");
					$row.removeClass("valid").addClass("error");
					$row.append("<div class='error'>" + errorMap[field] +  "</div>");
				}
			}

		}

		return this.each(function(){

			var $cs = $(this), $form = $cs.find('form'), $originalForm = $form.clone(), imageID, validator;
			
			// Allow for contentInner as the actual element
			var $panel = $cs.find('div.contentInner');
			if ($panel.length != 0) {
				$cs = $panel;
			}
			
			// TODO: call these on individual fields with proper options
			$('select').select2();
			
			$('textarea.elastic').elastic();
			
			validator = $form.validate({
				rules: options.rules,
				message: options.message,
				messages: options.messages,
				showErrors: function(errorMap, errorList) {
					showErrors($form, validator, errorMap, errorList);
				},
				debug: options.debug,
				errorPlacement: function(error, element) {
					$errorContainer = $form.find('.validateError[data-field='+element.attr('name')+']');
					if( $errorContainer.length ) {
						error.appendTo( $errorContainer );						
					} else {
						error.insertAfter(element)
					}
					$form.find('#question'+element.attr('name')).first().addClass("error");
				},				
		        unhighlight: function (element,sClass) {
		            $(element)
		            .addClass("valid")
		            .removeClass(sClass);
		            $form.find('#question'+$(element).attr('name')).first().removeClass("error");
		        },
				ignore: ':hidden:not(.ratingList input)', // don't validate hidden inputs, except for rating lists
				submitHandler: function() {
					console.log("test ok");
					$form.ajaxSubmit({
						dataType: 'json',
						beforeSubmit: function(){
							// #DEBUG
							console.log("Form submitted");
							// /#DEBUG
							$form.find(':input').attr('disabled', 'true').css('opacity', 0.3);
						},
						success: function(data, statusText, xhr, $form){
							var qData = {}, msg;
							$form.find(':input').attr('disabled', '').css('opacity', '');
							// #DEBUG
							console.log(data);
							// /#DEBUG
							
							if (data === true || ('OK' in data && data.OK)) {
								
								if (data !== true && 'NEXTPAGE' in data) {
									console.log("loading next page: ", data.NEXTPAGE);
									$cs.html("<div class='loading></div>");
									window.location.href = data.NEXTPAGE;
								}
								else {
									var msg = data.MESSAGE || options.message;	
									console.log("Displaying console message ", msg);
									$cs.html(msg);
								}
							}
							else {
								// Show error messages:
								// if we fail, we get back an object where the keys are the field names
								// and the values are the error messages.
								$cs.find('>.error').remove();
								msg = 'MESSAGE' in data ? data.MESSAGE : options.error_message;
								// recaptcha response is sent separately, so we need to write it out manually
								if( ('g-recaptcha-response' in data) && data['g-recaptcha-response'] !== '' ) {
									$form.find('#recaptcha_widget_'+data['g-recaptcha-response'])
									.find('>.validateError').remove().end()
									.append('<div class="validateError"><p> '+data[data['g-recaptcha-response']]+'</p></div>');
								}
								$cs.prepend('<div class="error">' + msg + '</div>');
								
								showErrors( $form, validator, data);

								//captcha must be reloaded each time, as only valid once
								if ('grecaptcha' in window) {
									console.log("reloading captcha");
									grecaptcha.reset();
								}
								// #DEBUG
								else {
									console.log("captcha not defined");
								} 
								// /#DEBUG
								$cs.find(':input:disabled').attr('disabled', false).css('opacity', 1);
							}
						},
						error : function (jqXHR){
							var errorID, msg = options.error_message;
							if( typeof jqXHR.getResponseHeader === 'function' && jqXHR.getResponseHeader('errorID')) {
								msg += '<div class="validateError">Error ID: '+ jqXHR.getResponseHeader('errorID')+'</div>';
							}
							$cs.html(msg);
						}
					});
				}
			});
			
		});
	};
}(jQuery));
