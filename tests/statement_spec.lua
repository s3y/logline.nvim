local statement = require('logline.statement')

describe('statement.label', function()
  it('carries file, line, enclosing function and variable', function()
    assert.equals('money.ts:12 parsePence value:', statement.label({
      file = 'money.ts', line = 12, enclosing = 'parsePence', variable = 'value',
    }))
  end)

  it('omits the enclosing function when there is not one', function()
    assert.equals('money.ts:3 value:', statement.label({
      file = 'money.ts', line = 3, variable = 'value',
    }))
  end)

  it('is not confused by a variable containing a quote', function()
    local label = statement.label({ file = 'a.ts', line = 1, variable = "it's" })
    assert.is_falsy(label:find("'"))
  end)
end)

describe('statement.render', function()
  local base = {
    template = 'console.log(%s)',
    label = 'money.ts:12 parsePence value:',
    variable = 'value',
    commentstring = '// %s',
    tag = 'logline',
  }

  it('builds a log call with the label and the variable', function()
    assert.equals("console.log('money.ts:12 parsePence value:', value) // logline",
      statement.render(base))
  end)

  it('respects the indent of the reference line', function()
    assert.equals("    console.log('money.ts:12 parsePence value:', value) // logline",
      statement.render(vim.tbl_extend('force', base, { indent = '    ' })))
  end)

  it('uses the comment syntax of the filetype', function()
    local rendered = statement.render(vim.tbl_extend('force', base, { commentstring = '-- %s' }))
    assert.is_truthy(rendered:find('-- logline', 1, true))
  end)

  it('still tags the line when the filetype has no commentstring', function()
    local rendered = statement.render(vim.tbl_extend('force', base, { commentstring = '' }))
    assert.is_truthy(rendered:find('logline', 1, true))
  end)

  it('handles a template with no variable slot for the label', function()
    local rendered = statement.render(vim.tbl_extend('force', base, { template = 'print(%s)' }))
    assert.is_truthy(rendered:find('print(', 1, true))
  end)
end)

describe('statement.is_logline', function()
  it('recognises a line it wrote', function()
    assert.is_true(statement.is_logline("console.log('a:', a) // logline", 'logline'))
  end)

  it('ignores an ordinary line', function()
    assert.is_false(statement.is_logline("const a = 1", 'logline'))
  end)

  it('ignores a console call the user wrote themselves', function()
    assert.is_false(statement.is_logline("console.log('hello')", 'logline'))
  end)

  it('recognises a line it wrote that has since been commented out', function()
    assert.is_true(statement.is_logline("// console.log('a:', a) // logline", 'logline'))
  end)
end)
