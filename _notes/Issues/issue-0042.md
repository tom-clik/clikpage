# Wireframe mode

On any given page, you can switch to wireframe mode.

Only containers defined in the current template will be editable. Inherited containers will be greyed out, but clicking on them will switch to the parent or other layout.

## Editing

Hovering over a layout will display information about it and then clikcing will put it into edit mode.

### Dimensions

Margin, padding, width, height, and borders can be editing using keystroke. When a container is in edit mode, pressing M, P, W, H, or B will switch to editing the relevant dimension. Then the up or down arrow arrow keys can be used to increase or decrease the value.

For the dimension lists, pressing 1,2, or 3/4 will change to editing all values, horizontal and vertical values, or 4 separate values. The left or right arrows will select which values you are editing.

### Adjust grid sizing

Grid sizing (G) will enter the grid sizing mode. This will allow sizing of the grid width (auto, fixed columns) or dragging of the column layout (also fixed columns but with grid-template-columns).

For named positions, the elements can be dragged to create the layouts.

### Styling

Basic styling can be applied via the dialog. This is just background color, border color.

## Implementation

In preview mode, we need to check key strokes.

(clik_onready - add clik.keyDown event)

Escape will take you out (or V, view).

### Displaying wireframe

