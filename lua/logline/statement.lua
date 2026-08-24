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
  local tag = opts.tag or ''
  local commentstring = opts.commentstring or ''
  local label = opts.label

  local comment = ''
  if tag ~= '' then
    if commentstring ~= '' and commentstring:find('%%s') then
      comment = ' ' .. commentstring:format(tag)
    else
      label = tag .. ' ' .. label
    end
  end

  local arguments = string.format("'%s', %s", label, opts.variable)
  return (opts.indent or '') .. opts.template:format(arguments) .. comment
end

---A statement this plugin wrote. Recognised by the shape of its label
---(`file:line ... variable:`) rather than a visible marker, so nothing has to
---be added to the line to make it findable again.
---@param line string
---@param tag string|nil
---@return boolean
function M.is_logline(line, tag)
  if tag and tag ~= '' and line:find(tag, 1, true) then return true end
  return line:find("'[%w%._%-]*:%d+ [^']*:'") ~= nil
end

return M
