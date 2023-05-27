# Settings Edit Form

Before we can tackle this we need to start thinking about storage of custom settings.

We should ideally also think about "tracing" settings to enable editability. We need for example to determine where a given setting comes from. This might be the item itself or it might be a scheme.

## WIP

On `imagegrid.cfm` -- testing out replacing the stylesheet dynamically. Want to create an API to receive the form request, save the new CSS and reload dynamically.

## Custom settings

These would be stored as a json file. They would just be struct appended to the data that's loaded from the files. 

It might be nice to export these to use the system for our own design materials but that would be another project.

We need to customise schemes, content, and layouts.

## Tracing

Need to check whether there is a custom setting.

## Clearing

Want to be able to clear content section or layout. This would remove any custom settings.

Need to somehow indicate whether there are custom settings from schemes as well.

## Layout schemes

Divs in layouts can have schemes. Need to be sure how we edit these. Do we not allow this? (YES). Remove schemes from layouts and only apply them globally.


