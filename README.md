# vis-highlight

A [vis-plugin](https://github.com/martanne/vis/wiki/Plugins/) to highlight patterns.

## Commands
 
`:hi [pattern] (on/off)` - highlight text with Lua pattern

`:hi-ls` - list patterns

`:hi-cl` - clear patterns

See [Patterns](https://www.lua.org/pil/20.2.html)

## Style

You can style the matches with:

```
require('plugins/vis-highlight').style = 'back:#444444,fore:#cccccc'
```

See Style definition in [LPegLexer](https://scintilla.sourceforge.io/LPegLexer.html)
