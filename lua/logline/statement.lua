local M = {}

local function sanitise(value)
  return (tostring(value or ''):gsub("['\"\n\r]", ''))
end

---Human-readable context for a log line: where it is and what it prints.
---@param opts { file: string, line: integer, enclosing: string|nil, variable: string }
---@return string
function M.label(opts)
  local parts = { string.format('%s:%d', sanitise(opts.file), opts.line or 0) }
  if opts.enclosing and opts.enclosing ~= '' then
    table.insert(parts, sanitise(opts.enclosing))
  end
  table.insert(parts, sanitise(opts.variable) .. ':')
  return table.concat(parts, ' ')
end

---@param opts { template: string, label: string, variable: string, commentstring: string|nil, tag: string, indent: string|nil }
---@return string
function M.render(opts)
  local tag = opts.tag or 'logline'
  local commentstring = opts.commentstring or ''
  local label = opts.label

  local comment = ''
  if commentstring ~= '' and commentstring:find('%%s') then
    comment = ' ' .. commentstring:format(tag)
  else
    label = tag .. ' ' .. label
  end

  local arguments = string.format("'%s', %s", label, opts.variable)
  return (opts.indent or '') .. opts.template:format(arguments) .. comment
end

---@param line string
---@param tag string
---@return boolean
function M.is_logline(line, tag)
  return line:find(tag, 1, true) ~= nil
end

return M
