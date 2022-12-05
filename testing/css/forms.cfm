<!DOCTYPE html>
<html>
<head>
	<title>Forms tests</title>
	<link rel="stylesheet" href="/_assets/css/reset.css">
	<link rel="stylesheet" href="/_assets/css/fonts/fonts_local.css">
	<link rel="stylesheet" href="/_assets/css/forms.css">
	<link rel="stylesheet" href="/_assets/css/navbuttons.css">
	<link rel="stylesheet" href="/_assets/css/select2.min.css" />
	
	<script src="/_assets/js/jquery-3.4.1.js"></script>
	<script src="/_assets/js/jquery.validate.js"></script>
	<script src="/_assets/js/jquery.form.js"></script>
	<script src="/_assets/js/select2.min.js"></script>
	<script src="/_assets/js/jquery.elastic.1.6.11.js"></script>
	<script src="/_assets/js/jquery.clikForm.js"></script>


	<meta charset="UTF-8">
	<style>

	#testform {
		max-width: 800px;
		margin:80px auto;
		border:1px solid var(--border-color);
		background-color: #efefef;
		--field-background-color: white;
		--field-border-color: #aaa;
		--input-padding: 8px;
	}

	.button {
		--button-border-color:var(--border-color);
		--button-border-width:1px;
		--button-border-style:solid;
		--button-background-color: white;
	}

	#testform .fieldrow:nth-child(even) {
		background-color: #e3e3e3;
	}
	</style>
	
</head>
<body>

<body>
<div id="testform" class="form">
<form method="post" action="forms_testapi.cfc?method=testTransaction">


	<div class="fieldrow">
		<label>
			
			Label 1

			<div class="button"><a class="icon icon-help"></a></div>
		</label>
		<field>
			<textarea name="field1" class="elastic markitup"></textarea>
		</field>
	</div>
	<div class="fieldrow">
		<label>
			Label 2
			<div class="button"><a class="icon icon-help"></a></div>
		</label>
		<field>
			<select name="field2" multiple>
				<option>Test</option>
				<option>Test2</option>
				<option>Test4</option>
				<option>Test5</option>
			</select>
		</field>
	</div>
	<div class="fieldrow">
		<label>
			
			Label 3

			<div class="button"><a class="icon icon-help"></a></div>
		</label>
		<field class="radio">
			<input type="radio" id="r1" name="field3" /><label for="r1">Radio 1</label>
			<input type="radio" id="r2" name="field3" /><label for="r2">Radio 2</label>
			<input type="radio" id="r3" name="field3" /><label for="r3">Radio 3</label>
			<input type="radio" id="r4" name="field3" /><label for="r4">Radio 4</label>
		</field>
	</div>
	<div class="fieldrow">
		<label>
			
			Label 4

			<div class="button"><a class="icon icon-help"></a></div>
		</label>
		<field class="checkbox">
			<input type="checkbox" id="c1" name="field4" /><label for="c1">Check Box 1</label>
			<input type="checkbox" id="c2" name="field4" /><label for="c2">Check Box 2</label>
			<input type="checkbox" id="c3" name="field4" /><label for="c3">Check Box 3</label>
			<input type="checkbox" id="c4" name="field4" /><label for="c4">Check Box 4</label>
		</field>
	</div>

	<div class="fieldrow">
		<label>
			&nbsp;
		</label>
		<field>
			<div class="button">
				<input type="submit" value="submit">
			</div>
		</field>
	</div>

</form>
</div>
<script type="text/javascript">
	$(document).ready(function() {
		
		$("#testform").clikForm({
			debug:false,
			rules : {
				field1: {
			    	required: true,
			    	email: true
			    },
			    field2: {
			    	required: true,
			    	rangelength: [2, 3]
			    },
			    field3: {
			    	required: true			    	
			    },
			    field4: {
			    	required: true		
			    }
			},
			messages: {
		        field1: {
		            required: 'Email address is required',
		            email: 'Please enter a valid email address'
		        },
		        field2: 'Please select 2 or 3 items',
		        field3: "select some values",
		        field6: "Please tick you agree to our terms and conditions"
		    }

		});
	});

</script>


</body>
</html>
