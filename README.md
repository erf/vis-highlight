# vis-highlight

A [vis-plugin](https://github.com/martanne/vis/wiki/Plugins/) to highlight Lua patterns.

## Commands
 
`:hi [pattern] (on/off)` - highlight text with Lua pattern

`:hi-ls` - list patterns

`:hi-cl` - clear patterns

See [Patterns](https://www.lua.org/pil/20.2.html) in Lua docs.

## Style

You can custom style matches with:

```
require('plugins/vis-highlight').style = 'back:#444444,fore:#cccccc'
```

See Style Definition in [LPegLexer](https://scintilla.sourceforge.io/LPegLexer.html).
