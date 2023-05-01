# Content sections

Content sections are added to layouts using the `<div>` tag. They should have a unique id for the site and a title. The title is sometimes used on the site, depending on the options for that content section.

```
<content type="title" id="sitetitle">
	<title>Site Title</title>
	<description>The main site title</description>
	<content>{{site.title}}</content>
	<link>{{link.index}}</link>
	<style>
	color:paneltext;
	margin:12 12 12 0;
	font-size:220%;	
	</style>
</content>
```


## Global content sections

It is possible to reuse content items across different templates. To do this, you define global content sections in your settings definition file.

It is best to define the files externally and then miport them. Wildcards can be used to import a folder, e.g.

```
<content import="content/*" />
```

The styling for these can be placed inline or in a stylesheet.

!Always prefer to use template inheritance to reuse content sections where you can. Global content sections should only be used for "library" type content sections such as navigation button.