local templates = require('logline.templates')

describe('templates', function()
  it('knows the three levels for typescript', function()
    local t = templates.for_filetype('typescript')
    assert.equals('console.log(%s)', t.log)
    assert.equals('console.info(%s)', t.info)
    assert.equals('console.error(%s)', t.error)
  end)

  it('uses a language-appropriate call rather than console for lua', function()
    assert.equals('vim.print(%s)', templates.for_filetype('lua').log)
  end)

  it('sends lua errors through notify so they are visible', function()
    assert.is_truthy(templates.for_filetype('lua').error:match('ERROR'))
  end)

  it('returns nil for a filetype it does not know', function()
    assert.is_nil(templates.for_filetype('brainfuck'))
  end)

  it('lets a user override a shipped filetype', function()
    local t = templates.for_filetype('python', { python = { log = 'logger.debug(%s)' } })
    assert.equals('logger.debug(%s)', t.log)
  end)

  it('lets a user add a filetype it does not ship', function()
    local t = templates.for_filetype('zig', { zig = { log = 'std.debug.print(%s)' } })
    assert.equals('std.debug.print(%s)', t.log)
  end)

  it('does not mutate the shipped defaults when overriding', function()
    templates.for_filetype('python', { python = { log = 'logger.debug(%s)' } })
    assert.equals('print(%s)', templates.defaults.python.log)
  end)
end)
