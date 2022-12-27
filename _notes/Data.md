# Data

All information is a site is defined as data. 

## Data types

A "data type" defines the fields available to show on a page. Some fields are standard. They are all based on a standard data record, and can extend this with custom field definitions.

### Standard fields

| Field             | Description
|-------------------|--------------------------
| id*               | Unique code or number for the record 
| title*            | Title of the record     
| short_title       | A shorter title to use in e.g. menu for sections
| description       | Short text description of the record           
| detail            | Long description of the record        
| image             | Image (see [](images.md))     
| tags              | Tags for this record    
| live              | Yes/No field indicating the content is live     
| pubdate           | Optional datetime field for sorting (or display)               
| sort_order        | Numerical field to use for custom sort orders          

### Defining custom fields

Any other required fields can be defined as custom fields. Each field can have the following properties.

| Property | Description
|----------|----------------------
| name*    | Unique code for field 
| label    | Optional display label  
| type     | Field type. Default is `text`
| default  | Default value for field    
| values   | List values for list or multi fields   

#### Standard types

The default type is a text field. This should be used for most data unless you need to search or filter on it.

| Type     | Description
|----------|------------------
| Text     | Simple text field. 
| Numeric  | Number field     
| Boolean  | yes/no field     
| date     | Date time field
| list     | One of a list of options as specified in "values"
| multi    | Multiple selections from a list of options as specified in "values"   
| image    | Image field   

#### Image fields

The image field will inherit the settings from the main record. To override this, use image_settings to specify a set of image settings.

#### Array fields

An "array" type can have its own field definitions.

## Data set

A data set is defined using either a search criteria or a specific set of record IDs. The latter approach is discouraged unless you have a separate system for maintaining your data.

