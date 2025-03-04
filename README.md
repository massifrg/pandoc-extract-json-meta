# pandoc-extract-json-meta

A custom writer for Pandoc to extract documents' metadata as JSON.

To test it, change dir to `./test` and type:

```sh
pandoc -f json -t ../src/json_metadata.lua test.json
```

and you'll get this output (here it's prettified):

```json
{
  "author": [
    "Author One",
    "Author Two"
  ],
  "average": "4.2",
  "flags": {
    "checked": true,
    "published": false
  },
  "meta1": "A string value",
  "meta2": "Inlines with an italic",
  "revision": "3",
  "title": "A document with metadata\n\n(for tests only)\n"
}
```

(just look at `./test.native` or `test.md` if you want to see the contents of the test document)

## Keeping the styles of `MetaInlines` and `MetaBlocks`

`MetaInlines` and `MetaBlocks` metadata can be formatted.

The default behavior of `json_metadata.lua` is to convert them to plain text.

You may want to keep the formatting: you can do it setting the `format` variable:

```sh
pandoc -f json -t ../src/json_metadata.lua -V format=html test.json
```

to get this:

```json
{
  "author": [
    "Author One",
    "Author Two"
  ],
  "average": "4.2",
  "flags": {
    "checked": true,
    "published": false
  },
  "meta1": "A string value",
  "meta2": "Inlines with an <em>italic</em>",
  "revision": "3",
  "title": "<p>A document with metadata</p>\n<p>(<em>for tests only</em>)</p>"
}
```

Currently, the script allows only `plain` (default), `markdown`, `html` and `native` formats,
but you can add any other format supported
by [pandoc.write](https://pandoc.org/lua-filters.html#pandoc.write)
changing the `ALLOWED_FORMATS` table in the first lines of the script.

## Detecting numbers

There's no `MetaValue` that represents numbers, so metadata with numeric values would
be represented by a `MetaString` or a `MetaInlines`.

Setting the `numbers` variable, you can detect integers or numbers with decimals:

```sh
pandoc -f json -t ../src/json_metadata.lua -V format=plain -V numbers=true test.json
```

results in:

```json
{
  "author": [
    "Author One",
    "Author Two"
  ],
  "average": 4.2,
  "flags": {
    "checked": true,
    "published": false
  },
  "meta1": "A string value",
  "meta2": "Inlines with an italic",
  "revision": 3,
  "title": "A document with metadata\n\n(for tests only)\n"
}
```

As you can see, `average` (`MetaString`) and `revision` (`MetaInlines`) fields are numbers
in the resulting JSON.

The number detection is activated by any value of the `number` variable,
except for `false` and `0`.