local buffer = require('logline.buffer')
local context = require('logline.context')
local statement = require('logline.statement')
local templates = require('logline.templates')

local M = {}

local defaults = {
  tag = 'logline',
  templates = {},
}

M.options = vim.deepcopy(defaults)

---@param opts table|nil
function M.setup(opts)
  M.options = vim.tbl_deep_extend('force', vim.deepcopy(defaults), opts or {})
end

---Insert a log statement for the identifier under the cursor.
---@param level 'log'|'info'|'error'
---@param opts { above: boolean|nil, visual: boolean|nil }|nil
---@return boolean inserted
function M.log(level, opts)
  opts = opts or {}
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype

  local set = templates.for_filetype(filetype, M.options.templates)
  if not set then
    vim.notify(('logline: no template for filetype %q'):format(filetype), vim.log.levels.WARN)
    return false
  end

  local variable = context.variable(opts)
  if not context.is_loggable(variable) then
    vim.notify('logline: nothing loggable under the cursor', vim.log.levels.WARN)
    return false
  end

  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local text = statement.render({
    template = set[level] or set.log,
    label = statement.label({
      file = vim.fn.expand('%:t'),
      line = lnum,
      enclosing = context.enclosing(bufnr),
      variable = variable,
    }),
    variable = variable,
    commentstring = vim.bo[bufnr].commentstring,
    tag = M.options.tag,
    indent = buffer.indent_of(bufnr, lnum),
  })

  buffer.insert(bufnr, lnum, text, { above = opts.above })
  return true
end

---@return integer removed
function M.delete()
  local removed = buffer.delete(vim.api.nvim_get_current_buf(), M.options.tag)
  vim.notify(('logline: removed %d statement%s'):format(removed, removed == 1 and '' or 's'))
  return removed
end

---@return integer touched
function M.comment_toggle()
  return buffer.comment_toggle(vim.api.nvim_get_current_buf(), M.options.tag)
end

---Populate the quickfix list with every logline statement under the cwd.
---@return integer count
function M.search()
  local previous = vim.o.grepprg
  vim.o.grepprg = 'rg --vimgrep --hidden --glob=!.git'
  local ok = pcall(vim.cmd, ('silent grep! %s'):format(vim.fn.shellescape(M.options.tag)))
  vim.o.grepprg = previous
  if not ok then return 0 end

  local items = vim.fn.getqflist()
  if #items == 0 then
    vim.notify('logline: no statements left behind')
    return 0
  end
  vim.cmd('copen')
  return #items
end

return M
