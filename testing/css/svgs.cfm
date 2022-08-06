<!---

# icons.cfm

Testing out some button styling using icons instead of svgs

This turned out to work quite well. If you apply a class to the "use" element of an inline
SVG that references an external file, you can apply simple cascaded styles.

You have to match the viewBox but apart from that it's all good.

--->

<cfsavecontent variable="leftArrow">
<svg  
	viewBox="0 0 197.4 197.4"><use href="graphics/left_arrow.svg#left_arrow" class="inlinebuttonSVG fillme"/></svg>
</cfsavecontent>

<!--- <cfsavecontent variable="leftArrow">
<svg  xmlns="http://www.w3.org/2000/svg" 
	viewBox="0 0 16 16"><use href="graphics/chevron_left.svg#chevron_left" class="inlinebuttonSVG fillme"/></svg>
</cfsavecontent>
 --->

<cfsavecontent variable="rightArrow">
<svg version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" x="0px" y="0px"
	 viewBox="0 0 223.413 223.413">
	 <use href="graphics/right_arrow.svg#right_arrow" x="10" class="inlinebuttonSVG fillme" />
	</svg>
</cfsavecontent>


<cfset dataImage = toBase64(Trim(leftArrow))>


<html>
<head>
	<title>Icon Tests</title>
	<style>

div.button a i {
	text-decoration: none;
	font-style: inherit;
	font-size: inherit;
	display:block;
	background-size: 80% 74%;
	background-position: 50% 50%;
	background-repeat: no-repeat;
	/*height:1.4em;*/
	height:2.2em;
	width:1.4em;
	background-color:#aaa;
	border:1px solid #333;
}

div.button a:hover i {
	background-color:#ccc;
}

div.button.prev a i {
	background-image:url('graphics/left_arrow.svg');
	background-position: 46% 50%;
}

div.button.prev a:hover i {
	background-image:url('graphics/left_arrow_hi.svg');
}

div.button.next a i {
	background-image:url('graphics/right_arrow.svg');
	background-position: 54% 50%;
}

div.button.next a:hover i {
	background-image:url('graphics/right_arrow_hi.svg');
}

div.button.prev  {
	text-align: left;
}

div.button.next {
	text-align: right;
}

div.button span {
	font-style: italic;
	display: block;
	line-height: 1em;
}

div.button a:hover span {
	text-decoration: underline;
}


a.test:hover .line {
	fill:red;
}

div.inlinebutton a {
	display: grid;
	align-items: center;
	grid-template-columns: min-content auto;
	grid-template-areas: "button label";
	grid-gap:12px;
}


div.inlinebutton.next a {
	grid-template-columns: auto min-content ;
	grid-template-areas: "label button"
}




div.button div {

	grid-area:button;
}

div.button span {
	grid-area:label;
	line-height: 1;
}

div.inlinebutton div {
	width:24px;
	height:32px;
	padding:4.8px 0px ;
	background-color:#aaa;
		border:1px solid #333;

}

div.inlinebutton svg {
	width:100%;
	height:100%;
}

div.inlinebutton a:hover div {
	background-color:#ccc;
}

div.inlinebutton a:hover .inlinebuttonSVG {
	fill:#ff00ff;
	stroke:#ff00ff;
}

div.rounded.next {
	float:right;
}

div.rounded a {
	display:block;
	-webkit-border-radius: 4px;
	-moz-border-radius: 4px;
	border-radius: 4px;
	width:20px;
	height:20px;
	padding:4px;
	border:1px solid #333;
	
background: #4c4c4c; /* Old browsers */
background: -moz-linear-gradient(top,  #4c4c4c 0%, #131313 100%); /* FF3.6+ */
background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#4c4c4c), color-stop(100%,#131313)); /* Chrome,Safari4+ */
background: -webkit-linear-gradient(top,  #4c4c4c 0%,#131313 100%); /* Chrome10+,Safari5.1+ */
background: -o-linear-gradient(top,  #4c4c4c 0%,#131313 100%); /* Opera 11.10+ */
background: -ms-linear-gradient(top,  #4c4c4c 0%,#131313 100%); /* IE10+ */
background: linear-gradient(to bottom,  #4c4c4c 0%,#131313 100%); /* W3C */
filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#4c4c4c', endColorstr='#131313',GradientType=0 ); /* IE6-9 */
}


div.rounded a:hover {
	
background: #131313; /* Old browsers */
background: -moz-linear-gradient(top,  #131313 0%, #4c4c4c 100%); /* FF3.6+ */
background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#131313), color-stop(100%,#4c4c4c)); /* Chrome,Safari4+ */
background: -webkit-linear-gradient(top,  #131313 0%,#4c4c4c 100%); /* Chrome10+,Safari5.1+ */
background: -o-linear-gradient(top,  #131313 0%,#4c4c4c 100%); /* Opera 11.10+ */
background: -ms-linear-gradient(top,  #131313 0%,#4c4c4c 100%); /* IE10+ */
background: linear-gradient(to bottom,  #131313 0%,#4c4c4c 100%); /* W3C */
filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#131313', endColorstr='#4c4c4c',GradientType=0 ); /* IE6-9 */
}

div.rounded .fillme {
	fill:white;
}

div.rounded a:hover .fillme {
	fill:#6d6d6d;
	fill-opacity:1;
}

div.rounded svg {
	width:100%;
	height:100%;
}

.inlinebutton {
	width:260px;
	background-color: #cdcdcd;

}


.iconset {
	display: grid;
	grid-gap: 4px;
	align-content: center;
	justify-content: center;
	grid-auto-flow: column;
}

.iconset {
	padding:12px 0;
}


.icon svg {
    width: 100%;
    height: 100%;
}

.social a {
	width:62px;
	height:62px;
	display: inline-block;
}

.social a:hover {
	fill:  #cdcdcd;
}

	</style>

</head>


<body>

<h1>SVG Button Tests</h1>

<p>You can apply overal styling to external svgs</p>


<table>

	<cfoutput>
	<tr>
		<td width="120"><div class="button inlinebutton prev"><a><div>#leftArrow#</div><span>Previous</span></a></td>
		<td><div class="button inlinebutton next"><a><div>#rightArrow#</div><span>Next</span></a></td>
	</tr>
	
	<tr>
		<td><div class="rounded"><a>
<div>#leftArrow#</div></a>
</div>	</td>
<td><div class="rounded next"><a>
<div>#rightArrow#</div></a>
</div></td>
</tr>
	</cfoutput>

</table>


</ol>
<cfoutput>
<div id="roundedset" class="iconset">
<div class="rounded icon"><a>
#leftArrow#</a></div>
<div class="rounded icon"><a>
#rightArrow#</a></div>
</cfoutput>
<div class="rounded icon"><a>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 408 408">
	<use href="graphics/thumbnails.svg#thumbnails"  class="fillme"/>
	</svg></a></div>
<div class="rounded icon"><a>
	<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 283.922 283.922">
	<use href="graphics/popup.svg#popup"  class="fillme"/>
	</svg>
</a></div>
<div class="rounded icon"><a>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 357 357">
	<use href="graphics/close47.svg#close" class="fillme"/>
	</svg></a></div>
</div>

<div id="socialmedia" class="iconset">
	<div class="social icon"><a>
	<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">
		<use href="graphics/social/twitter.svg#twitter" class="fillme"/>
		</svg></a></div>
		<div class="social icon"><a>
	<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">
		<use href="graphics/social/instagram.svg#instagram" class="fillme"/>
		</svg></a></div>
		<div class="social icon"><a>
		<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">
		<use href="graphics/social/facebook.svg#facebook" class="fillme"/>
		</svg></a></div>

		<div class="social icon"><a>
		<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">
		<use href="graphics/social/whatsapp.svg#whatsapp" class="fillme"/>
		</svg></a></div>


</div>

</body>

</html>

