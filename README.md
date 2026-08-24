# logline.nvim

Insert a debug log statement for the variable under the cursor, with enough
context in the message to tell you where it came from. Then remove every one of
them when you are done.

Inspired by Turbo Console Log, but language-agnostic: the templates are data,
so adding a language is one table entry.

```
const subtotal = 1
console.log('money.ts:1 formatPence subtotal:', subtotal)
```

File, line, enclosing function and variable name, so a wall of output still
tells you which print fired.

## Install

With lazy.nvim:

```lua
{
  's3y/logline.nvim',
  opts = {},
  keys = {
    { '<leader>cl', function() require('logline').log('log') end, mode = { 'n', 'v' }, desc = 'Log Variable' },
    { '<leader>ci', function() require('logline').log('info') end, mode = { 'n', 'v' }, desc = 'Log Variable (info)' },
    { '<leader>ce', function() require('logline').log('error') end, mode = { 'n', 'v' }, desc = 'Log Variable (error)' },
  },
  cmd = 'Logline',
}
```

No keymaps are set for you. Requires Neovim 0.10 or later, and `ripgrep` for
`:Logline search`.

## Commands

| Command | Does |
|---|---|
| `:Logline log` | insert a log statement below the cursor |
| `:Logline info` | same, at info level |
| `:Logline error` | same, at error level |
| `:Logline delete` | remove every logline statement in the buffer |
| `:Logline commenttoggle` | comment or uncomment them instead of removing |
| `:Logline search` | quickfix list of every logline statement under the cwd |

`:Logline search` is the one that stops a stray print reaching a pull request.

## Configuration

```lua
require('logline').setup({
  tag = '',
  templates = {
    typescript = { log = 'logger.debug(%s)' },
    zig = { log = 'std.debug.print(%s)' },
  },
})
```

`tag` is empty by default, so nothing is appended to the line. Statements are
recognised by the shape of their label (`file:line ... variable:`), which means
your code stays clean and `delete`, `commenttoggle` and `search` still find
them. Set a tag if you want an explicit marker as well; it is appended as a
comment so it never reaches your program's output.

`templates` is merged over the shipped defaults, so you can override one level of
one language without restating the rest.

### Shipped languages

JavaScript, TypeScript, JSX, TSX, Vue, Lua, PHP, Python, Go, Ruby and shell.

Lua uses `vim.print` and routes errors through `vim.notify`. PHP uses
`error_log`. Shell sends errors to stderr. Anything not listed refuses rather
than guessing, and tells you which filetype it wanted.

## How statements are found again

Nothing is added to the line. The label already carries a distinctive shape,
`file:line` followed by the variable name and a colon, all inside a quoted
string. That is what `delete`, `commenttoggle` and `search` match on.

A `console.log('hello')` you wrote by hand does not match, and neither does
`console.log('a:', a)`. Commented-out statements still do, so
`commenttoggle` then `delete` works.

If you would rather have an explicit marker, set `tag` and it is appended as a
comment using the buffer's `commentstring`.

## Tests

```
make test
```

Requires plenary.nvim.
