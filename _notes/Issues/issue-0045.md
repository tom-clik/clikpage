# Parent Data Sets

Previously we had assigned sub sections the same data set as their parent. This isn't going to work and we might need sub sections to have a data set.

Instead, we will have section links. These will be added to any section with a parent and work like record links. In addition to the next and previous links, "parent" will provide a third navigation option, e.g.  `section.parent_link`,`section.parent_title`.

`section.next_link` etc will provide the functionality needed for this.

## Section menus

A dataset can already be added to a content section using the {parent} tag. This can be used for a section menu.

```
<dataset tag="{parent}" type="sections"></dataset>
```

## Implementation

When the section is checked for data (see `site.loadSectionData()`) we also add the section links. This probably isn't the right place to do it.

It checks the parent section for data and then adds the links accordingly using a similar method to the record links.

