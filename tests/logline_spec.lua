local logline = require('logline')

local function open(lines, filetype, row, col)
  vim.cmd('enew!')
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].filetype = filetype
  vim.bo[bufnr].commentstring = '// %s'
  vim.api.nvim_win_set_cursor(0, { row, col })
  return bufnr
end

local function lines_of(bufnr)
  return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
end

describe('logline.log', function()
  before_each(function() logline.setup({}) end)

  it('inserts a console.log for the word under the cursor', function()
    local bufnr = open({ 'const subtotal = 1' }, 'typescript', 1, 6)
    assert.is_true(logline.log('log'))
    assert.equals(2, #lines_of(bufnr))
    assert.is_truthy(lines_of(bufnr)[2]:find('console.log(', 1, true))
    assert.is_truthy(lines_of(bufnr)[2]:find('subtotal', 1, true))
  end)

  it('uses console.error for the error level', function()
    local bufnr = open({ 'const subtotal = 1' }, 'typescript', 1, 6)
    logline.log('error')
    assert.is_truthy(lines_of(bufnr)[2]:find('console.error(', 1, true))
  end)

  it('uses console.info for the info level', function()
    local bufnr = open({ 'const subtotal = 1' }, 'typescript', 1, 6)
    logline.log('info')
    assert.is_truthy(lines_of(bufnr)[2]:find('console.info(', 1, true))
  end)

  it('tags the line so it can be found again', function()
    local bufnr = open({ 'const subtotal = 1' }, 'typescript', 1, 6)
    logline.log('log')
    assert.is_truthy(lines_of(bufnr)[2]:find('logline', 1, true))
  end)

  it('includes the line number in the message', function()
    local bufnr = open({ 'const a = 1', 'const subtotal = 2' }, 'typescript', 2, 6)
    logline.log('log')
    assert.is_truthy(lines_of(bufnr)[3]:find(':2', 1, true))
  end)

  it('matches the indentation of the reference line', function()
    local bufnr = open({ 'function f() {', '    const subtotal = 1', '}' }, 'typescript', 2, 10)
    logline.log('log')
    assert.equals('    ', lines_of(bufnr)[3]:match('^%s*'))
  end)

  it('refuses a filetype it has no template for', function()
    open({ 'whatever' }, 'nosuchfiletype', 1, 0)
    assert.is_false(logline.log('log'))
  end)

  it('honours a user template override', function()
    logline.setup({ templates = { typescript = { log = 'logger.debug(%s)' } } })
    local bufnr = open({ 'const subtotal = 1' }, 'typescript', 1, 6)
    logline.log('log')
    assert.is_truthy(lines_of(bufnr)[2]:find('logger.debug(', 1, true))
  end)

  it('honours a custom tag', function()
    logline.setup({ tag = 'DEBUGME' })
    local bufnr = open({ 'const subtotal = 1' }, 'typescript', 1, 6)
    logline.log('log')
    assert.is_truthy(lines_of(bufnr)[2]:find('DEBUGME', 1, true))
  end)
end)

describe('logline.delete', function()
  it('removes only what it inserted', function()
    logline.setup({})
    local bufnr = open({ "console.log('mine')", 'const subtotal = 1' }, 'typescript', 2, 6)
    logline.log('log')
    assert.equals(3, #lines_of(bufnr))
    assert.equals(1, logline.delete())
    assert.same({ "console.log('mine')", 'const subtotal = 1' }, lines_of(bufnr))
  end)
end)

describe('logline.log refuses nonsense', function()
  before_each(function() logline.setup({}) end)

  it('will not log a comment marker', function()
    local bufnr = open({ '  //' }, 'typescript', 1, 2)
    assert.is_false(logline.log('log'))
    assert.equals(1, #lines_of(bufnr))
  end)

  it('will not log a bare operator', function()
    open({ 'a +' }, 'typescript', 1, 2)
    assert.is_false(logline.log('log'))
  end)

  it('still logs a property access', function()
    local bufnr = open({ 'const x = user.name' }, 'typescript', 1, 6)
    assert.is_true(logline.log('log'))
    assert.equals(2, #lines_of(bufnr))
  end)
end)
