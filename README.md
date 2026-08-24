# logline.nvim

Insert a debug log statement for the variable under the cursor, with enough
context in the message to tell you where it came from. Then remove every one of
them when you are done.

Inspired by Turbo Console Log, but language-agnostic: the templates are data,
so adding a language is one table entry.

```
const subtotal = 1
console.log('money.ts:1 formatPence subtotal:', subtotal) // logline
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
  tag = 'logline',
  templates = {
    typescript = { log = 'logger.debug(%s)' },
    zig = { log = 'std.debug.print(%s)' },
  },
})
```

`tag` is the marker appended as a comment to each inserted line. It is how
`delete`, `commenttoggle` and `search` find them again, and it keeps the tag out
of your program's output.

`templates` is merged over the shipped defaults, so you can override one level of
one language without restating the rest.

### Shipped languages

JavaScript, TypeScript, JSX, TSX, Vue, Lua, PHP, Python, Go, Ruby and shell.

Lua uses `vim.print` and routes errors through `vim.notify`. PHP uses
`error_log`. Shell sends errors to stderr. Anything not listed refuses rather
than guessing, and tells you which filetype it wanted.

## Why the tag is a comment

Putting the marker in a trailing comment rather than inside the printed string
keeps your output clean while still making the lines findable. Comment syntax
comes from the buffer's `commentstring`, so it is correct per language without
the plugin knowing anything about it.

For a filetype with no `commentstring`, the tag moves into the message so the
line can still be found.

## Tests

```
make test
```

Requires plenary.nvim.
