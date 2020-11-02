# vis-highlight

A [vis-plugin](https://github.com/martanne/vis/wiki/Plugins/) to highlight Lua patterns.

## Commands

`:hi [pattern] (style)` - highlight text with Lua pattern and an optional style

`:hi-ls` - list patterns with style

`:hi-cl` - clear patterns

`:hi-rm [pattern]` - remove specific pattern

## Prepare patterns

You can prepare multiple patterns with style in your `visrc.lua` file with:

```
local hi = require('plugins/vis-highlight')
hi.patterns[' +\n'] = { style = 'back:#444444' }
```

Leave it empty for the default `STYLE_CURSOR` style.

```
local hi = require('plugins/vis-highlight')
hi.patterns[' +\n'] = {}
```

> Notice the number of custom styles are limited to 64 and may be overridden by
lexer styles.

See [Patterns](https://www.lua.org/pil/20.2.html) in Lua docs.

See Style Definition in [LPegLexer](https://scintilla.sourceforge.io/LPegLexer.html).
