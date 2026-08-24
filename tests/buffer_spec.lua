local buffer = require('logline.buffer')

local function scratch(lines, filetype)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].filetype = filetype or 'typescript'
  vim.bo[bufnr].commentstring = '// %s'
  return bufnr
end

local function lines_of(bufnr)
  return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
end

describe('buffer.insert', function()
  it('puts the statement on the line below', function()
    local bufnr = scratch({ 'const a = 1', 'const b = 2' })
    buffer.insert(bufnr, 1, '  console.log(1) // logline')
    assert.same({ 'const a = 1', '  console.log(1) // logline', 'const b = 2' }, lines_of(bufnr))
  end)

  it('puts the statement above when asked', function()
    local bufnr = scratch({ 'const a = 1' })
    buffer.insert(bufnr, 1, 'X', { above = true })
    assert.same({ 'X', 'const a = 1' }, lines_of(bufnr))
  end)
end)

describe('buffer.indent_of', function()
  it('reads the leading whitespace of a line', function()
    local bufnr = scratch({ 'function f() {', '    const a = 1', '}' })
    assert.equals('    ', buffer.indent_of(bufnr, 2))
  end)

  it('is empty for an unindented line', function()
    local bufnr = scratch({ 'const a = 1' })
    assert.equals('', buffer.indent_of(bufnr, 1))
  end)

  it('indents into a block when the line opens one', function()
    local bufnr = scratch({ '  function f() {', '  }' })
    assert.equals('    ', buffer.indent_of(bufnr, 1, { shiftwidth = 2 }))
  end)
end)

describe('buffer.delete', function()
  it('removes every tagged line and leaves the rest', function()
    local bufnr = scratch({
      'const a = 1',
      "console.log('a:', a) // logline",
      'const b = 2',
      "console.error('b:', b) // logline",
    })
    assert.equals(2, buffer.delete(bufnr, 'logline'))
    assert.same({ 'const a = 1', 'const b = 2' }, lines_of(bufnr))
  end)

  it('leaves a console call the user wrote themselves', function()
    local bufnr = scratch({ "console.log('mine')" })
    assert.equals(0, buffer.delete(bufnr, 'logline'))
    assert.same({ "console.log('mine')" }, lines_of(bufnr))
  end)

  it('removes tagged lines that were commented out', function()
    local bufnr = scratch({ 'const a = 1', "// console.log('a:', a) // logline" })
    assert.equals(1, buffer.delete(bufnr, 'logline'))
    assert.same({ 'const a = 1' }, lines_of(bufnr))
  end)
end)

describe('buffer.comment_toggle', function()
  it('comments out every tagged line', function()
    local bufnr = scratch({ 'const a = 1', "console.log('a:', a) // logline" })
    buffer.comment_toggle(bufnr, 'logline')
    assert.same({ 'const a = 1', "// console.log('a:', a) // logline" }, lines_of(bufnr))
  end)

  it('uncomments a line it previously commented', function()
    local bufnr = scratch({ "// console.log('a:', a) // logline" })
    buffer.comment_toggle(bufnr, 'logline')
    assert.same({ "console.log('a:', a) // logline" }, lines_of(bufnr))
  end)

  it('returns to where it started after two toggles', function()
    local bufnr = scratch({ "console.log('a:', a) // logline" })
    buffer.comment_toggle(bufnr, 'logline')
    buffer.comment_toggle(bufnr, 'logline')
    assert.same({ "console.log('a:', a) // logline" }, lines_of(bufnr))
  end)

  it('preserves indentation when commenting', function()
    local bufnr = scratch({ "    console.log('a:', a) // logline" })
    buffer.comment_toggle(bufnr, 'logline')
    assert.same({ "    // console.log('a:', a) // logline" }, lines_of(bufnr))
  end)

  it('leaves untagged lines alone', function()
    local bufnr = scratch({ 'const a = 1' })
    buffer.comment_toggle(bufnr, 'logline')
    assert.same({ 'const a = 1' }, lines_of(bufnr))
  end)
end)
