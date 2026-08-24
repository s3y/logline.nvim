local statement = require('logline.statement')

local M = {}

local function line_at(bufnr, lnum)
  return vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1] or ''
end

---Leading whitespace to use for a statement placed relative to lnum.
---@param bufnr integer
---@param lnum integer 1-indexed
---@param opts { shiftwidth: integer|nil }|nil
---@return string
function M.indent_of(bufnr, lnum, opts)
  local line = line_at(bufnr, lnum)
  local indent = line:match('^%s*') or ''
  local opens_block = line:match('[%({%[]%s*$') ~= nil
  if opens_block then
    local width = (opts or {}).shiftwidth or vim.bo[bufnr].shiftwidth
    if width == 0 then width = vim.bo[bufnr].tabstop end
    indent = indent .. string.rep(' ', width)
  end
  return indent
end

---@param bufnr integer
---@param lnum integer 1-indexed reference line
---@param text string
---@param opts { above: boolean|nil }|nil
function M.insert(bufnr, lnum, text, opts)
  local at = (opts or {}).above and lnum - 1 or lnum
  vim.api.nvim_buf_set_lines(bufnr, at, at, false, { text })
end

---@param bufnr integer
---@param tag string
---@return integer removed
function M.delete(bufnr, tag)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local kept, removed = {}, 0
  for _, line in ipairs(lines) do
    if statement.is_logline(line, tag) then
      removed = removed + 1
    else
      table.insert(kept, line)
    end
  end
  if removed > 0 then
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, kept)
  end
  return removed
end

---@param bufnr integer
---@param tag string
---@return integer touched
function M.comment_toggle(bufnr, tag)
  local commentstring = vim.bo[bufnr].commentstring
  if commentstring == '' or not commentstring:find('%%s') then return 0 end

  local prefix = vim.trim(commentstring:format(''):gsub('%s+$', ''))
  if prefix == '' then return 0 end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local touched = 0
  for index, line in ipairs(lines) do
    if statement.is_logline(line, tag) then
      local indent, rest = line:match('^(%s*)(.*)$')
      local without = rest:match('^' .. vim.pesc(prefix) .. '%s?(.*)$')
      lines[index] = indent .. (without or (prefix .. ' ' .. rest))
      touched = touched + 1
    end
  end
  if touched > 0 then
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  end
  return touched
end

return M
