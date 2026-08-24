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
    tag = '',
  }

  it('builds a log call with the label and the variable', function()
    assert.equals("console.log('money.ts:12 parsePence value:', value)",
      statement.render(base))
  end)

  it('respects the indent of the reference line', function()
    assert.equals("    console.log('money.ts:12 parsePence value:', value)",
      statement.render(vim.tbl_extend('force', base, { indent = '    ' })))
  end)

  it('appends a comment marker only when a tag is configured', function()
    local rendered = statement.render(vim.tbl_extend('force', base, { commentstring = '-- %s', tag = 'DEBUG' }))
    assert.is_truthy(rendered:find('-- DEBUG', 1, true))
  end)

  it('moves a configured tag into the message when there is no commentstring', function()
    local rendered = statement.render(vim.tbl_extend('force', base, { commentstring = '', tag = 'DEBUG' }))
    assert.is_truthy(rendered:find('DEBUG', 1, true))
  end)

  it('handles a template with no variable slot for the label', function()
    local rendered = statement.render(vim.tbl_extend('force', base, { template = 'print(%s)' }))
    assert.is_truthy(rendered:find('print(', 1, true))
  end)
end)

describe('statement.is_logline', function()
  it('recognises a line it wrote by the shape of its label', function()
    assert.is_true(statement.is_logline("console.log('money.ts:4 f value:', value)", ''))
  end)

  it('ignores an ordinary line', function()
    assert.is_false(statement.is_logline("const a = 1", ''))
  end)

  it('ignores a console call the user wrote themselves', function()
    assert.is_false(statement.is_logline("console.log('hello')", ''))
    assert.is_false(statement.is_logline("console.log('a:', a)", ''))
  end)

  it('recognises one that has since been commented out', function()
    assert.is_true(statement.is_logline("// console.log('money.ts:4 f value:', value)", ''))
  end)

  it('still honours an explicit tag when one is configured', function()
    assert.is_true(statement.is_logline("console.log('x') // DEBUG", 'DEBUG'))
  end)
end)
