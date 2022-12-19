# CSS Grids

Clik offers fiv flavours of grid.

## 1. Plain

Minimum width applied to items and the grid will fill as many as it can, balancing the rows. Ideal for photos. Usually done with an `auto-fill`, but this can be changed to `auto-fit`. Needs a minimum column width.

## 2. Flexible

Flexbox with either stretch=0 or 1 to allow the items to expand.

## 3. Fixed Columns

Specified number of columns divided equally. Usually for containers.

You can also specify the widths (e.g. 25% auto 25%) which overrides the columns settings.

### 3.5 Auto columns

Fixed columns but calculated from the number of children. Only supposed to be used for menus to be put into one line. Sometimes you see this for galleries. Col number "auto". It is much better to use an auto grid to do this.

## 4. Fixed Width

Each column is a set width and as many will be shown as possible. Legacy behaviour suitable for smaller thumbnails were you want to show them at the max size always. Far better now to use bigger thumbnails and allow the browser to size them down.

## 5. Named positions

`grid-template-areas` is set with the names of the containers and then `grid-template-columns` and/or `grid-template-rows` are set to specify the widths.
