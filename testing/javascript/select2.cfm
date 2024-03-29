<!--

# Select 2 Demo Page

## Synopsis


-->

<cfset select2 = new select2_testapi()>
<cfset options = select2.getOptions()>

<!DOCTYPE html>
<html>

<head>
	<link rel="stylesheet" type="text/css" href="/_assets/css/reset.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/grids.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/forms.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/select2.min.css" />
	<style>
	body {
		padding:20px;
		background-color: #ccc;
	}

	#ubercontainer {
		background-color: #fff;
		border: 1px solid #000;
		padding:20px;
		margin: 0 auto;
		max-width: 660px;
	}

	.section {
		margin:20px;
		border: 1px solid #000;
		padding:20px;
	}
	.form {
		
		
	}
	</style>
</head>

<body>

	<div id="ubercontainer">

		<form class="form">
			
			<div class="fieldrow">
				<label>basic single</label>

				<field>
					<select name="js-example-basic-single" class="basic">
						<cfoutput>#options#</cfoutput>
					</select>
				<field>
			</div>
			<div class="fieldrow">
				<label>basic multiple</label>

				<field>
					<select name="js-example-basic-multiple" class="basic" multiple>
						<cfoutput>#options#</cfoutput>
					</select>
				<field>
			</div>
			<div class="fieldrow">
				<label>basic multiple placeholder</label>

				<field>
					<select name="js-example-basic-multiple-placeholder" class="basic" multiple>
						<cfoutput>#options#</cfoutput>
					</select>
				<field>
			</div>
			<div class="fieldrow">
				<label>basic multiple max 3</label>

				<field>
					<select name="js-example-basic-multiple-max" class="basic" multiple>
						<cfoutput>#options#</cfoutput>
					</select>
				<field>
			</div>
			<div class="fieldrow">
				<label>Ajax</label>

				<field>
					<select name="js-example-ajax" class="basic" multiple>
						
					</select>
				<field>
			</div>

		</form>
	</div>

</body>

<script src="/_assets/js/jquery-3.4.1.js" type="text/javascript" charset="utf-8"></script>
<script src="/_assets/js/select2.min.js"></script>

<!---
		maximumInputLength	integer	0	Maximum number of characters that may be provided for a search term.
maximumSelectionLength	integer	0	The maximum number of items that may be selected in a multi-select control. If the value of this option is less than 1, the number of selected items will not be limited.
minimumInputLength	integer	0	Minimum number of characters required to start a search.
minimumResultsForSearch	integer	
--->
<script>


	$(document).ready(function() {
		
		$('select.basic').select2();

		$('select[name=js-example-basic-multiple-placeholder]').select2({
		  placeholder: 'Select some options option'
		});

		$('select[name=js-example-basic-multiple-max]').select2({
		  maximumSelectionLength: 3
		});
		
		$('select[name=js-example-ajax]').select2({
			ajax: {
			    url: 'select2_testapi.cfc?method=search',
			    dataType: 'json'
			},
			minimumInputLength:3
    	});

	});

</script>

</html>
