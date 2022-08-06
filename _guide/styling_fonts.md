# Fonts

Like colors, fonts are never applied directly. We reference only the variable name, allowing for easy editing.

    <fonts>
        <font name="titlefont" value="Lato" />
        <font name="bodyfont" value="Open Sans" />
    </fonts>

Like colors, these are now exported to the css as variables, e.g.

    var(--titlefont);

## Setting up fonts

Your font families should be defined in a fonts.css file, which you can add either via the static files mechanism
or just as a file.

If you use the static file mechanism, you can create a debug version that uses local fonts, either files in the web distribution or using the local font mechanism `src: local('Lato Light');`. This should never be used in production.

It can help to split individual fonts out into their own files. E.g. for Lato "local", a sample font file looks like this:

```
@font-face {
  font-family: 'Lato';
  font-style: normal;
  font-weight: 300;
  font-display: swap;
  src: local('Lato Light');
}

@font-face {
  font-family: 'Lato';
  font-style: normal;
  font-weight: 400;
  font-display: swap;
  src: local('Lato');
}
```

Then for the static files that actually get defined, you would have a debug version and production version:

#### Debug

```
@import url('open_sans_local.css');
@import url('lato_local.css');
```

#### Production

```
@import url('https://fonts.googleapis.com/css2?family=Lato:wght@300;400;700&display=swap');
```

## Available weights

At this time the author is responsible for only using the available weights in their styling. For fonts that don't have bold versions, this means ensuring the title and headings styles don't use a bold weight. It can be easier, especially when developing style variations, to define a bold weight with a normal weight file. This doesn't really work for Google fonts, but these rarely don't have available weights. It tends to only apply to exotic fonts which we generally host in the web distribution.
