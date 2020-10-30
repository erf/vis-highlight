# vis-highlight

A [vis-plugin](https://github.com/martanne/vis/wiki/Plugins/) to highlight Lua patterns.

## How to
 
`:hi [pattern] [style]` - highlight text with Lua pattern and optional style

`:hi-ls` - list patterns

`:hi-cl` - clear patterns

`:hi-rm [pattern]` - remove specific pattern

You can add multiple patterns to highlight the text until cleared or disabled.

You can prepare patterns in your `visrc.lua` file with:

```
local hi = require('plugins/vis-highlight')
hi.patterns[' +\n'] = {}
```

And style it with:

```
hi.patterns[' +\n'] = { style = 'back:#444444,fore:#cccccc', id = 78 }
```

See [Patterns](https://www.lua.org/pil/20.2.html) in Lua docs.

See Style Definition in [LPegLexer](https://scintilla.sourceforge.io/LPegLexer.html).
