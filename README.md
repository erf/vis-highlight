# vis-highlight

A [vis-plugin](https://github.com/martanne/vis/wiki/Plugins/) to highlight Lua patterns.

## Commands
 
`:hi [pattern] (on/off)` - highlight text with Lua pattern

`:hi-ls` - list patterns

`:hi-cl` - clear patterns

You can add multiple patterns to  highlight text until cleared or disabled.

You can prepare patterns in your `visrc.lua` file with:

```
local hi = require('plugins/vis-highlight')
hi.patterns[' +\n'] = true
```

See [Patterns](https://www.lua.org/pil/20.2.html) in Lua docs.

## Style

You can add a custom style for matches with:

```
local hi = require('plugins/vis-highlight')
hi.style = 'back:#444444,fore:#cccccc'
```

See Style Definition in [LPegLexer](https://scintilla.sourceforge.io/LPegLexer.html).
