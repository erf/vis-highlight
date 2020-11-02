# vis-highlight

A [vis-plugin](https://github.com/martanne/vis/wiki/Plugins/) to highlight Lua patterns.

## Commands

`:hi [pattern] (style)` - highlight a Lua pattern with optional style

`:hi-ls` - list patterns with style

`:hi-cl` - clear patterns

`:hi-rm [pattern]` - remove pattern

## Patterns in visrc

You can set multiple patterns with style in your `visrc.lua` file with:

```
local hi = require('plugins/vis-highlight')
hi.patterns[' +\n'] = { style = 'back:#444444' }
hi.patterns['hi'] = { style = 'back:yellow,fore:blue,underlined:true,bold:true' }
```

If pattern is set to empty `{}` it defaults to `STYLE_CURSOR` style.

> Notice the number of custom styles are limited to 64 and may be overridden by
lexer styles.

See [Patterns](https://www.lua.org/pil/20.2.html)

## Style definitions

Style definitions may contain the following:

- **fore**: Font face foreground color in 0xBBGGRR or "#RRGGBB" format.
- **back**: Font face background color in 0xBBGGRR or "#RRGGBB" format.
- **bold**: Whether or not the font face is bold. The default value is false.
- **underlined**: Whether or not the font face is underlined. The default value is false.

See [LPegLexer](https://scintilla.sourceforge.io/LPegLexer.html)
