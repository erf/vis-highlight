# vis-highlight 🌈

A [vis-plugin](https://github.com/martanne/vis/wiki/Plugins/) to highlight Lua patterns.

## Commands

`:hi [pattern] (style)` - highlight a Lua pattern with optional style

> This will highlight all windows with the given pattern and style

`:hi-ls` - list patterns and style

`:hi-clear` - clear patterns

`:hi-rm [pattern]` - remove a specific pattern

## Example

```
:hi ' +\n' back:#444444
:hi-ls
:hi-rm " +\n"
:hi hi back:yellow,fore:blue,underlined:true,bold:true
:hi-clear
```

> You only need quotation marks if you use spaces in your patterns

## Configure patterns in visrc

You can configure multiple patterns with style in your `visrc.lua` file:

```
local hi = require('plugins/vis-highlight')

hi.patterns['  +'] = { style = 'back:#666600' }
hi.patterns[' +\n'] = { style = 'back:#444444', hideOnInsert = true }
hi.patterns['hi'] = { style = 'back:yellow,fore:blue,underlined:true,bold:true' }
```

> The number of custom styles are limited to 64 and may be overridden by lexer styles

If style is empty, `win.STYLE_CURSOR` will be used.

You can set the `hideOnInsert = true` option to avoid highlighting when in 
`INSERT` mode.

See [Patterns](https://www.lua.org/pil/20.2.html) for how to Lua define patterns.

## Style definitions

Style definitions may contain the following:

- **fore**: Font face foreground color in 0xBBGGRR or "#RRGGBB" format.
- **back**: Font face background color in 0xBBGGRR or "#RRGGBB" format.
- **bold**: Whether or not the font face is bold. The default value is false.
- **underlined**: Whether or not the font face is underlined. The default value is false.

See [LPegLexer](https://scintilla.sourceforge.io/LPegLexer.html) for  more info on styles.

