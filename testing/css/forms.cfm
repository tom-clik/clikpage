<!DOCTYPE html>
<html>
<head>
	<title>Forms tests</title>
	<!--- why are we explicitly linking here in the cfm version?
		Use the static object to check it works... --->
	<link rel="stylesheet" href="/_assets/css/reset.css">
	<link rel="stylesheet" href="/_assets/css/fonts/google_icons.css">
	<link rel="stylesheet" href="/_assets/css/fonts/fonts_local.css">
	<link rel="stylesheet" href="/_assets/css/icons.css">
	<link rel="stylesheet" href="/_assets/css/grids.css">
	<link rel="stylesheet" href="/_assets/css/forms.css">
	<link rel="stylesheet" href="/_assets/css/navbuttons.css">
	<link rel="stylesheet" href="/_assets/css/select2.min.css" />
	
	<script src="/_assets/js/jquery-3.4.1.js"></script>
	<script src="/_assets/js/select2.min.js"></script>
	<script src="/_assets/js/jquery.elastic.1.6.11.js"></script>
	<script src="/_assets/js/jquery.validate.js"></script>
	<script src="/_assets/js/jquery.serializeData.js"></script>
	<script src="/_assets/js/jquery.form.js"></script>
	<script src="/_assets/js/jquery.clikForm.js"></script>

	<meta charset="UTF-8">
	<style>

	#testform {
		max-width: 800px;
		margin:80px auto;
		border:1px solid var(--border-color);
		--field-background-color: white;
		--field-border-color: #aaa;
		--input-padding: 8px;
	}
	.fieldButtons .button {
		border-color:var(--border-color);
		border-width:1px;
		border-style:solid;
		background-color: white;
		padding: 4px 8px;
	}

	.fieldButtons .button:hover {
		background-color:  #efefef;
	}

	#testform .fieldrow:nth-child(even) {
		background-color: #efefef;
	}

	#testform .fieldrow.error {
		border:1px solid red;
	}

	#testform .errMessage {
		color:red;
	}
	</style>
	
</head>
<body>

<body>
<div id="testform" class="form">
	<form action="forms_testapi.cfc?method=testTransaction" method="post">
			<input type="hidden" name="hidden_test" value="hidden_test">
			
			<div class="fieldrow">
				<div class="fieldLabel">
				<label>
					
					Auto grow text

				</label>
				<div class="button"><a><i class="icon-help"></i></a></div>
				</div>
				<div class="field">
					<textarea name="field1" rows="1" class="elastic markitup"></textarea>
				</div>
			</div>
			<div class="fieldrow">
				<div class="fieldLabel">
				<label>
					Email
				</label>
				<div class="button"><a><i class="icon-help"></i></a></div>
				</div>
				<div class="field">
					<input type="text" name="email">
				</div>
			</div>
			<div class="fieldrow">
				<div class="fieldLabel">
				<label>
					
					Label 2

					
				</label>
				<div class="button"><a><i class="icon-help"></i></a></div>
				</div>
				<div class="field">
					<select name="field2" multiple>
						<option></option>
						<option>Test</option>
						<option>Test2</option>
						<option>Test4</option>
						<option>Test5</option>
					</select>
				</div>
			</div>
			<div class="fieldrow">
				<div class="fieldLabel">
				<label>
					
					Label 3

					
				</label>
				<div class="button"><a><i class="icon-help"></i></a></div>
				</div>
				<div class="field checkbox">
					<input type="radio" name="field3" id="field3_1"  value="1"><label for="field3_1">field3_1</label>
					<input type="radio" name="field3" id="field3_2"  value="2"><label for="field3_2">field3_2</label>
					<input type="radio" name="field3" id="field3_3"  value="3"><label for="field3_3">field3_3</label>
					<input type="radio" name="field3" id="field3_4"  value="4"><label for="field3_4">field3_4</label>
				</div>
			</div>
			<div class="fieldrow">
				<div class="fieldLabel">
				<label>
					
					Label 4

					
				</label>
				<div class="button"><a><i class="icon-help"></i></a></div>
				</div>
				<div class="field checkbox">
					<input type="checkbox" name="field4" id="field4_1"  value="1"><label for="field4_1">field4_1</label>
					<input type="checkbox" name="field4" id="field4_2"  value="2"><label for="field4_2">field4_2</label>
					<input type="checkbox" name="field4" id="field4_3"  value="3"><label for="field4_3">field4_3</label>
				</div>
			</div>
			
			<div class="fieldrow">
				<div class="fieldLabel">
				<label>
					
					Label 5

				</label>
				<div class="button"><a><i class="icon-help"></i></a></div>
				</div>
				<div class="field">
					<select name="field5">
						<option></option>
						<option>Test</option>
						<option>Test2</option>
						<option>Test4</option>
						<option>Test5</option>
					</select>
				</div>
			</div>

			<div class="fieldrow">
				<div class="fieldLabel">
				<label>
					&nbsp;
				</label>
				<div class="button"><a><i class="icon-help"></i></a></div>
				</div>
				<div class="field checkbox">
					<input type="checkbox" name="field6" id="field6_1" value="1"><label for="field6_1">field6_1</label>
					<!-- <input type="checkbox" name="field6" id="field6_2" value="2"><label for="field6_2">field6_2</label> -->
				</div>
			</div>

			<div class="fieldrow">
				<div class="fieldLabel">
					<label>
						Label 7
					</label>
					<div class="button"><a><i class="icon-help"></i></a></div>
				</div>
				<div class="field">
					<input type="text" name="field7" id="field7_1" value="">
				</div>
			</div>

			<div class="fieldButtons">
				<div class="fieldSpace">
				<label>
					
					&nbsp;

				</label>
				</div>
				<div>
					<div class="button">
						<input type="button" value="Submit"  onclick="getOk(this);">
					</div>
					<div class="button">
						<input type="button" value="Get validation errors" onclick="getErrors(this);">
					</div>
					<div class="button">
						<input type="button" value="Network errors" onclick="failError(this);">
					</div>
				</div>
			</div>
		</form>
</div>
<script type="text/javascript">
	$(document).ready(function() {
		
		$("#testform").clikForm({
			debug:false,
			rules : {
				  email: {
			    	required: true,
			    	email: true
			    },
			    field2: {
			    	required: true,
			    	minlength: 2,
			    	maxlength: 3
			    },
			    field3: {
			    	required: true			    	
			    },
			    field6: {
			    	required: true		
			    },
			    field7: {
			    	required: true,
			    	code: true		
			    }
			},
			messages: {
		        email: {
		            required: 'Email address is required',
		            email: 'Please enter a valid email address'
		        },
		        field2: 'Please select 2 or 3 items',
		        field3: "select some values",
		        field6: "Please tick you agree to our terms and conditions"
		    }

		});

	});

function getOk(button) {
	button.form.action = "forms_testapi.cfc?method=testTransaction";
   	
    $(button.form).submit();
}

function getErrors(button) {
	button.form.action = "forms_testapi.cfc?method=testInvalid";
    $(button.form).submit();
}

function failError(button) {
	button.form.action = "gingganggooly.json";
    $(button.form).submit();
}

</script>


</body>
</html>
