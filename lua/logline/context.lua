local M = {}

local FUNCTION_NODES = {
  arrow_function = true,
  class_declaration = true,
  class_definition = true,
  function_declaration = true,
  function_definition = true,
  function_expression = true,
  function_item = true,
  method_declaration = true,
  method_definition = true,
  ['function'] = true,
}

local function name_of(node, bufnr)
  local named = node:field('name')[1]
  if named then
    return vim.treesitter.get_node_text(named, bufnr)
  end
  local parent = node:parent()
  if parent and (parent:type() == 'variable_declarator' or parent:type() == 'pair') then
    local sibling = parent:field('name')[1] or parent:field('key')[1]
    if sibling then
      return vim.treesitter.get_node_text(sibling, bufnr)
    end
  end
  return nil
end

---Name of the function or class the cursor sits inside, if any.
---@param bufnr integer
---@return string|nil
function M.enclosing(bufnr)
  local parsed = pcall(function()
    local filetype = vim.bo[bufnr].filetype
    local language = vim.treesitter.language.get_lang(filetype) or filetype
    local parser = vim.treesitter.get_parser(bufnr, language)
    if parser then parser:parse() end
  end)
  if not parsed then return nil end

  local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr })
  if not ok or not node then return nil end

  while node do
    if FUNCTION_NODES[node:type()] then
      local name = name_of(node, bufnr)
      if name and name ~= '' then return name end
    end
    node = node:parent()
  end
  return nil
end

---The identifier the cursor is on, or the visual selection.
---Whether a captured string is worth logging, rather than punctuation the
---cursor happened to be sitting on.
---@param value string
---@return boolean
function M.is_loggable(value)
  if not value or value == '' then return false end
  return value:match('^[%w_$][%w_$%.%[%]%-\'"]*$') ~= nil
end

---@param opts { visual: boolean|nil }|nil
---@return string
function M.variable(opts)
  if (opts or {}).visual then
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local lines = vim.api.nvim_buf_get_text(
      0, start_pos[2] - 1, start_pos[3] - 1, end_pos[2] - 1, math.min(end_pos[3], vim.fn.col({ end_pos[2], '$' }) - 1), {}
    )
    return vim.trim(table.concat(lines, ' '))
  end
  return vim.fn.expand('<cword>')
end

return M
