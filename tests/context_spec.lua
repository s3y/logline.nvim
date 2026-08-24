local context = require('logline.context')

local function open(lines, filetype, row, col)
  vim.cmd('enew!')
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].filetype = filetype
  vim.api.nvim_win_set_cursor(0, { row, col })
  return bufnr
end

describe('context.enclosing', function()
  it('returns nil rather than throwing when there is no parser', function()
    local bufnr = open({ 'nothing here' }, 'nosuchfiletype', 1, 0)
    assert.is_nil(context.enclosing(bufnr))
  end)

  it('names the function the cursor sits in', function()
    if not pcall(vim.treesitter.language.inspect, 'lua') then return end
    local bufnr = open({ 'local function parsePence(value)', '  local x = value', 'end' }, 'lua', 2, 8)
    assert.equals('parsePence', context.enclosing(bufnr))
  end)

  it('returns nil at the top level of a file', function()
    if not pcall(vim.treesitter.language.inspect, 'lua') then return end
    local bufnr = open({ 'local x = 1' }, 'lua', 1, 6)
    assert.is_nil(context.enclosing(bufnr))
  end)
end)

describe('context.variable', function()
  it('reads the identifier under the cursor', function()
    open({ 'const total = subtotal + tax' }, 'typescript', 1, 14)
    assert.equals('subtotal', context.variable())
  end)

  it('reads the whole word when the cursor is at its start', function()
    open({ 'const total = 1' }, 'typescript', 1, 6)
    assert.equals('total', context.variable())
  end)
end)
